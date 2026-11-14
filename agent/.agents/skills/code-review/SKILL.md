---
name: code-review
description: "Review and publish inline feedback on a GitLab merge request."
argument-hint: "Merge request ID"
---

# GitLab Merge Request Code Review

Review the specified merge request and publish substantiated inline findings. This skill runs in CI/CD, so always publish the review; do not ask for confirmation.

## Workflow

1. Confirm the repository and merge request ID. Check for local changes and do not overwrite or discard them. Confirm the checked-out branch and commit match the merge request source branch and head; stop if they do not match.
2. Read the MR metadata with `glab mr view <id>` and inspect its diff with `glab mr diff <id> --color never`. Compare against the target branch and inspect relevant callers, contracts, and tests. Ignore generated or lockfile churn unless it contains a concrete defect.
3. Report only substantiated correctness, data-loss, authorization, or runtime problems. Keep findings independent, prioritize by severity, and anchor each to a changed line.
4. Fetch MR diff-version metadata with the skill helper:

   ```sh
   scripts/gitlab-mr-api.sh versions <id>
   ```

   Use the current version's `base_commit_sha`, `start_commit_sha`, and `head_commit_sha` in discussion positions. Confirm the head SHA still matches the reviewed revision; if it changed, re-review affected lines and update findings.
5. Check existing discussions to avoid duplicates:

   ```sh
   scripts/gitlab-mr-api.sh discussions <id>
   ```

   Publish findings sequentially as inline discussions, never as general MR notes. Use `jq` to build each discussion JSON safely, then pipe it to the helper:

   ```sh
   jq -n ... | scripts/gitlab-mr-api.sh publish <id>
   ```

   Each body should include a severity label and each position should include `position_type: "text"`, the three version SHAs, matching `old_path` and `new_path`, and the changed `new_line`. The helper validates request and response shapes and fails unless GitLab returns a non-empty discussion `id`. Do not call the GitLab API directly.

## Comment Quality

- Write concise comments in Polish unless another language is requested. State the condition, concrete impact, and smallest corrective direction.
- Use `[P1]` for severe functional, security, or data-loss impact; `[P2]` for substantial narrower defects; `[P3]` for lower-impact defects. Report only issues supported by evidence.
- Never include credentials, tokens, or other secrets.

## Failure Handling

Stop and report failures. If the MR head changed, or a line position is unsupported, re-review or stop rather than publishing stale or unanchored feedback.
