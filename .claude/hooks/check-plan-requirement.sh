#!/bin/bash

# Plan requirement checker for Design Partner Workflow
# Runs before Write/Edit/MultiEdit operations
# Blocks complex changes that don't have a plan

# Read the tool use context from stdin
TOOL_CONTEXT=$(cat)

# Extract file path and operation from JSON context
FILE_PATH=$(echo "$TOOL_CONTEXT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)
OPERATION=$(echo "$TOOL_CONTEXT" | grep -o '"tool":"[^"]*"' | cut -d'"' -f4)

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
BRANCH_SLUG=$(echo "$CURRENT_BRANCH" | sed 's/[^a-zA-Z0-9]/-/g')

# Check if this is a trivial file type that doesn't need planning
TRIVIAL_PATTERNS=("*.md" "*.txt" "*.json" "translations/" ".env" "package.json")
for pattern in "${TRIVIAL_PATTERNS[@]}"; do
    case "$FILE_PATH" in
        $pattern)
            echo "✅ Trivial file type, no plan required: $FILE_PATH"
            exit 0
            ;;
    esac
done

# Check for existing plans
PLAN_FILES=(
    "plans/active/${CURRENT_BRANCH}.md"
    "plans/active/${BRANCH_SLUG}.md"
    "plans/active/"*.md
)

PLAN_EXISTS=false
ACTIVE_PLAN=""

for plan_file in "${PLAN_FILES[@]}"; do
    if [[ -f "$plan_file" ]] && grep -q "Status: active" "$plan_file" 2>/dev/null; then
        PLAN_EXISTS=true
        ACTIVE_PLAN="$plan_file"
        break
    fi
done

# If no active plan found, check for draft plans
if [[ $PLAN_EXISTS == false ]]; then
    for plan_file in "${PLAN_FILES[@]}"; do
        if [[ -f "$plan_file" ]] && grep -q "Status: draft" "$plan_file" 2>/dev/null; then
            echo "📝 Found draft plan: $plan_file"
            echo "💡 Suggestion: Activate the plan before implementing"
            echo "   Change 'Status: draft' to 'Status: active' in the plan file"
            exit 1  # Warning but don't block
        fi
    done
fi

# Determine if this change requires a plan based on file patterns
REQUIRES_PLAN=false

# Check for complex file patterns that typically need planning
COMPLEX_PATTERNS=(
    "src/db/schema/"     # Database changes
    "src/app/api/"       # New API endpoints
    "src/app/\[locale\]/" # New pages
    "drizzle.config"     # Database config
    "next.config"        # App config
)

for pattern in "${COMPLEX_PATTERNS[@]}"; do
    case "$FILE_PATH" in
        *"$pattern"*)
            REQUIRES_PLAN=true
            break
            ;;
    esac
done

# Check if this is a new file creation (usually more complex)
if [[ "$OPERATION" == "Write" ]] && [[ ! -f "$FILE_PATH" ]]; then
    # Creating new files in certain directories requires planning
    case "$FILE_PATH" in
        src/components/*|src/app/*|src/api/*)
            REQUIRES_PLAN=true
            ;;
    esac
fi

# Decision logic
if [[ $REQUIRES_PLAN == true ]] && [[ $PLAN_EXISTS == false ]]; then
    echo "🚫 Plan required for complex changes"
    echo ""
    echo "This change affects: $FILE_PATH"
    echo "Operation: $OPERATION"
    echo ""
    echo "💡 Create a plan first:"
    echo "   • Use '/plan [feature-name]' command"
    echo "   • Or ask Claude to create a plan for this feature"
    echo ""
    echo "🔧 To override (use sparingly):"
    echo "   • Add '--no-plan' to your request"
    echo "   • Or use '/skip-plan' command"
    
    exit 2  # Block execution with feedback
elif [[ $PLAN_EXISTS == true ]]; then
    echo "✅ Active plan found: $(basename "$ACTIVE_PLAN")"
    exit 0  # Allow execution
else
    echo "✅ No plan required for this change"
    exit 0  # Allow execution
fi