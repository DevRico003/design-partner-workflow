#!/bin/bash

# Context loader for Design Partner Workflow
# Runs at session start to load relevant plans
# Helps Claude understand current project state

echo "🚀 Loading Design Partner context..."

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# Find active plans
ACTIVE_PLANS=()
if [[ -d "plans/active" ]]; then
    while IFS= read -r -d '' plan_file; do
        if grep -q "Status: active" "$plan_file" 2>/dev/null; then
            ACTIVE_PLANS+=("$plan_file")
        fi
    done < <(find plans/active -name "*.md" -print0 2>/dev/null)
fi

# Find recent plans (modified in last 7 days)
RECENT_PLANS=()
if [[ -d "plans" ]]; then
    while IFS= read -r -d '' plan_file; do
        # Exclude administrative files
        if [[ "$(basename "$plan_file")" != "INDEX.md" ]] && [[ "$(basename "$plan_file")" != ".template.md" ]]; then
            RECENT_PLANS+=("$plan_file")
        fi
    done < <(find plans -name "*.md" -mtime -7 -print0 2>/dev/null)
fi

# Display summary
echo ""
if [[ ${#ACTIVE_PLANS[@]} -eq 0 ]] && [[ ${#RECENT_PLANS[@]} -eq 0 ]]; then
    echo "📝 No active plans found. Ready to start fresh!"
    echo "💡 Use '/plan [feature-name]' to create your first plan"
else
    if [[ ${#ACTIVE_PLANS[@]} -gt 0 ]]; then
        echo "📋 Active Plans (${#ACTIVE_PLANS[@]}):"
        for plan in "${ACTIVE_PLANS[@]}"; do
            PLAN_NAME=$(basename "$plan" .md)
            CREATED_DATE=$(grep "Created:" "$plan" | cut -d: -f2- | tr -d ' ' 2>/dev/null || echo "unknown")
            
            # Count progress
            TOTAL=$(grep -c "- \[ \]" "$plan" 2>/dev/null || echo "0")
            DONE=$(grep -c "- \[x\]" "$plan" 2>/dev/null || echo "0")
            
            if [[ $TOTAL -gt 0 ]]; then
                PERCENTAGE=$((DONE * 100 / TOTAL))
                echo "  • $PLAN_NAME (${PERCENTAGE}% complete) - $CREATED_DATE"
            else
                echo "  • $PLAN_NAME - $CREATED_DATE"
            fi
        done
        echo ""
    fi
    
    if [[ ${#RECENT_PLANS[@]} -gt 0 ]] && [[ ${#ACTIVE_PLANS[@]} -lt ${#RECENT_PLANS[@]} ]]; then
        DRAFT_COUNT=$((${#RECENT_PLANS[@]} - ${#ACTIVE_PLANS[@]}))
        echo "📄 Recent activity: $DRAFT_COUNT draft/completed plans in last 7 days"
        echo ""
    fi
fi

# Show current branch context
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "🌿 Current branch: $CURRENT_BRANCH"
    
    # Check if there's a plan for this branch
    BRANCH_PLAN_EXISTS=false
    BRANCH_SLUG=$(echo "$CURRENT_BRANCH" | sed 's/[^a-zA-Z0-9]/-/g')
    
    for plan in "plans/active/${CURRENT_BRANCH}.md" "plans/active/${BRANCH_SLUG}.md"; do
        if [[ -f "$plan" ]]; then
            echo "✅ Found plan for current branch: $(basename "$plan")"
            BRANCH_PLAN_EXISTS=true
            break
        fi
    done
    
    if [[ $BRANCH_PLAN_EXISTS == false ]] && [[ "$CURRENT_BRANCH" == feature/* ]]; then
        echo "💡 Consider creating a plan for this feature branch"
        echo "   Use: /plan $(echo "$CURRENT_BRANCH" | sed 's/feature\///')"
    fi
    echo ""
fi

# Quick tips based on context
if [[ ${#ACTIVE_PLANS[@]} -eq 0 ]]; then
    echo "🎯 Quick Start Tips:"
    echo "  • Use '/plan [name]' to create a feature plan"
    echo "  • Small changes (< 5 files) don't need full plans"
    echo "  • Ask me to 'create a plan for [feature]' anytime"
elif [[ ${#ACTIVE_PLANS[@]} -eq 1 ]]; then
    echo "🎯 Ready to continue development on active plan"
    echo "  • Use '/status' to see current progress"
    echo "  • Ask 'what's next?' to continue implementation"
else
    echo "🎯 Multiple active plans detected"
    echo "  • Use '/plans' to see all active plans"
    echo "  • Focus on one plan at a time for best results"
fi

echo ""
echo "🔧 Design Partner Workflow active - I'll help plan, implement, and document your changes"

# Create logs directory if it doesn't exist
mkdir -p .claude/logs 2>/dev/null

# Log session start
echo "$(date '+%Y-%m-%d %H:%M:%S') - Session started - Branch: $CURRENT_BRANCH - Active plans: ${#ACTIVE_PLANS[@]}" >> .claude/logs/sessions.log 2>/dev/null

exit 0