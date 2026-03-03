Migrate this repository from Cursor to Claude Code.

## What this skill does

Performs all steps needed to migrate a project that was set up for Cursor AI IDE to Claude Code. Run this when a repo has `.cursor/mcp.json` or other Cursor-specific configuration that needs to be replaced.

## Steps

1. **Audit current state**
   - Run `git status` to see current state
   - Check for `.cursor/` directory and its contents
   - Check `.gitignore` for Cursor-related entries
   - Check any scripts that reference `.cursor/` paths
   - Check `README.md` and other docs for Cursor references

2. **Create `.mcp.json` at project root**
   - Copy content from `.cursor/mcp.json` (if it exists) as the base
   - Place at `.mcp.json` (project root) — this is the Claude Code MCP config location
   - Make it git-tracked (do NOT add to `.gitignore`) so it's shared with the team via Dev Container

   Example structure:
   ```json
   {
     "mcpServers": {
       "bigquery": {
         "command": "npx",
         "args": ["-y", "@toolbox-sdk/server", "--prebuilt", "bigquery", "--stdio"],
         "env": {
           "BIGQUERY_PROJECT": "principle-c"
         }
       }
     }
   }
   ```

3. **Update `.gitignore`**
   - Remove entries for `.cursor/mcp.json` and `.cursor/mcp.json.example`
   - Add `.cursor/` (entire directory) to ignore
   - If `*.json` is ignored, add `!.mcp.json` exception to allow tracking
   - Add `.mcp.json.backup` to ignore (runtime artifact from switch scripts)
   - Add `__pycache__/` and `*.pyc` if not already present

4. **Update any switch/config scripts**
   - Find scripts (e.g., `scripts/switch_mcp_config.ps1`) that reference `.cursor/mcp.json`
   - Update paths to use `.mcp.json` and `.mcp.json.backup` instead
   - Update any user-facing messages from "restart Cursor" to "restart Claude Code"

5. **Update documentation**
   - Search all `.md` files for "Cursor" references: `grep -r "Cursor" --include="*.md" .`
   - Update `README.md`:
     - Directory structure: remove `.cursor/` block, add `.mcp.json` entry
     - Prerequisites: replace Cursor with Claude Code
     - Setup steps: remove `.cursor/mcp.json` creation, reference `.mcp.json`
     - Usage examples: update headers and instructions
     - Troubleshooting: update file paths
     - References: replace Cursor docs URLs with Claude Code docs URLs
   - Update any other docs that reference Cursor

6. **Remove `.cursor/` directory**
   - If `.cursor/mcp.json` or `.cursor/mcp.json.example` were tracked by git, run `git rm` on them
   - After `git rm`, the directory can be deleted (or left for `.gitignore` to handle)

7. **Create Claude Code slash commands (optional)**
   - Create `.claude/commands/push.md` for a `/push` command:
     - Steps: git status/diff → review for errors → stage → commit with Japanese message → push
   - Or use the new skills format: `.claude/skills/<skill-name>/SKILL.md`

8. **Update Dev Container (if applicable)**
   - Add GitHub CLI to `Dockerfile` so `gh auth login` is available after container rebuild
   - Add Claude Code CLI if desired: `RUN npm install -g @anthropic-ai/claude-code`
   - Note: after container rebuild, users must run `gh auth login` again (auth stored in `~/.config/gh/`)

9. **Create `CLAUDE.md`** (if not present)
   - Run `/init` to have Claude Code generate a project-specific CLAUDE.md
   - Add communication style preference: respond to user in Japanese, keep code/files in English

10. **Verify and commit**
    - Run `git status` to confirm all changes are staged correctly
    - Check no secrets (`.env`, credentials) are being committed
    - Commit with descriptive message, push to origin

## Key differences: Cursor vs Claude Code

| Item | Cursor | Claude Code |
|------|--------|-------------|
| MCP config (project) | `.cursor/mcp.json` | `.mcp.json` (project root) |
| MCP config (global) | `~/.cursor/mcp.json` | `~/.claude.json` (mcpServers section) |
| Slash commands | N/A | `.claude/commands/<name>.md` or `.claude/skills/<name>/SKILL.md` |
| Project instructions | `.cursorrules` | `CLAUDE.md` |
| IDE | Cursor app | `claude` CLI or VSCode extension |

## Notes

- `.mcp.json` should be git-tracked if you want to share MCP config with teammates via Dev Container
- GitHub authentication (`gh auth login`) must be repeated after each Dev Container rebuild — this is by design
- The warning `'C:\Program Files\GitHub CLI\gh.exe': not found` when pushing from WSL is harmless; it means Windows gh.exe is not visible from Linux, but Linux gh handles auth fine
