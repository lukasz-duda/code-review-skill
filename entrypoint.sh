#!/bin/bash

glab config set -g host $GITLAB_HOST
glab config set -g skip_tls_verify true --host $GITLAB_HOST
glab auth login --hostname $GITLAB_HOST -t $TOKEN
glab auth status --hostname $GITLAB_HOST
glab api --hostname "$GITLAB_HOST" --paginate "groups/$GROUP_ID/merge_requests?state=opened"