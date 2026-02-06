# fishbc - BC Fish Codes R Package

Fork of `poissonconsulting/fishbc` for NewGraphEnvironment fish passage reporting.

## Repository Context

**Upstream:** poissonconsulting/fishbc
**Fork:** NewGraphEnvironment/fishbc
**Primary Language:** R

## Current Work

Resolving issue poissonconsulting/fishbc#13 - updating `cdc.csv` with current BC Conservation Data Centre data.

### Key Files

- `data-raw/cdc/cdc.csv` - CDC species at risk data (target for update)
- `data-raw/freshwaterfish/freshwaterfish.csv` - joins to cdc via CDCode
- `data-raw/data-raw.R` - data processing script with validation checks

### Complexity

- CDC export format changed since 2020
- Species name/code changes (e.g., Catostomus platyrhynchus → bondi)
- Subspecies/population edge cases (Arctic vs Pacific Bull Trout listings)
- Must maintain column compatibility for downstream consumers

### Reference

- Issue: poissonconsulting/fishbc#13
- Lucy's work: lucy-schick/fishbc@updated_data (R/cdc.Rmd)
- Consumer: fish_passage_template_reporting uses fishbc::cdc

---

# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
# NewGraph Environment Conventions

Core patterns for professional, efficient workflows across NewGraph repositories.

## Issue Creation Guidelines

### Professional Issue Writing

Write issues with clear technical focus:

- **Use normal technical language** in titles and descriptions
- **Focus on the problem and solution** approach
- **Avoid internal project codes or tracking references** in the main description
- **Add tracking links at the end** if needed (e.g., `Relates to Owner/repo#N`)

**Why:** Issues are read by consultants, clients, and collaborators. Keep them professional and focused on technical content.

**Example:**
```markdown
## Problem
The DEM processing pipeline is slow for large datasets.

## Proposed Solution
Add structured logging and performance benchmarking to identify bottlenecks.
```

### GitHub Issue Creation - Always Use Files

The `gh issue create` command with heredoc syntax fails repeatedly with EOF errors. ALWAYS use intermediate file approach:

```bash
# Write issue body to scratchpad file first
cat > /path/to/scratchpad/issue_body.md << 'EOF'
## Problem
...

## Proposed Solution
...
EOF

# Then create issue from file
gh issue create --title "Brief technical title" --body-file /path/to/scratchpad/issue_body.md
```

**Why:** Reliable, works every time, no syntax errors. Saves time and tokens.

## Commit Quality

Write clear, informative commit messages:

```
Brief description (50 chars or less)

Detailed explanation of changes and impact.
- What changed
- Why it changed
- Relevant context

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**When to commit:**
- Logical, atomic units of work
- Working state (tests pass)
- Clear description of changes

**What to avoid:**
- "WIP" or "temp" commits in main branch
- Combining unrelated changes
- Vague messages like "fixes" or "updates"
