#!/bin/bash

# Progress tracker for Design Partner Workflow
# Runs when Claude finishes responding
# Shows plan progress and suggests next steps

# Only run if there are active plans
if [[ ! -d "plans/active" ]] || [[ -z "$(ls -A plans/active 2>/dev/null)" ]]; then
    exit 0  # No active plans, nothing to show
fi

# Find active plans
ACTIVE_PLANS=()
while IFS= read -r -d '' plan_file; do
    if grep -q "Status: active" "$plan_file" 2>/dev/null; then
        ACTIVE_PLANS+=("$plan_file")
    fi
done < <(find plans/active -name "*.md" -print0 2>/dev/null)

# Exit if no active plans
if [[ ${#ACTIVE_PLANS[@]} -eq 0 ]]; then
    exit 0
fi

echo ""
echo "📊 Progress Summary"
echo "==================="

for plan in "${ACTIVE_PLANS[@]}"; do
    PLAN_NAME=$(basename "$plan" .md | tr '-' ' ' | sed 's/\b\w/\U&/g')
    
    # Count checklist items
    TOTAL_TASKS=$(grep -c "- \[ \]" "$plan" 2>/dev/null || echo "0")
    COMPLETED_TASKS=$(grep -c "- \[x\]" "$plan" 2>/dev/null || echo "0")
    TOTAL_ALL_TASKS=$((TOTAL_TASKS + COMPLETED_TASKS))
    
    if [[ $TOTAL_ALL_TASKS -gt 0 ]]; then
        PERCENTAGE=$((COMPLETED_TASKS * 100 / TOTAL_ALL_TASKS))
        
        # Create progress bar
        FILLED=$((PERCENTAGE / 10))
        EMPTY=$((10 - FILLED))
        PROGRESS_BAR=""
        for ((i=0; i<FILLED; i++)); do
            PROGRESS_BAR+="█"
        done
        for ((i=0; i<EMPTY; i++)); do
            PROGRESS_BAR+="░"
        done
        
        echo ""
        echo "📋 $PLAN_NAME"
        echo "   Progress: [$PROGRESS_BAR] ${PERCENTAGE}% (${COMPLETED_TASKS}/${TOTAL_ALL_TASKS} tasks)"
        
        # Show next pending tasks (max 3)
        NEXT_TASKS=$(grep -n "- \[ \]" "$plan" 2>/dev/null | head -3)
        if [[ -n "$NEXT_TASKS" ]]; then
            echo "   Next tasks:"
            while IFS= read -r task_line; do
                TASK_TEXT=$(echo "$task_line" | sed 's/^[0-9]*:- \[ \] *//')
                echo "     • $TASK_TEXT"
            done <<< "$NEXT_TASKS"
        fi
        
        # Show completion status
        if [[ $PERCENTAGE -eq 100 ]]; then
            echo "   🎉 Ready for completion! Consider archiving this plan."
        elif [[ $PERCENTAGE -ge 80 ]]; then
            echo "   🚀 Nearly done! Focus on finishing remaining tasks."
        elif [[ $PERCENTAGE -ge 50 ]]; then
            echo "   ⚡ Good progress! Keep implementing step by step."
        elif [[ $PERCENTAGE -gt 0 ]]; then
            echo "   🏗️  Getting started! Continue with the implementation plan."
        else
            echo "   📝 Plan ready! Start with the first implementation phase."
        fi
    else
        echo ""
        echo "📋 $PLAN_NAME"
        echo "   Status: Plan created, ready to start implementation"
    fi
done

# Suggest helpful commands
echo ""
echo "💡 Helpful commands:"
echo "   • '/status' - Show detailed progress"
echo "   • '/plans' - List all active plans" 
echo "   • Ask 'what should I work on next?' for guidance"
echo "   • Ask 'show me the next step' to continue implementation"

# Check for completed plans that should be archived
COMPLETED_PLANS=()
while IFS= read -r -d '' plan_file; do
    if grep -q "Status: completed" "$plan_file" 2>/dev/null; then
        COMPLETED_PLANS+=("$plan_file")
    fi
done < <(find plans/active -name "*.md" -print0 2>/dev/null)

if [[ ${#COMPLETED_PLANS[@]} -gt 0 ]]; then
    echo ""
    echo "🗂️  Found ${#COMPLETED_PLANS[@]} completed plan(s) ready for archiving:"
    for plan in "${COMPLETED_PLANS[@]}"; do
        PLAN_NAME=$(basename "$plan" .md)
        echo "   • Use '/archive $PLAN_NAME' to archive"
    done
fi

echo ""

exit 0