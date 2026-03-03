#!/usr/bin/env python3
"""PostToolUse hook: auto-register GitHub Issues from planning/open_items.md.

Fires on every Write tool call. Checks if the written file is
planning/open_items.md, then creates GitHub Issues for any unregistered items.

Configuration is read dynamically:
- REPO: auto-detected via `gh repo view`
- PROJECT_NUMBER / PROJECT_OWNER: read from planning/github.md
"""
import json
import os
import re
import subprocess
import sys

TARGET_SUFFIX = "planning/open_items.md"

SECTION_LABELS = {
    "🔴": "code-fix",
    "🟡": "doc-update",
    "🔵": "monitor",
}


def read_stdin_file_path() -> str:
    """Parse file_path from PostToolUse JSON on stdin."""
    try:
        data = json.load(sys.stdin)
        return data.get("tool_input", {}).get("file_path", "")
    except (json.JSONDecodeError, KeyError):
        return ""


def detect_repo() -> str:
    """Auto-detect GitHub repo from gh CLI."""
    result = subprocess.run(
        ["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"],
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        return result.stdout.strip()
    return ""


def read_github_config() -> tuple[str, str]:
    """Read PROJECT_NUMBER and PROJECT_OWNER from planning/github.md.

    Returns (project_number, project_owner). Falls back to empty strings.
    Looks for lines like:
      - Project number: 2
      - Owner: shotaseike
    """
    github_md = "planning/github.md"
    if not os.path.isfile(github_md):
        return "", ""
    with open(github_md, encoding="utf-8") as f:
        content = f.read()
    number_match = re.search(r"[Pp]roject[^\d]*(\d+)", content)
    owner_match = re.search(r"[Oo]wner[:\s]+([A-Za-z0-9_-]+)", content)
    project_number = number_match.group(1) if number_match else ""
    project_owner = owner_match.group(1) if owner_match else ""
    return project_number, project_owner


def parse_resolved_ids(content: str) -> set:
    """Extract ITEM-IDs from the ✅ resolved section."""
    resolved = set()
    match = re.search(r"## ✅.*?(?=\n## |\Z)", content, re.DOTALL)
    if match:
        resolved = set(re.findall(r"### \[([A-Z][A-Z0-9_]*(?:-[A-Z][A-Z0-9_]*)*-\d+)\]", match.group()))
    return resolved


def parse_active_items(content: str, resolved_ids: set) -> list:
    """Return list of (item_id, title, label, body_block) for non-resolved items."""
    items = []
    sections = re.split(r"(?=\n## )", "\n" + content)
    for section in sections:
        header_match = re.match(r"\n## ([🔴🟡🔵✅])", section)
        if not header_match:
            continue
        emoji = header_match.group(1)
        if emoji == "✅":
            continue
        label = SECTION_LABELS.get(emoji)
        if not label:
            continue
        for m in re.finditer(
            r"### \[([A-Z][A-Z0-9_]*(?:-[A-Z][A-Z0-9_]*)*-\d+)\]\s+(.+?)\n(.*?)(?=\n### |\n## |\Z)",
            section,
            re.DOTALL,
        ):
            item_id = m.group(1)
            title = m.group(2).strip()
            body_block = m.group(3).strip()
            if item_id in resolved_ids:
                continue
            items.append((item_id, title, label, body_block))
    return items


def issue_exists(item_id: str, repo: str) -> bool:
    """Return True if a GitHub Issue with [ITEM-ID] already exists (open or closed)."""
    result = subprocess.run(
        [
            "gh", "issue", "list",
            "--search", f"[{item_id}] in:title",
            "--state", "all",
            "--repo", repo,
            "--json", "number,title",
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return False
    try:
        found = json.loads(result.stdout or "[]")
        return any(f"[{item_id}]" in i.get("title", "") for i in found)
    except json.JSONDecodeError:
        return False


def create_issue(item_id: str, title: str, label: str, body_block: str, repo: str) -> str | None:
    """Create a GitHub Issue and return its URL, or None on failure."""
    body = f"Source: `planning/open_items.md` item `[{item_id}]`\n\n{body_block}"
    result = subprocess.run(
        [
            "gh", "issue", "create",
            "--title", f"[{item_id}] {title}",
            "--body", body,
            "--label", label,
            "--repo", repo,
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"[auto-register] ERROR creating {item_id}: {result.stderr.strip()}", file=sys.stderr)
        return None
    return result.stdout.strip()


def add_to_project(issue_url: str, project_number: str, project_owner: str) -> None:
    """Add an Issue to GitHub Project (non-fatal if it fails)."""
    if not project_number or not project_owner:
        return
    result = subprocess.run(
        [
            "gh", "project", "item-add", project_number,
            "--owner", project_owner,
            "--url", issue_url,
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"[auto-register] WARNING: Failed to add {issue_url} to project: {result.stderr.strip()}", file=sys.stderr)


def main() -> None:
    file_path = read_stdin_file_path()
    if not file_path.endswith(TARGET_SUFFIX):
        return

    if not os.path.isfile(file_path):
        return

    repo = detect_repo()
    if not repo:
        print("[auto-register] WARNING: Could not detect GitHub repo. Skipping.", file=sys.stderr)
        return

    project_number, project_owner = read_github_config()

    with open(file_path, encoding="utf-8") as f:
        content = f.read()

    resolved_ids = parse_resolved_ids(content)
    active_items = parse_active_items(content, resolved_ids)

    new_issues: list[tuple[str, str]] = []

    for item_id, title, label, body_block in active_items:
        if issue_exists(item_id, repo):
            continue
        url = create_issue(item_id, title, label, body_block, repo)
        if url:
            add_to_project(url, project_number, project_owner)
            new_issues.append((item_id, url))

    if new_issues:
        print(f"[auto-register] {len(new_issues)} 件の GitHub Issue を自動登録しました:")
        for item_id, url in new_issues:
            print(f"  [{item_id}] {url}")


if __name__ == "__main__":
    main()
