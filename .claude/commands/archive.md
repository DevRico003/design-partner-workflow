Archive completed or abandoned development plans to keep the workspace clean.

When the user says "/archive $ARGUMENTS", you should:

1. **Identify the plan**: Find the plan file matching $ARGUMENTS
2. **Validate status**: Ensure plan is ready for archiving (completed, abandoned, or old draft)
3. **Create archive structure**: Set up appropriate directory in `/plans/archive/`
4. **Move and update**: Transfer plan and update its status to "archived"
5. **Update index**: Refresh `/plans/INDEX.md` to reflect changes
6. **Confirm action**: Show what was archived and where

## Archive Structure
```
/plans/archive/
├── 2024/
│   ├── q4/
│   │   ├── completed/
│   │   │   └── feature-name.md
│   │   └── abandoned/
│   │       └── old-draft.md
│   └── q3/
└── 2025/
    └── q1/
```

## Archival Rules
- **Completed plans**: Move to `archive/YYYY/qN/completed/`
- **Abandoned plans**: Move to `archive/YYYY/qN/abandoned/`
- **Old drafts**: Plans with "Status: draft" older than 30 days
- **Preserve history**: Keep original creation date and metadata

## Status Updates
When archiving, update the plan file:
```markdown
- **Status**: archived
- **Archived**: 2024-12-23
- **Archived By**: [User/System]
- **Archive Reason**: completed | abandoned | stale_draft
```

## Example Response
```
Archiving plan: recurring-bookings.md

✅ Plan archived successfully:
   From: /plans/active/recurring-bookings.md
   To: /plans/archive/2024/q4/completed/recurring-bookings.md
   
📊 Archive Summary:
   • Status: completed → archived
   • Duration: 5 days (Dec 18 - Dec 23)
   • Completion: 100% (12/12 tasks)
   
🧹 Workspace cleaned:
   • Active plans: 2 → 1
   • Ready to focus on remaining work
```

## Arguments
- `[plan-name]`: Archive specific plan by name
- `completed`: Archive all completed plans  
- `old`: Archive drafts older than 30 days
- `abandoned`: Archive manually abandoned plans
- `all-completed`: Bulk archive all completed plans

## Safety Checks
- Confirm before archiving active plans
- Warn if archiving plan with < 80% completion
- Show what will be archived before moving files
- Create backup before moving files

## Bulk Operations
For bulk archiving:
1. List all candidates for archiving
2. Ask for confirmation
3. Process each plan individually
4. Show summary of all archived plans
5. Update INDEX.md with cleaned state

## Recovery
- Archived plans can be restored by moving back to `/plans/active/`
- Change status from "archived" to "active" or "draft"
- Explain recovery process if user asks

## After Archiving
- Update `/plans/INDEX.md`
- Clean up empty directories
- Show remaining active plans
- Suggest next steps for development focus