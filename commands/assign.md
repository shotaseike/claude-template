Assign a GitHub Issue to a team member and create a task branch.

Arguments: <ITEM-ID> <person> (e.g. DOC-1 seike)

Steps:
1. Detect the GitHub repository: run `gh repo view --json nameWithOwner -q .nameWithOwner` to get REPO
2. Run: gh issue list --search "[ITEM-ID]" --json number,title --repo REPO to find the Issue number (if multiple results, use the most recent one)
3. Run: gh issue edit <NUMBER> --add-assignee <person> --repo REPO
4. Run: git checkout -b task/<ITEM-ID>-<person> (if branch exists, run: git checkout task/<ITEM-ID>-<person>)
5. Run: git push -u origin task/<ITEM-ID>-<person>
6. Report the assigned Issue URL and branch name to the user in Japanese
