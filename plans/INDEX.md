# Development Plans Index

## Active Development Plans

### High Priority
*No active plans currently*

### Medium Priority
*No active plans currently*

### Low Priority / Draft
*No active plans currently*

## Recently Completed (Last 30 Days)
*No completed plans currently*

## Quick Actions

### Commands
- `/plan [feature-name]` - Create new feature plan
- `/plans` - List all active plans
- `/archive [plan-name]` - Archive completed plan
- `/status` - Show current plan progress

### Useful Scripts
```bash
# Archive old completed plans (run monthly)
./scripts/archive-plans.sh

# Find plans by keyword
grep -r "keyword" plans/active/

# View plan template
cat plans/.template.md
```

### Plan Status Guide
- **draft**: Plan created but not yet approved/started
- **active**: Currently being implemented
- **completed**: Implementation finished, ready for archive
- **archived**: Historical record, moved to archive/

### Complexity Levels
- **trivial**: < 2 files, < 50 lines (no plan needed)
- **small**: < 5 files, < 200 lines (mini-plan in response)
- **medium**: < 10 files, < 500 lines (plan required)
- **large**: < 20 files, < 1000 lines (plan + review required)
- **epic**: > 20 files, > 1000 lines (break down into smaller plans)

---

*This index is automatically updated by the Design Partner Workflow system*