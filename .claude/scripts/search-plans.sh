#!/bin/bash

# Plan Search and Management Utility
# Provides various ways to find and analyze development plans

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SEARCH_TERM=""
SEARCH_TYPE="content"
INCLUDE_ARCHIVED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --keyword|-k)
            SEARCH_TERM="$2"
            SEARCH_TYPE="content"
            shift 2
            ;;
        --status|-s)
            SEARCH_TERM="$2"
            SEARCH_TYPE="status"
            shift 2
            ;;
        --author|-a)
            SEARCH_TERM="$2"
            SEARCH_TYPE="author"
            shift 2
            ;;
        --complexity|-c)
            SEARCH_TERM="$2"
            SEARCH_TYPE="complexity"
            shift 2
            ;;
        --include-archived)
            INCLUDE_ARCHIVED=true
            shift
            ;;
        --stats)
            SEARCH_TYPE="stats"
            shift
            ;;
        --health)
            SEARCH_TYPE="health"
            shift
            ;;
        --help)
            cat << EOF
Plan Search and Management Utility

Usage: $0 [OPTIONS] [SEARCH_TERM]

Search Options:
    -k, --keyword TERM      Search plan content for keyword
    -s, --status STATUS     Find plans with specific status (active, draft, completed)
    -a, --author AUTHOR     Find plans by author
    -c, --complexity LEVEL  Find plans by complexity (trivial, small, medium, large, epic)
    --include-archived      Include archived plans in search

Analysis Options:
    --stats                 Show project statistics
    --health                Show project health metrics

Examples:
    $0 -k "authentication"           # Find plans mentioning authentication
    $0 -s active                     # Show all active plans
    $0 -c large --include-archived   # Find all large complexity plans
    $0 --stats                       # Show project statistics
    $0 --health                      # Show project health check
EOF
            exit 0
            ;;
        *)
            if [[ -z "$SEARCH_TERM" ]]; then
                SEARCH_TERM="$1"
                SEARCH_TYPE="content"
            fi
            shift
            ;;
    esac
done

# Build search paths
SEARCH_PATHS=("plans/active")
if [[ -d "plans/completed" ]]; then
    SEARCH_PATHS+=("plans/completed")
fi
if [[ $INCLUDE_ARCHIVED == true ]] && [[ -d "plans/archive" ]]; then
    SEARCH_PATHS+=("plans/archive")
fi

# Function to extract metadata from plan
get_plan_metadata() {
    local plan_file="$1"
    local field="$2"
    
    grep "^- \*\*${field}\*\*:" "$plan_file" 2>/dev/null | head -1 | sed "s/^- \*\*${field}\*\*: *//" || echo "unknown"
}

# Function to calculate plan progress
calculate_progress() {
    local plan_file="$1"
    
    local total_tasks=$(grep -c "- \[ \]" "$plan_file" 2>/dev/null || echo "0")
    local completed_tasks=$(grep -c "- \[x\]" "$plan_file" 2>/dev/null || echo "0")
    local all_tasks=$((total_tasks + completed_tasks))
    
    if [[ $all_tasks -gt 0 ]]; then
        echo "$((completed_tasks * 100 / all_tasks))% ($completed_tasks/$all_tasks)"
    else
        echo "No tasks"
    fi
}

# Search by content
search_content() {
    echo -e "${BLUE}🔍 Searching for: '$SEARCH_TERM'${NC}"
    echo ""
    
    local found=0
    for search_path in "${SEARCH_PATHS[@]}"; do
        [[ -d "$search_path" ]] || continue
        
        while IFS= read -r -d '' plan_file; do
            if grep -l -i "$SEARCH_TERM" "$plan_file" >/dev/null 2>&1; then
                found=$((found + 1))
                local filename=$(basename "$plan_file" .md)
                local status=$(get_plan_metadata "$plan_file" "Status")
                local progress=$(calculate_progress "$plan_file")
                
                echo -e "${GREEN}📋 $filename${NC}"
                echo "   Status: $status | Progress: $progress"
                echo "   Location: $plan_file"
                
                # Show matching lines
                echo "   Matches:"
                grep -n -i --color=never "$SEARCH_TERM" "$plan_file" | head -3 | while IFS= read -r line; do
                    echo "     $line"
                done
                echo ""
            fi
        done < <(find "$search_path" -name "*.md" -type f -print0 2>/dev/null)
    done
    
    if [[ $found -eq 0 ]]; then
        echo "No plans found matching '$SEARCH_TERM'"
    else
        echo "Found $found plan(s)"
    fi
}

# Search by status
search_status() {
    echo -e "${BLUE}📊 Plans with status: '$SEARCH_TERM'${NC}"
    echo ""
    
    local found=0
    for search_path in "${SEARCH_PATHS[@]}"; do
        [[ -d "$search_path" ]] || continue
        
        while IFS= read -r -d '' plan_file; do
            local status=$(get_plan_metadata "$plan_file" "Status")
            if [[ "${status,,}" == "${SEARCH_TERM,,}" ]]; then
                found=$((found + 1))
                local filename=$(basename "$plan_file" .md)
                local created=$(get_plan_metadata "$plan_file" "Created")
                local complexity=$(get_plan_metadata "$plan_file" "Complexity")
                local progress=$(calculate_progress "$plan_file")
                
                echo -e "${GREEN}📋 $filename${NC}"
                echo "   Created: $created | Complexity: $complexity"
                echo "   Progress: $progress"
                echo "   Location: $plan_file"
                echo ""
            fi
        done < <(find "$search_path" -name "*.md" -type f -print0 2>/dev/null)
    done
    
    [[ $found -eq 0 ]] && echo "No plans found with status '$SEARCH_TERM'"
}

# Show project statistics
show_stats() {
    echo -e "${BLUE}📊 Project Plan Statistics${NC}"
    echo "=========================="
    echo ""
    
    local total_active=0
    local total_draft=0
    local total_completed=0
    local total_archived=0
    local complexity_count=()
    
    # Count by status and complexity
    for search_path in "${SEARCH_PATHS[@]}"; do
        [[ -d "$search_path" ]] || continue
        
        while IFS= read -r -d '' plan_file; do
            local status=$(get_plan_metadata "$plan_file" "Status")
            local complexity=$(get_plan_metadata "$plan_file" "Complexity")
            
            case "${status,,}" in
                active) total_active=$((total_active + 1)) ;;
                draft) total_draft=$((total_draft + 1)) ;;
                completed) total_completed=$((total_completed + 1)) ;;
                archived) total_archived=$((total_archived + 1)) ;;
            esac
            
            # Count complexity
            complexity_count["$complexity"]=$((${complexity_count["$complexity"]:-0} + 1))
        done < <(find "$search_path" -name "*.md" -type f -print0 2>/dev/null)
    done
    
    echo "Status Distribution:"
    echo "  🟢 Active: $total_active"
    echo "  📝 Draft: $total_draft"
    echo "  ✅ Completed: $total_completed"
    echo "  📦 Archived: $total_archived"
    echo "  📊 Total: $((total_active + total_draft + total_completed + total_archived))"
    echo ""
    
    echo "Complexity Distribution:"
    for complexity in trivial small medium large epic; do
        local count=${complexity_count["$complexity"]:-0}
        [[ $count -gt 0 ]] && echo "  $complexity: $count"
    done
    echo ""
    
    # Recent activity
    echo "Recent Activity (last 7 days):"
    local recent_count=0
    for search_path in "${SEARCH_PATHS[@]}"; do
        [[ -d "$search_path" ]] || continue
        while IFS= read -r -d '' plan_file; do
            recent_count=$((recent_count + 1))
        done < <(find "$search_path" -name "*.md" -mtime -7 -print0 2>/dev/null)
    done
    echo "  📅 Plans modified: $recent_count"
}

# Show project health
show_health() {
    echo -e "${BLUE}🏥 Project Health Check${NC}"
    echo "======================"
    echo ""
    
    local issues=0
    local warnings=0
    
    # Check for stale active plans
    echo "🔍 Checking for stale active plans..."
    local stale_active=0
    if [[ -d "plans/active" ]]; then
        while IFS= read -r -d '' plan_file; do
            local status=$(get_plan_metadata "$plan_file" "Status")
            if [[ "${status,,}" == "active" ]]; then
                local age_days=$((($(date +%s) - $(stat -c %Y "$plan_file")) / 86400))
                if [[ $age_days -gt 14 ]]; then
                    stale_active=$((stale_active + 1))
                    echo "  ⚠️  $(basename "$plan_file" .md) - ${age_days} days old"
                fi
            fi
        done < <(find "plans/active" -name "*.md" -print0 2>/dev/null)
    fi
    
    if [[ $stale_active -eq 0 ]]; then
        echo "  ✅ No stale active plans"
    else
        warnings=$((warnings + stale_active))
        echo "  📊 Found $stale_active stale active plan(s)"
    fi
    echo ""
    
    # Check for old drafts
    echo "🔍 Checking for abandoned drafts..."
    local old_drafts=0
    if [[ -d "plans/active" ]]; then
        while IFS= read -r -d '' plan_file; do
            local status=$(get_plan_metadata "$plan_file" "Status")
            if [[ "${status,,}" == "draft" ]]; then
                local age_days=$((($(date +%s) - $(stat -c %Y "$plan_file")) / 86400))
                if [[ $age_days -gt 7 ]]; then
                    old_drafts=$((old_drafts + 1))
                    echo "  📝 $(basename "$plan_file" .md) - ${age_days} days old"
                fi
            fi
        done < <(find "plans/active" -name "*.md" -print0 2>/dev/null)
    fi
    
    if [[ $old_drafts -eq 0 ]]; then
        echo "  ✅ No old draft plans"
    else
        warnings=$((warnings + old_drafts))
        echo "  📊 Found $old_drafts old draft plan(s)"
    fi
    echo ""
    
    # Check workspace size
    echo "🔍 Checking workspace size..."
    local active_count=0
    [[ -d "plans/active" ]] && active_count=$(find "plans/active" -name "*.md" | wc -l)
    
    if [[ $active_count -le 3 ]]; then
        echo "  ✅ Workspace size optimal ($active_count active plans)"
    elif [[ $active_count -le 5 ]]; then
        echo "  ⚠️  Workspace getting busy ($active_count active plans)"
        warnings=$((warnings + 1))
    else
        echo "  ❌ Workspace cluttered ($active_count active plans)"
        issues=$((issues + 1))
    fi
    echo ""
    
    # Summary
    echo "Health Summary:"
    if [[ $issues -eq 0 ]] && [[ $warnings -eq 0 ]]; then
        echo "  🟢 Excellent - No issues found"
    elif [[ $issues -eq 0 ]]; then
        echo "  🟡 Good - $warnings warning(s), no critical issues"
    else
        echo "  🔴 Needs attention - $issues issue(s), $warnings warning(s)"
    fi
    
    echo ""
    echo "💡 Recommendations:"
    [[ $stale_active -gt 0 ]] && echo "  • Review stale active plans - complete or archive them"
    [[ $old_drafts -gt 0 ]] && echo "  • Clean up old drafts - activate or archive them"
    [[ $active_count -gt 5 ]] && echo "  • Archive completed plans to reduce workspace clutter"
    echo "  • Run './claude/scripts/archive-plans.sh --dry-run' to preview cleanup"
}

# Main execution
case $SEARCH_TYPE in
    content)
        if [[ -z "$SEARCH_TERM" ]]; then
            echo "Error: Search term required for content search"
            echo "Use --help for usage information"
            exit 1
        fi
        search_content
        ;;
    status)
        search_status
        ;;
    author|complexity)
        echo "Search by $SEARCH_TYPE not yet implemented"
        exit 1
        ;;
    stats)
        show_stats
        ;;
    health)
        show_health
        ;;
    *)
        echo "Unknown search type: $SEARCH_TYPE"
        echo "Use --help for usage information"
        exit 1
        ;;
esac