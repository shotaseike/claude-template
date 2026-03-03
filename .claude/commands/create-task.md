Create a GitHub Issue from a planning/open_items.md entry and add it to the Project.

Arguments: <ITEM-ID> (e.g. DOC-1, EXT-2)

Steps:
1. Detect the GitHub repository: run `gh repo view --json nameWithOwner -q .nameWithOwner` to get REPO
2. Read `planning/github.md` to get PROJECT-NUMBER and PROJECT-OWNER
3. Read planning/open_items.md and extract the entry for ITEM-ID (title, description, and action items)
4. Determine the label from the section header: red circle -> code-fix / yellow circle -> doc-update / blue circle -> monitor
5. Check for duplicate: Run `gh issue list --search "[ITEM-ID]" --repo REPO` to verify no existing Issue with this ITEM-ID. If found, report to user and stop (do not create).
6. Format the issue body using the extracted content (Purpose, Target files, Steps, Completion criteria, Source: ITEM-ID)
7. Run: gh issue create --title "[ITEM-ID] <title>" --body "<formatted body>" --label <label> --repo REPO
8. Run: gh project item-add PROJECT-NUMBER --owner PROJECT-OWNER --url <ISSUE-URL> (REQUIRED: do not skip)
9. Verify Issue is added to Project: `gh issue view <NUMBER> --json projectItems` should show the project
10. Report the Issue URL and number to the user in Japanese
