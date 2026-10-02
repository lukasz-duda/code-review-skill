---
name: gitlab-mr-review-notes
description: "Review GitLab merge requests from a local checkout and prepare or post precise inline review discussions with glab. Use for MR code reviews, finding bugs in changed lines, or scripting GitLab review comments."
argument-hint: "GitLab MR IID and optional review focus"
---

# GitLab MR Review Notes

Review merge request changes from the repository checkout and prepare concise, actionable, line-anchored GitLab discussions. Write review comments in Polish unless the user explicitly requests another language. Separate preparing notes from posting them: never post comments unless the user explicitly asks to post them.

## Workflow

1. Confirm the current directory is the intended repository and identify the MR IID. Check local changes and do not overwrite or discard them.
2. Read MR metadata with `glab mr view <iid>` and confirm its source and target branches. Use `glab mr diff <iid> --color never` to identify changed paths and changed lines. If the installed `glab` lacks a flag, use the supported plain output rather than assuming a newer CLI syntax.
3. Compare the MR against its target branch and inspect only the changed code plus the nearest relevant callers, data contracts, and tests. For example, use `git diff origin/<target>...HEAD -- <paths>`. Do not review generated or lockfile churn as application logic unless it presents a concrete defect.
4. For every candidate finding, establish the failing behavior from code or tests. Prefer reproducible correctness, data-loss, authorization, or runtime problems over speculative concerns and style preferences. Keep findings independent, prioritize by severity, and anchor each note to a changed line that makes the defect understandable.
5. Fetch the MR diff-version metadata before creating notes:

   ```sh
   glab api projects/:fullpath/merge_requests/<iid>/versions
   ```

   Use the current version's `base_commit_sha`, `start_commit_sha`, and `head_commit_sha` in each discussion position. Confirm the head SHA still matches the reviewed revision before posting; if it changed, re-review affected lines and update notes.

6. Prepare the notes as JSON with `jq`, escaping Polish text through `--arg`. Create inline discussions with the GitLab discussions API, not `glab mr note` (that command creates a general MR note):

   ```sh
   glab api "projects/:fullpath/merge_requests/<iid>/discussions" \
     --method POST \
     --header 'Content-Type: application/json' \
     --input - <<<"$payload"
   ```

   The JSON body uses this shape; use the actual changed path and line number:

   ```json
   {
     "body": "[P1] Krótki, konkretny opis problemu i jego skutku.",
     "position": {
       "position_type": "text",
       "base_sha": "<base_commit_sha>",
       "start_sha": "<start_commit_sha>",
       "head_sha": "<head_commit_sha>",
       "old_path": "path/to/file",
       "new_path": "path/to/file",
       "new_line": 42
     }
   }
   ```

7. If the user asks for a script rather than immediate posting, create a script with a non-posting `--dry-run` mode. Check its syntax and inspect dry-run JSON before finishing. The script must fail on request errors or malformed/empty responses, and must print a success message only after validating the returned discussion ID. Include a reviewed-head SHA guard to prevent stale line anchors.
8. If posting was explicitly requested, check existing discussions first to avoid duplicates. Post notes sequentially, verify each response, and report exactly which notes succeeded or failed. Never interpret an HTTP error printed by `glab` as success merely because the command's exit status is zero.

## Comment Quality

- Write concise comments in Polish, focused on one defect each.
- State the observed condition, concrete impact, and the smallest corrective direction; avoid prescribing a broad rewrite.
- Use severity labels consistently: `[P1]` for severe functional/security/data-loss impact, `[P2]` for substantial but narrower behavior defects, and `[P3]` for lower-impact issues. Do not force a fixed number of findings; report only substantiated problems.
- Anchor comments to changed lines. Do not create general MR notes when the user requested line comments.
- Do not include credentials, tokens, or other secrets in notes, scripts, terminal output, or examples.

## Failure Handling

- HTTP 415: ensure the request explicitly sends `Content-Type: application/json` and that `--input -` receives valid JSON.
- A `glab` HTTP error can appear without a useful nonzero exit status. Validate that the response is JSON containing a non-empty discussion `id` before reporting success.
- If the response is empty, invalid JSON, lacks an ID, or has an unsupported line position, stop and report the failure. Do not keep printing success or silently fall back to a general note.
- If `glab` options differ by version, inspect `glab api --help` and adapt to flags supported by the installed CLI.
