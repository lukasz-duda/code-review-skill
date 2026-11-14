#!/bin/sh
set -eu

encoded_path=$(jq -rn --arg x "$GITLAB_PATH" '$x | @uri')
git clone "https://oauth2:$GITLAB_TOKEN@$GITLAB_HOST/$GITLAB_PATH.git" src
cd src

printf '%s' "$GITLAB_TOKEN" | glab auth login --hostname "$GITLAB_HOST" --stdin
glab auth status --hostname "$GITLAB_HOST"

mr=$(glab api "projects/:fullpath/merge_requests/$GITLAB_MR_ID")
branch=$(printf '%s' "$mr" | jq -er '
    .source_branch | if type == "string" and length > 0 then . else error("invalid merge request source branch") end
')
git checkout "$branch"

copilot -p "/skill:code-review $GITLAB_MR_ID" --allow-all
