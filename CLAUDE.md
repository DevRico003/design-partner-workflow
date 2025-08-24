# DESIGN PARTNER WORKFLOW

## Overview

This project uses the **Design Partner Workflow** - a systematic approach that transforms Claude from a simple code generator into a collaborative design partner. This system enforces planning, maintains documentation, and ensures quality through automated hooks.

📖 **Full Documentation**: See `DESIGN_PARTNER_WORKFLOW.md` for complete guide.

## Quick Reference

### Complexity Levels & Planning Requirements

| Level | Files | Lines | Duration | Plan Required | Example |
|-------|-------|-------|----------|---------------|---------|
| **Trivial** | <2 | <50 | <30min | ❌ No | Typos, colors, translations |
| **Small** | <5 | <200 | <2h | 📝 Mini | New buttons, simple endpoints |
| **Medium** | <10 | <500 | <1d | ✅ Yes | Components, integrations |
| **Large** | <20 | <1000 | <3d | ✅ Yes + Review | Features, migrations |
| **Epic** | >20 | >1000 | >3d | 🔄 Break down | Platform changes |

### Essential Commands

```bash
/plan [feature-name]     # Create feature plan  
/plans                   # List all active plans
/status                  # Show progress summary
/archive [plan-name]     # Archive completed plan
```

### Hook System (Automatic)

- **UserPromptSubmit**: Analyzes complexity, suggests planning approach
- **PreToolUse**: Blocks complex changes without plans 
- **PostToolUse**: Updates plans with implementation notes
- **SessionStart**: Loads relevant plan context
- **Stop**: Shows progress and next steps

### Directory Structure

```
.claude/                    # Claude Code configuration
├── settings.json          # Hook configuration  
├── hooks/                 # Automation scripts
├── commands/              # Custom slash commands
└── scripts/               # Maintenance utilities

plans/                     # Development plans
├── .template.md          # Plan template
├── INDEX.md              # Quick navigation
├── active/               # Current development
├── completed/            # Recently finished  
└── archive/              # Historical record
```

### Workflow Examples

#### New Feature (Medium/Large)
```
You: "Add pet vaccination tracking"
Claude: "Creating plan for this medium complexity feature..."
[Creates: plans/active/pet-vaccination-tracking.md]
Claude: "Plan ready for review. Proceed with implementation?"
You: "Yes, start with database schema"
[Implementation begins with automatic plan updates]
```

#### Quick Fix (Trivial)  
```
You: "Fix typo in booking confirmation email"
Claude: [Implements directly - no plan needed]
```

#### Continuing Work
```
You: "Continue with vaccination feature"  
Claude: [Loads plan context automatically]
Claude: "Resuming Phase 2: API endpoints (60% complete)"
```

### Best Practices

#### DO ✅
- Review plans before implementing
- Work on one plan at a time
- Mark completed checklist items
- Archive finished plans regularly
- Use hooks guidance - they prevent problems

#### DON'T ❌
- Skip plans for complex features (hooks will block)
- Leave plans in draft forever  
- Ignore hook warnings
- Create multiple plans for one feature
- Delete plans (archive instead)

### Maintenance

```bash
# Weekly cleanup (recommended)
./.claude/scripts/archive-plans.sh

# Health check
./.claude/scripts/search-plans.sh --health

# Find plans by keyword
./.claude/scripts/search-plans.sh -k "authentication"
```

### Plan Override (Emergency Only)
```bash
/skip-plan              # Override plan requirement once
--no-plan              # Add to request to bypass
```

**Note**: The Design Partner system is active and will guide development. For complete workflow details, troubleshooting, and team collaboration guidance, see `DESIGN_PARTNER_WORKFLOW.md`.