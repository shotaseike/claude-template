Review all pending changes for errors, then commit and push to the remote repository.
If on a task branch (task/<ITEM-ID>-<person>), also create a pull request to main, close the associated GitHub Issue, and update GitHub Projects Board status to Done automatically.

Steps:
1. Detect the GitHub repository: run `gh repo view --json nameWithOwner -q .nameWithOwner` to get REPO (e.g. "owner/repo-name")
2. Read `planning/github.md` to find the Project number (PROJECT-NUMBER) and project owner (PROJECT-OWNER)
3. Run `git status` and `git diff` to understand what has changed
4. Review each changed file for errors or inconsistencies (broken links, outdated references, etc.)
5. Report any issues found to the user before proceeding
6. Stage all relevant files (exclude binaries, cache files, secrets)
7. Commit with a descriptive message in Japanese following the format: `<type>: <summary>`
8. Push to the current branch (task branch → that branch; main → origin main)
9. If push fails due to authentication, explain how to fix it without retrying automatically
10. After successful push, run `git branch --show-current` to check branch name:
    - If branch matches pattern `task/<ITEM-ID>-<person>` (e.g., `task/DOC-2-seike`):
      a. Extract ITEM-ID (e.g., `DOC-2`)
      b. Find Issue number: `gh issue list --search "[ITEM-ID]" --json number,title --repo REPO`
      c. Create pull request to main:
         - Get Issue title from the search result (step 10b)
         - Command: `gh pr create --base=main --title="<Issue Title>" --body="Closes #<NUMBER>" --repo REPO`
         - PR title: Use the exact Issue title
         - PR body: "Closes #<NUMBER>" to auto-link the Issue
      d. Close Issue: `gh issue close <NUMBER> --repo REPO`
      e. Update GitHub Projects Board status to Done via GraphQL:
         1. Get project node ID: `gh api graphql -f query='{user(login:"PROJECT-OWNER"){projectV2(number:PROJECT-NUMBER){id}}}'`
         2. Get Status field ID and Done option ID: `gh api graphql -f query='{user(login:"PROJECT-OWNER"){projectV2(number:PROJECT-NUMBER){fields(first:20){nodes{...on ProjectV2SingleSelectField{id,name,options{id,name}}}}}}}' ` — find the "Status" field and its "Done" option ID
         3. Get item ID in project for this issue: `gh api graphql -f query='query{repository(owner:"PROJECT-OWNER",name:"REPO-NAME"){issue(number:<NUMBER>){projectItems(first:5){nodes{id,project{number}}}}}}'` — use the item whose project number is PROJECT-NUMBER
         4. Update status to Done: `gh api graphql -f query='mutation{updateProjectV2ItemFieldValue(input:{projectId:"<PROJECT_NODE_ID>",itemId:"<ITEM_ID>",fieldId:"<FIELD_ID>",value:{singleSelectOptionId:"<DONE_OPTION_ID>"}}){projectV2Item{id}}}'`
      f. Report in Japanese: PR created (with URL) + Issue closed + Projects Board status updated to Done
    - If not on a task branch, skip step 10 and report push completion in Japanese
