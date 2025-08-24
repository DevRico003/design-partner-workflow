Show detailed progress status for active development plans and current project state.

When the user says "/status" or "/status $ARGUMENTS", you should:

1. **Show current context**: Current branch, active plans, recent activity
2. **Display detailed progress**: Task completion, time estimates, blocking issues
3. **Highlight next actions**: What should be worked on next
4. **Show health metrics**: Plan age, completion velocity, potential issues
5. **Provide actionable recommendations**: Clear next steps

## Default Status Display
```
🎯 Current Status - Branch: feature/recurring-bookings
══════════════════════════════════════════════════════

📋 Active Plans (1)
┌─ Recurring Bookings System
├─ Progress: ████████░░ 80% (8/10 tasks)
├─ Created: 2024-12-20 (3 days ago)
├─ Complexity: medium
├─ Est. Time: 6h total (1.5h remaining)
└─ Status: On track

🎯 Current Phase: Testing & Polish
📝 Last Update: 2 hours ago
⚡ Next Tasks:
   1. Add error handling for edge cases
   2. Write integration tests for API endpoints
   
🚨 Attention Needed:
   • None - healthy progress

💡 Recommendations:
   • Focus on completing testing phase
   • Ready for review after next 2 tasks
   • Consider starting next feature plan
```

## Arguments
- No arguments: Show overview of all active work
- `[plan-name]`: Show detailed status for specific plan
- `branch`: Show status for current branch only
- `health`: Show project health metrics and potential issues
- `velocity`: Show completion velocity and time estimates

## Detailed Plan Status
When showing specific plan status:
- **Progress breakdown**: By implementation phase
- **Time tracking**: Estimated vs actual time spent
- **Dependency status**: Related tasks and blockers
- **Risk assessment**: Current risks and mitigation status
- **Recent activity**: Last 3-5 implementation updates

## Health Metrics
```
📊 Project Health Metrics
├─ Active Plans: 2 (optimal: 1-3)
├─ Avg Plan Age: 4.5 days (good: <7 days)
├─ Completion Rate: 75% (good: >70%)
├─ Stale Plans: 0 (excellent)
└─ Overall Health: 🟢 Healthy
```

## Warning Indicators
Show warnings for:
- Plans active for >14 days without completion
- Plans with 0% progress for >3 days  
- More than 5 active plans simultaneously
- Draft plans older than 7 days
- High-risk items without mitigation

## Velocity Tracking
```
⚡ Development Velocity
├─ Tasks/Day: 2.5 (last 7 days)
├─ Est. Completion: Dec 25 (in 2 days)
├─ Trend: ↗️ Accelerating
└─ Confidence: High (80%)
```

## Branch Context
- Show if current branch has associated plan
- Display branch-specific progress
- Suggest creating plan for feature branches
- Show commit activity correlation with plan progress

## Interactive Follow-ups
After showing status, offer:
- "Show me the next step to work on"
- "What's blocking progress on [plan-name]?"
- "How can I speed up completion?"
- "Should we break down any large tasks?"

## Integration with Git
- Correlate commits with plan progress
- Show if branch is ahead/behind main
- Indicate if branch is ready for PR
- Display commit activity vs plan updates