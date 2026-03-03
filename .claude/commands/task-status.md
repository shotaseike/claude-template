Update a GitHub Issue status on GitHub Projects.

Arguments: <ITEM-ID> <status> (status: in_progress | review | done | pending)

Steps:
1. Detect the GitHub repository: run `gh repo view --json nameWithOwner -q .nameWithOwner` to get REPO
2. Read `planning/github.md` to get PROJECT-NUMBER and PROJECT-OWNER (for the Projects board URL)
3. Run: gh issue list --search "[ITEM-ID]" --json number,title --repo REPO to find the Issue number
4. Apply status change based on status type:
   - done: Run `gh issue close <NUMBER> --repo REPO` (Projects auto-moves to Done via automation rule)
   - pending: Run `gh issue reopen <NUMBER> --repo REPO` (Projects auto-moves to Backlog via automation rule if available)
   - in_progress or review: Report to user that manual update is required on GitHub Projects UI (or provide direct URL using PROJECT-OWNER and PROJECT-NUMBER)
5. Report the status change result to the user in Japanese

Note: GitHub CLI does not support direct Project column status updates for non-close/reopen actions. Automation rules handle done/pending via issue close/reopen. For in_progress and review, drag the Issue card on the Project board UI.
