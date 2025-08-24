Create or update a feature plan for development work.

When the user says "/plan $ARGUMENTS", you should:

1. **Analyze the request**: Parse $ARGUMENTS to understand what feature/task needs planning
2. **Determine complexity**: Assess if this needs a full plan, mini-plan, or no plan
3. **Create the plan**: Use the template from `/plans/.template.md`
4. **Set up the file**: Save to `/plans/active/[feature-name].md` with appropriate filename
5. **Fill in details**: Complete as much of the template as possible based on the request
6. **Set status to draft**: Mark as "Status: draft" until user approves

## Template Usage
- Copy the structure from `/plans/.template.md`
- Replace all `[placeholders]` with actual content
- Fill in metadata (created date, complexity, branch name)
- Create actionable implementation steps
- Include realistic time estimates
- Add appropriate risk assessment

## Filename Convention
- Use lowercase with hyphens: `feature-name.md`
- Match git branch name if possible: `feature/user-profile` → `user-profile.md`
- Keep names descriptive but concise

## Example Response Pattern
```
I'll create a plan for [feature name]. This appears to be [complexity level] complexity.

Creating plan: /plans/active/feature-name.md

[Show key sections of the plan you created]

The plan is ready for review. Key points:
- Estimated duration: [time estimate]  
- Main components: [list key components]
- Potential risks: [mention any risks]

Please review the plan and let me know if you'd like any adjustments before we mark it as active and begin implementation.
```

## After Plan Creation
- Ask user to review the plan
- Wait for approval before changing status from "draft" to "active"
- Offer to start implementation once approved
- Update the `/plans/INDEX.md` file to reflect the new plan

## Special Cases
- If plan already exists: Ask if user wants to update it
- If request is too small for a plan: Suggest a mini-plan approach instead
- If request is too large: Suggest breaking it into smaller plans