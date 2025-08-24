#!/bin/bash

# Plan updater for Design Partner Workflow  
# Runs after successful Write/Edit/MultiEdit operations
# Updates active plan with implementation notes

# Read the tool result from stdin
TOOL_RESULT=$(cat)

# Extract file path from the context
FILE_PATH=$(echo "$TOOL_RESULT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4 | head -1)
OPERATION=$(echo "$TOOL_RESULT" | grep -o '"tool":"[^"]*"' | cut -d'"' -f4 | head -1)

# Skip if no file path found or if it's a trivial file
if [[ -z "$FILE_PATH" ]] || [[ "$FILE_PATH" == *".md" ]] || [[ "$FILE_PATH" == *".txt" ]] || [[ "$FILE_PATH" == *".json" ]]; then
    exit 0
fi

# Get current branch and find active plan
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
BRANCH_SLUG=$(echo "$CURRENT_BRANCH" | sed 's/[^a-zA-Z0-9]/-/g')

# Find active plan file
PLAN_FILE=""
POSSIBLE_PLANS=(
    "plans/active/${CURRENT_BRANCH}.md"
    "plans/active/${BRANCH_SLUG}.md"
)

# Look for any active plan in the active directory
for plan_file in plans/active/*.md; do
    if [[ -f "$plan_file" ]] && grep -q "Status: active" "$plan_file" 2>/dev/null; then
        PLAN_FILE="$plan_file"
        break
    fi
done

# If no active plan found, check the branch-specific files
if [[ -z "$PLAN_FILE" ]]; then
    for plan_file in "${POSSIBLE_PLANS[@]}"; do
        if [[ -f "$plan_file" ]]; then
            PLAN_FILE="$plan_file"
            break
        fi
    done
fi

# Exit if no plan file found
if [[ -z "$PLAN_FILE" ]] || [[ ! -f "$PLAN_FILE" ]]; then
    echo "ℹ️  No active plan to update"
    exit 0
fi

# Create log entry
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
FILE_BASENAME=$(basename "$FILE_PATH")

# Determine the type of change
CHANGE_TYPE="Modified"
if [[ "$OPERATION" == "Write" ]] && [[ ! -f "$FILE_PATH.backup" ]]; then
    CHANGE_TYPE="Created"
fi

# Count lines changed (approximation)
LINES_CHANGED="unknown"
if [[ -f "$FILE_PATH" ]]; then
    LINES_CHANGED=$(wc -l < "$FILE_PATH")
fi

# Prepare update entry
UPDATE_ENTRY="
### ${TIMESTAMP} - Development Update
- **${CHANGE_TYPE}**: \`${FILE_BASENAME}\`
- **Operation**: ${OPERATION}
- **Lines**: ~${LINES_CHANGED}
- **Branch**: ${CURRENT_BRANCH}"

# Check if Implementation Notes section exists
if grep -q "## Implementation Notes" "$PLAN_FILE"; then
    # Add to existing section
    sed -i "/## Implementation Notes/a\\$UPDATE_ENTRY" "$PLAN_FILE"
else
    # Create new section before completion checklist
    if grep -q "## Completion Checklist" "$PLAN_FILE"; then
        sed -i "/## Completion Checklist/i\\## Implementation Notes\\$UPDATE_ENTRY\\n" "$PLAN_FILE"
    else
        # Add to end of file
        echo -e "\n## Implementation Notes$UPDATE_ENTRY\n" >> "$PLAN_FILE"
    fi
fi

# Update the "Updated" metadata field
if grep -q "Updated:" "$PLAN_FILE"; then
    sed -i "s/Updated: .*/Updated: $(date '+%Y-%m-%d')/" "$PLAN_FILE"
fi

# Update completion percentage (rough estimate based on checked items)
TOTAL_ITEMS=$(grep -c "- \[ \]" "$PLAN_FILE" 2>/dev/null || echo "0")
COMPLETED_ITEMS=$(grep -c "- \[x\]" "$PLAN_FILE" 2>/dev/null || echo "0")

if [[ $TOTAL_ITEMS -gt 0 ]]; then
    PERCENTAGE=$((COMPLETED_ITEMS * 100 / TOTAL_ITEMS))
    echo "📊 Plan updated: ${COMPLETED_ITEMS}/${TOTAL_ITEMS} tasks complete (${PERCENTAGE}%)"
else
    echo "✅ Plan updated with implementation notes"
fi

# Create backup of important files
mkdir -p .claude/backups 2>/dev/null
cp "$PLAN_FILE" ".claude/backups/$(basename "$PLAN_FILE").$(date +%s)" 2>/dev/null

exit 0