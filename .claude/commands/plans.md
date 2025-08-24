List and manage all development plans in the project.

When the user says "/plans" or "/plans $ARGUMENTS", you should:

1. **Show active plans**: List all plans with "Status: active" in `/plans/active/`
2. **Show draft plans**: List plans with "Status: draft" 
3. **Show recent activity**: Plans modified in last 7-14 days
4. **Display progress**: Show completion percentage for each plan
5. **Suggest next actions**: Recommend what to work on next

## Display Format
```
📋 Active Plans (2)
├─ recurring-bookings.md (75% complete) - Created: 2024-12-20
│  Next: Implement error handling, Add unit tests
├─ email-notifications.md (25% complete) - Created: 2024-12-22
│  Next: Create email templates, Set up SMTP configuration

📄 Draft Plans (1)
├─ payment-integration.md - Created: 2024-12-19
│  Status: Waiting for approval

🗂️ Recently Completed (1)
├─ pet-photo-upload.md - Completed: 2024-12-18
│  Ready for archiving

💡 Suggestions:
• Continue with recurring-bookings.md (nearly done!)
• Review and activate payment-integration.md draft
• Archive completed pet-photo-upload.md
```

## Arguments
- No arguments: Show all plans overview
- `active`: Show only active plans with detailed progress  
- `draft`: Show only draft plans awaiting approval
- `recent`: Show recent activity (last 30 days)
- `completed`: Show completed plans ready for archiving

## Progress Calculation
- Count total checkboxes: `- [ ]` and `- [x]`
- Calculate percentage: (completed / total) * 100
- Show visual progress bar for active plans
- Highlight next 2-3 pending tasks

## Interactive Elements
After showing plans, offer these options:
- "Which plan should we work on?" 
- "Show me the next step for [plan-name]"
- "Create a new plan with `/plan [feature-name]`"
- "Archive completed plans with `/archive [plan-name]`"

## Branch Context
- Highlight plans matching current git branch
- Show if current branch has no associated plan
- Suggest creating branch-specific plan if on feature branch

## Special Cases
- Empty state: Guide user to create first plan
- Too many plans: Suggest archiving completed ones
- Stale drafts: Identify old draft plans (>14 days) for cleanup