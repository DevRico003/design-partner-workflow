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

## Commands

| Command | Description |
|---------|-------------|
| `/plan [name]` | Create a new development plan |
| `/plans` | List all active and recent plans |
| `/status` | Show detailed progress and next steps |
| `/archive [name]` | Archive completed or abandoned plans |

## Smart Features

- **Complexity Detection**: Automatically suggests planning for complex changes
- **Branch Awareness**: Plans connect to your current git branch
- **Progress Monitoring**: Real-time updates as you implement features  
- **Next Step Suggestions**: Always know what to work on next

## File Structure

```
plans/
├── active/           # Current development plans
├── completed/        # Finished plans ready for archiving
├── archive/          # Completed and abandoned plans
│   └── 2024/q4/     # Organized by date
├── .template.md      # Plan template
└── INDEX.md         # Overview of all plans
```

## Getting Help

- Ask "What should I work on next?" for guidance
- Use `/status` to see detailed progress
- Ask "Create a plan for [feature]" to start planning
- Small changes (< 5 files) don't need full plans

Start with `/plan [your-feature-name]` to create your first structured development plan!