#!/bin/bash

# Archive Plans Maintenance Script
# Automatically archives old completed and abandoned plans
# Run weekly via cron or manually for cleanup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPLETED_AGE_DAYS=30  # Archive completed plans older than this
DRAFT_AGE_DAYS=60      # Archive abandoned drafts older than this
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --completed-age)
            COMPLETED_AGE_DAYS="$2"
            shift 2
            ;;
        --draft-age)
            DRAFT_AGE_DAYS="$2"
            shift 2
            ;;
        --help)
            cat << EOF
Archive Plans Maintenance Script

Usage: $0 [OPTIONS]

Options:
    --dry-run           Show what would be archived without actually moving files
    --completed-age N   Archive completed plans older than N days (default: 30)
    --draft-age N       Archive abandoned drafts older than N days (default: 60)
    --help              Show this help message

Examples:
    $0                          # Run with default settings
    $0 --dry-run               # Preview what would be archived
    $0 --completed-age 14      # Archive completed plans older than 2 weeks
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🗂️  Plan Archive Maintenance${NC}"
echo "=================================="

if [[ $DRY_RUN == true ]]; then
    echo -e "${YELLOW}⚠️  DRY RUN MODE - No files will be moved${NC}"
fi

echo "Settings:"
echo "  - Archive completed plans older than: ${COMPLETED_AGE_DAYS} days"
echo "  - Archive abandoned drafts older than: ${DRAFT_AGE_DAYS} days"
echo ""

# Check if plans directories exist
if [[ ! -d "plans/active" ]]; then
    echo -e "${RED}❌ Error: plans/active directory not found${NC}"
    echo "Make sure you're running this from the project root"
    exit 1
fi

# Create archive directory structure
CURRENT_YEAR=$(date +%Y)
CURRENT_QUARTER="q$(($(date +%-m -1) / 3 + 1))"
ARCHIVE_BASE="plans/archive"
COMPLETED_DIR="$ARCHIVE_BASE/$CURRENT_YEAR/$CURRENT_QUARTER/completed"
ABANDONED_DIR="$ARCHIVE_BASE/$CURRENT_YEAR/$CURRENT_QUARTER/abandoned"

if [[ $DRY_RUN == false ]]; then
    mkdir -p "$COMPLETED_DIR" "$ABANDONED_DIR"
fi

# Counters
COMPLETED_ARCHIVED=0
ABANDONED_ARCHIVED=0
TOTAL_SCANNED=0

# Function to archive a plan
archive_plan() {
    local plan_file="$1"
    local archive_dir="$2"
    local status="$3"
    local reason="$4"
    
    local filename=$(basename "$plan_file")
    local target="$archive_dir/$filename"
    
    if [[ $DRY_RUN == false ]]; then
        # Update plan metadata
        local temp_file=$(mktemp)
        if grep -q "Status:" "$plan_file"; then
            sed "s/Status: .*/Status: archived/" "$plan_file" > "$temp_file"
        else
            {
                head -n 1 "$plan_file"
                echo "- **Status**: archived"
                tail -n +2 "$plan_file"
            } > "$temp_file"
        fi
        
        # Add archive metadata
        {
            head -n -1 "$temp_file"
            echo ""
            echo "## Archive Information"
            echo "- **Archived Date**: $(date '+%Y-%m-%d')"
            echo "- **Archive Reason**: $reason"
            echo "- **Original Status**: $status"
            echo ""
            echo "*This plan was automatically archived by the maintenance script*"
        } > "$target"
        
        # Remove original file
        rm "$plan_file" "$temp_file"
        
        echo -e "${GREEN}✅ Archived: $filename → $archive_dir${NC}"
    else
        echo -e "${YELLOW}📄 Would archive: $filename → $archive_dir (reason: $reason)${NC}"
    fi
}

echo "Scanning active plans..."
echo ""

# Find and process plans
if [[ -d "plans/active" ]]; then
    for plan_file in plans/active/*.md; do
        # Skip if no .md files found (glob didn't match)
        [[ -f "$plan_file" ]] || continue
        
        TOTAL_SCANNED=$((TOTAL_SCANNED + 1))
        
        local filename=$(basename "$plan_file")
        local file_age_days=$((($(date +%s) - $(stat -c %Y "$plan_file")) / 86400))
        local status="unknown"
        
        # Extract status from plan
        if grep -q "Status:" "$plan_file"; then
            status=$(grep "Status:" "$plan_file" | head -1 | sed 's/.*Status[^:]*: *\([^|]*\).*/\1/' | tr -d ' ')
        fi
        
        echo "📋 $filename (age: ${file_age_days}d, status: $status)"
        
        # Archive completed plans older than threshold
        if [[ "$status" == "completed" ]] && [[ $file_age_days -gt $COMPLETED_AGE_DAYS ]]; then
            archive_plan "$plan_file" "$COMPLETED_DIR" "$status" "completed_old"
            COMPLETED_ARCHIVED=$((COMPLETED_ARCHIVED + 1))
        
        # Archive old draft plans (likely abandoned)
        elif [[ "$status" == "draft" ]] && [[ $file_age_days -gt $DRAFT_AGE_DAYS ]]; then
            archive_plan "$plan_file" "$ABANDONED_DIR" "$status" "stale_draft"
            ABANDONED_ARCHIVED=$((ABANDONED_ARCHIVED + 1))
        
        # Show status for other plans
        elif [[ "$status" == "active" ]]; then
            echo "   ⚡ Active - keeping in workspace"
        elif [[ "$status" == "completed" ]]; then
            local days_until_archive=$((COMPLETED_AGE_DAYS - file_age_days))
            echo "   🎉 Completed - will archive in ${days_until_archive} days"
        elif [[ "$status" == "draft" ]]; then
            local days_until_archive=$((DRAFT_AGE_DAYS - file_age_days))
            echo "   📝 Draft - will archive in ${days_until_archive} days if unchanged"
        else
            echo "   ❓ Unknown status - skipping"
        fi
        
        echo ""
    done
fi

# Process completed plans directory if it exists
if [[ -d "plans/completed" ]]; then
    echo "Checking recently completed plans..."
    for plan_file in plans/completed/*/*.md 2>/dev/null; do
        [[ -f "$plan_file" ]] || continue
        
        local file_age_days=$((($(date +%s) - $(stat -c %Y "$plan_file")) / 86400))
        local filename=$(basename "$plan_file")
        
        if [[ $file_age_days -gt $COMPLETED_AGE_DAYS ]]; then
            echo "📋 $filename (age: ${file_age_days}d)"
            archive_plan "$plan_file" "$COMPLETED_DIR" "completed" "completed_old"
            COMPLETED_ARCHIVED=$((COMPLETED_ARCHIVED + 1))
        fi
    done
fi

# Summary
echo "=================================="
echo "📊 Archive Summary:"
echo "   • Total plans scanned: $TOTAL_SCANNED"
echo "   • Completed plans archived: $COMPLETED_ARCHIVED"
echo "   • Abandoned drafts archived: $ABANDONED_ARCHIVED"
echo "   • Total archived: $((COMPLETED_ARCHIVED + ABANDONED_ARCHIVED))"

if [[ $DRY_RUN == true ]]; then
    echo ""
    echo -e "${YELLOW}This was a dry run. Run without --dry-run to actually archive files.${NC}"
elif [[ $((COMPLETED_ARCHIVED + ABANDONED_ARCHIVED)) -gt 0 ]]; then
    echo ""
    echo -e "${GREEN}✅ Archive maintenance completed successfully${NC}"
    echo "Archived plans are stored in: $ARCHIVE_BASE/$CURRENT_YEAR/$CURRENT_QUARTER/"
    
    # Update INDEX.md if it exists
    if [[ -f "plans/INDEX.md" ]] && [[ $DRY_RUN == false ]]; then
        echo ""
        echo "📝 Updating plans/INDEX.md..."
        # This could be enhanced to actually update the INDEX file
        echo "   (Manual update of INDEX.md recommended)"
    fi
else
    echo ""
    echo -e "${GREEN}✅ No plans needed archiving - workspace is clean${NC}"
fi

# Cleanup empty directories
if [[ $DRY_RUN == false ]]; then
    find plans -type d -empty -delete 2>/dev/null || true
fi

echo ""
echo "💡 Tips:"
echo "   • Run this script weekly to keep workspace clean"
echo "   • Use --dry-run to preview changes first"
echo "   • Archived plans can be restored by moving them back to active/"
echo "   • Consider setting up a cron job: 0 0 * * 0 $PWD/$0"