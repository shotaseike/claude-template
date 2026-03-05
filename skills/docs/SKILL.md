---
name: docs
description: Analyze the codebase and update all documentation files. Auto-detects project structure, identifies outdated/missing content, and updates CLAUDE.md, README.md, and other docs with impact analysis. Use when you want to refresh project documentation.
disable-model-invocation: true
---

Analyze the codebase and update all documentation files comprehensively. Complete ALL steps in a single pass — do not stop mid-way.

## Step 0: Build documentation registry

Before analyzing code, catalog every documentation file and understand its role.

### 0a: Discover all docs using Glob
```
*.md (root level)
docs/*.md (if docs/ exists)
.claude/commands/*.md
.claude/skills/**/*.md
```

### 0b: Read each doc file and extract metadata

For each `.md` file, read the YAML frontmatter (if present) and first 60 lines to extract:
```
path          — file path relative to repo root
title         — document title (H1 heading)
audience      — who reads this: "ai-assistant" | "developer" | "ops" | "user"
trace_id      — doc-tracer identity (frontmatter: trace.id), or null if absent
declared_uses — modules declared in frontmatter (trace.uses), or [] if absent
update_rules  — constraints: e.g., "max 200 lines" for CLAUDE.md, "Japanese prose" for technical docs
```

**Frontmatter schema** (optional but improves routing accuracy — add to docs that declare code dependencies):
```yaml
---
trace:
  id: doc:path/to/doc.md          # unique ID for this document
  uses:
    - module:src/auth.py          # Python module this doc covers
    - module:src/api/users.ts     # TypeScript module
    - component:UserController    # class or component
    - env:DATABASE_URL            # environment variable
---
```

**Standard doc roles for most projects:**
| File | Audience | Purpose |
|------|----------|---------|
| `CLAUDE.md` | ai-assistant | Quick reference for Claude Code (max 200 lines) |
| `README.md` | user/developer | Getting started, features, installation |
| `docs/*.md` | developer | Technical deep-dives, architecture, API reference |
| `.claude/commands/*.md` | n/a | Claude Code command specifications (auto-read by Claude Code) |
| `.claude/skills/**/*.md` | n/a | Claude Code skill specifications (auto-read by Claude Code) |

### 0c: Build reverse lookup map (frontmatter-based impact analysis)

From all `declared_uses` entries, build:
```
module_to_docs = {
  "module:src/auth.py"       → ["docs/auth.md", "CLAUDE.md"],
  "env:DATABASE_URL"         → ["CLAUDE.md", "docs/setup.md"],
  "component:UserController" → ["docs/api.md"],
  ...
}
```

This map will be used in Step 3 to route findings to the correct docs with certainty.

Also detect:
- **Orphan docs** — `.md` files with no `trace.id` in frontmatter (will be processed in Step 0d)
- **Broken references** — `trace.uses` entries pointing to files/modules that do not exist in the codebase (report in Step 5)

Build this registry in memory for use in Steps 1–5.

### 0d: Auto-generate frontmatter for orphan docs

For every doc that has no `trace:` frontmatter, infer its dependencies by scanning the doc's full content:

**Inference rules** (apply all that match):
1. **Module references** — file paths mentioned inline (e.g. `` `src/auth.py` ``, `notion_fetch.py`) → `module:<path>`
2. **Class / function names** — capitalized identifiers or backtick-quoted names that match source files found in Step 0a (e.g. `UserController`, `safe_column_name`) → `component:<name>`
3. **Environment variables** — ALL_CAPS tokens or names in env-var lists (e.g. `DATABASE_URL`, `NOTION_TOKEN`) → `env:<NAME>`
4. **Audience inference** — use H1 heading, section names, and language style:
   - Contains "deploy", "gcloud", "Cloud Run", step-by-step commands → `ops`
   - Contains schema definitions, algorithm details, code samples → `developer`
   - Starts with "This file provides guidance to Claude Code" → `ai-assistant`
   - Otherwise → `user`

**Construct the frontmatter block** for each orphan doc:
```yaml
---
trace:
  id: doc:<path/to/doc.md>
  generated_by: skill:docs
  uses:
    - module:<inferred>
    - env:<inferred>
    ...
---
```

**Write rules:**
- If the file already has a YAML frontmatter block (`---` … `---`), insert the `trace:` key inside it (do not create a second `---` block)
- If the file has NO frontmatter, prepend the full `--- … ---` block followed by a blank line before the existing content
- Skip `.claude/commands/*.md` and `.claude/skills/**/*.md` — these have their own frontmatter schema; do not add `trace:`
- If no dependencies can be inferred (empty `uses`), still write the `trace.id` and `generated_by` — this marks the doc as "reviewed, no code deps"
- After writing, update the in-memory registry so Steps 1–5 can use the newly generated `declared_uses`

---

## Step 1: Parallel codebase exploration

Spawn multiple independent agents simultaneously. Each agent explores a different angle:

**Agent A — Project entry points & build config**
- Read: `main.py`, `__main__.py`, `cli.py`, `setup.py`, `package.json`, `Makefile`, `pyproject.toml`, `go.mod`, `Cargo.toml`
- List: All CLI commands, build targets, entry points
- Note: Language, framework, dependencies, version constraints

**Agent B — Core code structure**
- Glob: Find all source directories (`src/`, `lib/`, `app/`, module roots)
- Read: Key module files to understand purpose
- Summarize: What each module/package does, key design decisions, non-obvious behaviors

**Agent C — Environment & configuration**
- Read: `.env.example`, `config.py`, `settings.json`, `.mcp.json`, `.github/`, any `*.yml` / `*.yaml`
- List: All environment variables (required, optional, defaults)
- Note: CI/CD pipelines, deployment targets, integrations

**Agent D — Full documentation audit**
- Read: Complete content of every doc from Step 0 registry
- For each doc, list: sections that appear outdated, missing, contradicted by current code, or contain TODOs/placeholders
- Note: Broken links, references to removed features, version mismatches

**Agent E — Tests & examples**
- Read: Test files (`*_test.py`, `*.test.js`, `test_*.py`, `tests/`) and example files
- List: Tested functionality, expected usage patterns, undocumented behaviors

Collect all findings from these agents.

---

## Step 2: External documentation search

Use WebSearch to find changes relevant to this project. Search for:

1. **Language/framework updates** — e.g., "Python 3.12 changes 2025", "TypeScript 5.5 release notes", "Node.js LTS 2025"
2. **Dependency changelogs** — e.g., "Django 5.0 breaking changes", "React 19 release"
3. **API updates** — e.g., "Notion API changelog 2025", "Google Cloud APIs deprecations"
4. **Claude Code best practices** — "Claude Code CLAUDE.md 2025 best practices"

Extract only:
- Items affecting how this project should work
- Newly deprecated APIs currently in use
- New features that improve the codebase (worth documenting)

---

## Step 3: Impact analysis — route each finding to its doc

For every finding from Steps 1–2, classify as:
- **Missing** — correct information not documented anywhere
- **Outdated** — documented but no longer accurate
- **Accurate** — already correct, no change needed
- **Wrong-place** — documented in wrong file
- **Clarification-needed** — ambiguous, confusing, or incomplete explanation

### Routing priority (use highest-confidence method available):

**Method 1 — Frontmatter-based (authoritative)**: If a finding involves a module/env var/component in `module_to_docs`, route to exactly those docs. No inference needed.

```
Finding: New env var DATABASE_URL added to src/config.py
→ module_to_docs["env:DATABASE_URL"] = ["CLAUDE.md", "docs/setup.md"]
→ Route to: CLAUDE.md (Environment Setup: Missing), docs/setup.md (Config: Missing)
```

**Method 2 — LLM inference (fallback)**: For modules/components not yet covered by frontmatter, infer based on content similarity, section headings, and audience:

```
Finding: New CLI flag --verbose in cli.py (no trace.uses declared)
→ Infer: CLAUDE.md (ai-assistant audience, Common Commands section)
→ Note in report: "trace.uses not declared — routing inferred"
```

**Build a routing table:**
```
[Finding summary] → [Target doc] : [Section] : [Status] : [Routing method]
Example:
  New env var DATABASE_URL          → CLAUDE.md : Environment Setup : Missing  : frontmatter
  New env var DATABASE_URL          → docs/setup.md : Config : Missing          : frontmatter
  Undocumented CLI flag --verbose   → CLAUDE.md : Common Commands : Missing     : inferred
  Deprecated package.json field     → README.md : Installation : Outdated       : inferred
```

Include routing method in the final report so the user can see which were authoritative vs. inferred.

---

## Step 4: Update each affected doc

For each doc with at least one routed finding, apply all changes in ONE write operation.

**Constraints per doc type:**

**`CLAUDE.md`** (audience: AI assistant, max 200 lines)
- Keep prefix: `# CLAUDE.md\n\nThis file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.`
- Strict 200-line limit — remove lower-priority items if needed (commands in `--help`, details in linked docs)
- Prefer short notes over long paragraphs; link to other docs for details
- Do NOT add: generic advice, "Last Updated" section, duplicated information from README/SPEC

**`README.md`** (audience: users, getting started)
- Include: project description, features, quick-start, installation, key links
- Keep current installation/setup steps
- Link to CLAUDE.md for detailed technical info
- Add: badges, examples, troubleshooting if relevant

**`docs/*.md`** or similar (audience: developers, technical depth)
- Technical accuracy required
- Include: API reference, algorithm details, edge cases, examples
- Preserve existing prose style (English vs. Japanese)

**Skip** any doc where all findings are classified as **Accurate**.

---

## Step 5: Write planning document and report to user

### 5a: Update planning/open_items.md

Create or overwrite `planning/open_items.md` with this structure:

```markdown
---
trace:
  id: doc:planning/open_items.md
  generated_by: skill:docs
  last_updated: "YYYY-MM-DD"
---

# 未確認・要レビュー項目

`/docs` スキル実行時に自動検出された、人手での確認・対処が必要な項目。
スキル実行のたびに上書き更新される。解決済みの項目はスキルが次回実行時に削除する。

---

## 🔴 要対処（コード・設定変更が必要）

[Items requiring code/config changes. Include file path + line number, description, how to verify, how to fix, risk level.]

---

## 🟡 要更新（ドキュメント整備が必要）

[Items requiring documentation work. Include file path, description, suggested action.
Also include: orphan docs (no trace.id) and broken trace.uses references detected in Step 0.]

---

## 🔵 外部API変更（コード修正の可能性あり）

[Items from Step 2 that may require code changes. Include source, description, how to confirm, risk level.]

---

## ✅ 解決済み（次回 /docs 実行時に削除予定）

[Leave this section empty if no items were resolved since the last run. If items previously listed are now confirmed resolved, list them here briefly before removing on the next run.]

---

*このファイルは `/docs` スキルが自動生成・更新します。手動編集も可能ですが、次回の `/docs` 実行時に上書きされます。*
```

**Rules:**
- Write TODAY's date in `last_updated`
- Each item must have a unique ID like `[CODE-1]`, `[DOC-1]`, `[EXT-1]`
- Only include items that genuinely need human review; exclude things verified as correct
- If a previous item from the old file is now confirmed resolved, move it to ✅ section
- If ALL items are resolved, write "現在、未確認・要レビュー項目はありません。" in the relevant sections
- Include orphan docs (those lacking `trace.id`) under 🟡 with suggestion to add frontmatter
- Include broken `trace.uses` entries (declared module does not exist) under 🔴

### 5b: Close resolved GitHub Issues

For each item moved to the ✅ section in Step 5a, close the corresponding GitHub Issue if it is still open:

1. Detect the GitHub repository: `gh repo view --json nameWithOwner -q .nameWithOwner`
2. For each resolved item (e.g. `[DOC-1]`), run:
   ```bash
   gh issue list --repo <REPO> --search "[ITEM-ID]" --state open --json number,title
   ```
3. If an open issue is found, close it with a resolution comment:
   ```bash
   gh issue close <NUMBER> --repo <REPO> \
     --comment "<ITEM-ID> 解決済み: <解決内容の簡潔な説明>。planning/open_items.md の ✅ セクションに記録済み。"
   ```
4. If no open issue is found, skip silently.

### 5c: Report to user (in Japanese)

Output summary with these sections:

**🏷️ フロントマター自動生成**

List docs that had `trace:` frontmatter auto-generated in Step 0d:
```
✓ docs/auth.md        — trace.id 設定, uses: [module:src/auth.py, env:JWT_SECRET]
✓ docs/setup.md       — trace.id 設定, uses: [env:DATABASE_URL, env:PORT]
  README.md           — スキップ（依存関係なし、trace.id のみ設定）
```

Mention the total: "X 件のドキュメントに trace: フロントマターを自動追加しました。"
If all docs already had frontmatter, write "すべてのドキュメントに既存のフロントマターがありました。"

**📝 更新されたドキュメント**

For each doc changed, list:
- File path
- What was added/changed/removed
- Why (which findings triggered the change)
- Routing method used (frontmatter / inferred)

Example:
```
✓ CLAUDE.md
  - Environment Setup: 新しい環境変数 DATABASE_URL を追加 [frontmatter routing]
  - Common Commands: 新しい --verbose フラグを記載 [inferred routing]

✓ README.md
  - Installation セクションを Python 3.12 対応に更新 [inferred routing]
```

**📋 planning/open_items.md**

List items written to planning file, grouped by severity:
```
🔴 要対処: 2 items
  - [CODE-1] Deprecated API usage in main.py

🟡 要更新: 1 item
  - [DOC-1] docs/api.md に trace.id フロントマター未設定（影響範囲の自動検出に対応するため追加を推奨）

🔵 外部API: 0 items
```

**🔍 外部ドキュメントからの発見**

Summarize findings from Step 2:
```
- Python 3.12: f-string parsing changes (not applicable to current code)
- Django 5.0: ORM API changes (check if project uses Django)
```

**🗺️ ルーティング判断の概要**

Show the routing table from Step 3 with routing method (frontmatter / inferred) so user can follow the reasoning and identify which modules would benefit from adding `trace.uses` frontmatter.
