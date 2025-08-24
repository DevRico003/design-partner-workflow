# Design Partner Workflow

A structured development workflow system that helps you plan, implement, and track feature development with intelligent task management and progress monitoring.

## Quick Start

### 1. Initialize Your First Plan
```bash
# Create a plan for a new feature
/plan user-authentication

# Or ask for help creating a plan
"Create a plan for implementing user login functionality"
```

### 2. Check Your Progress
```bash
# View all active plans
/plans

# Check detailed status
/status

# See what to work on next
"What should I work on next?"
```

### 3. Archive Completed Work
```bash
# Archive a completed plan
/archive user-authentication

# Archive all completed plans
/archive completed
```

## Features

- **Smart Planning**: Automatically suggests when complex changes need planning
- **Progress Tracking**: Visual progress bars and completion percentages  
- **Branch Integration**: Plans automatically associate with git branches
- **Task Classification**: Intelligently categorizes work complexity
- **Organized Archives**: Keeps completed work organized by date and status

## Workflow Overview

1. **Plan** → Create structured plans for medium-to-large features
2. **Implement** → Build features step-by-step with automatic progress tracking
3. **Track** → Monitor completion and get suggestions for next steps
4. **Archive** → Keep workspace clean by archiving completed work

## Plan Structure

Plans include:
- **Implementation phases** with clear tasks
- **Time estimates** and complexity assessment
- **Risk identification** and mitigation strategies
- **Automatic progress tracking** as you work

## How It Works

### Task Complexity Classification
The system automatically analyzes your requests and suggests the appropriate planning approach:

| Level | Criteria | Plan Required | Example |
|-------|----------|---------------|---------|
| **Trivial** | < 2 files, < 50 lines, < 30min | ❌ No | Fix typo, change color, add translation |
| **Small** | < 5 files, < 200 lines, < 2h | 📝 Mini-plan | Add button, new form field, simple endpoint |
| **Medium** | < 10 files, < 500 lines, < 1 day | ✅ Yes | New component, integration, refactoring |
| **Large** | < 20 files, < 1000 lines, < 3 days | ✅ Yes + Review | New feature, migration, architecture change |

### Plan Status Workflow
Plans progress through these statuses:

1. **`draft`** → Plan created, needs review → **Change to `active` to begin work**
2. **`active`** → Currently being implemented → Continue development  
3. **`completed`** → Implementation finished → Archive the plan
4. **`archived`** → Historical record → Safe to ignore

**Important**: After creating a plan, you must manually change the status from `draft` to `active` in the plan file before implementation can begin.

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/plan [name]` | Create a new development plan | `/plan user-authentication` |
| `/plans` | List all active and recent plans | Shows progress and status |
| `/status` | Show detailed progress and next steps | Current work summary |
| `/archive [name]` | Archive completed or abandoned plans | `/archive user-auth` |

## Hooks System

The workflow uses intelligent hooks that run automatically to ensure quality:

### 🎯 Task Classification Hook
- **When**: Every time you submit a request
- **What**: Analyzes complexity and suggests planning approach
- **You see**: "Task classified as: medium - This appears to be a medium complexity task. A plan would be helpful."

### 🚦 Plan Requirement Hook  
- **When**: Before code writing/editing operations
- **What**: Ensures complex changes have associated plans
- **You see**: Either proceeds smoothly or blocks with helpful guidance

```bash
# Complex change without plan
You: "Implement payment processing"
System: "🚫 Plan required for complex changes. Use '/plan payment-processing'"

# Simple change  
You: "Fix button color"
System: "✅ No plan required for this change" (proceeds directly)
```

### 📝 Plan Update Hook
- **When**: After code modifications
- **What**: Automatically updates plans with implementation notes
- **You see**: "✅ Plan updated: user-auth.md - Progress: 5/8 tasks complete"

### 🏁 Progress Display Hook
- **When**: After completing responses
- **What**: Shows current progress and suggests next steps
- **You see**: Progress bars, completion percentages, and next task suggestions

### 🚀 Context Loading Hook
- **When**: Starting new sessions
- **What**: Loads relevant active plans for context
- **You see**: Summary of current work and active plans

## Scripts

The system includes helpful maintenance scripts:

| Script | Purpose | Usage |
|--------|---------|-------|
| `archive-plans.sh` | Bulk archive completed plans | Keeps workspace clean |
| `search-plans.sh` | Find plans by content or status | Locate specific plans quickly |

## Working with Plans

### Creating a Plan
```bash
# Automatic (recommended)
"Implement user authentication with social login"
# System detects complexity and creates plan automatically

# Manual  
/plan user-authentication
# Creates plan template for you to customize
```

### Activating a Plan
**Critical Step**: After plan creation, you must activate it:

1. Open the plan file in `plans/active/your-plan.md`
2. Change `Status: draft` to `Status: active`
3. Save the file
4. Now implementation can begin

### Monitoring Progress
```bash
/status              # Detailed progress view
/plans active        # Only active plans
/plans              # All plans overview
```

## File Structure

```
.claude/
├── settings.json           # Main configuration
├── hooks/                  # Automatic workflow enforcement
│   ├── classify-task.sh    # Complexity analysis
│   ├── check-plan-requirement.sh  # Plan enforcement
│   ├── update-plan.sh      # Auto-documentation
│   ├── load-context.sh     # Session initialization
│   └── show-progress.sh    # Progress tracking
├── commands/               # Custom slash commands
│   ├── plan.md            # /plan command definition
│   ├── plans.md           # /plans command definition
│   ├── archive.md         # /archive command definition
│   └── status.md          # /status command definition
└── scripts/               # Maintenance utilities
    ├── archive-plans.sh   # Bulk archiving
    └── search-plans.sh    # Plan search

plans/
├── .template.md           # Plan template structure
├── INDEX.md              # Quick navigation overview
├── active/               # Current development plans
├── completed/            # Finished plans ready for archiving
└── archive/              # Historical completed/abandoned plans
    └── 2024/q4/         # Organized by date
```

## Best Practices

### ✅ DO
- **Review plans before starting** - Plans are your implementation contract
- **Change status from draft to active** - Required for implementation to begin  
- **Work on one plan at a time** - Focus leads to quality
- **Archive completed plans** - Keep workspace clean
- **Trust the hooks** - They prevent quality issues

### ❌ DON'T  
- **Skip plans for complex features** - Hooks will block you anyway
- **Leave plans in draft forever** - Activate or archive them
- **Override plan requirements casually** - Use bypass sparingly
- **Delete plans** - Archive instead to preserve history

## Getting Help

- Ask "What should I work on next?" for guidance
- Use `/status` to see detailed progress  
- Ask "Create a plan for [feature]" to start planning
- Remember to change plan status from `draft` to `active`
- Small changes (< 5 files) don't need full plans

Start with `/plan [your-feature-name]` to create your first structured development plan!