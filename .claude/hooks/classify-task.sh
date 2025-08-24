#!/bin/bash

# Classification hook for Design Partner Workflow
# Analyzes user prompt and determines task complexity
# Returns suggestions for planning approach

# Read the user's prompt from stdin
USER_PROMPT=$(cat)

# Get current branch for context
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# Define complexity keywords
TRIVIAL_KEYWORDS=("typo" "color" "spacing" "text" "translation" "comment" "fix spelling" "change color")
SMALL_KEYWORDS=("add button" "new field" "validation" "endpoint" "form" "simple" "quick")
MEDIUM_KEYWORDS=("component" "refactor" "integration" "page" "feature" "new component")
LARGE_KEYWORDS=("feature" "migration" "architecture" "service" "system" "redesign" "new feature")
EPIC_KEYWORDS=("redesign" "rewrite" "platform" "infrastructure" "complete" "entire" "overhaul")

# Convert prompt to lowercase for matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Function to check if prompt contains keywords
contains_keywords() {
    local -n keywords=$1
    for keyword in "${keywords[@]}"; do
        if [[ $PROMPT_LOWER == *"$keyword"* ]]; then
            return 0
        fi
    done
    return 1
}

# Classify based on keywords
COMPLEXITY="unknown"
SUGGESTION=""

if contains_keywords EPIC_KEYWORDS; then
    COMPLEXITY="epic"
    SUGGESTION="🏗️  This appears to be an epic-level task. Consider breaking it down into smaller features."
elif contains_keywords LARGE_KEYWORDS; then
    COMPLEXITY="large" 
    SUGGESTION="📋 This looks like a large feature requiring a comprehensive plan."
elif contains_keywords MEDIUM_KEYWORDS; then
    COMPLEXITY="medium"
    SUGGESTION="📝 This appears to be a medium complexity task. A plan would be helpful."
elif contains_keywords SMALL_KEYWORDS; then
    COMPLEXITY="small"
    SUGGESTION="⚡ This looks like a small task. I can include a mini-plan in my response."
elif contains_keywords TRIVIAL_KEYWORDS; then
    COMPLEXITY="trivial"
    SUGGESTION="✅ This appears to be a trivial change. No plan needed."
else
    # Default classification based on prompt length and common patterns
    WORD_COUNT=$(echo "$USER_PROMPT" | wc -w)
    if [[ $WORD_COUNT -lt 10 ]]; then
        COMPLEXITY="small"
        SUGGESTION="⚡ Short request - likely a small task."
    else
        COMPLEXITY="medium"
        SUGGESTION="📝 Detailed request - might benefit from planning."
    fi
fi

# Check if there's already a plan for current branch
PLAN_EXISTS=false
if [[ -f "plans/active/${CURRENT_BRANCH}.md" ]] || [[ -f "plans/active/${CURRENT_BRANCH/\//-}.md" ]]; then
    PLAN_EXISTS=true
fi

# Output classification result
echo "Task classified as: $COMPLEXITY"
if [[ $PLAN_EXISTS == true ]]; then
    echo "✅ Plan exists for current branch: $CURRENT_BRANCH"
else
    echo "$SUGGESTION"
fi

# Log classification for debugging (optional)
echo "$(date '+%Y-%m-%d %H:%M:%S') - $COMPLEXITY: $USER_PROMPT" >> .claude/logs/classifications.log 2>/dev/null

# Exit with appropriate code
case $COMPLEXITY in
    "trivial"|"small")
        exit 0  # Proceed without blocking
        ;;
    "medium"|"large"|"epic")
        if [[ $PLAN_EXISTS == true ]]; then
            exit 0  # Plan exists, proceed
        else
            exit 1  # Suggest planning but don't block
        fi
        ;;
    *)
        exit 0  # Unknown, don't block
        ;;
esac