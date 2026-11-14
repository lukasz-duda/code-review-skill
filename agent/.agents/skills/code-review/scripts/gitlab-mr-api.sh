#!/bin/sh
set -eu

usage() {
    printf 'Usage: %s {versions|discussions|publish} <merge-request-id>\n' "$0" >&2
    exit 2
}

[ "$#" -eq 2 ] || usage
operation=$1
mr_id=$2

case "$mr_id" in
    ''|*[!0-9]*) usage ;;
esac

endpoint="projects/:fullpath/merge_requests/$mr_id"

case "$operation" in
    versions)
        response=$(glab api --paginate "$endpoint/versions")
        versions=$(printf '%s\n' "$response" | jq -se '
            if all(.[]; type == "array") then [.[][]]
            else error("expected an array of version pages")
            end
        ')
        printf '%s\n' "$versions" | jq -e '
            length > 0 and all(.[];
                (.base_commit_sha | type == "string" and length > 0) and
                (.start_commit_sha | type == "string" and length > 0) and
                (.head_commit_sha | type == "string" and length > 0)
            )
        ' >/dev/null || {
            printf 'GitLab returned invalid merge request versions.\n' >&2
            exit 1
        }
        printf '%s\n' "$versions"
        ;;
    discussions)
        response=$(glab api --paginate "$endpoint/discussions")
        discussions=$(printf '%s\n' "$response" | jq -se '
            if all(.[]; type == "array") then [.[][]]
            else error("expected an array of discussion pages")
            end
        ')
        printf '%s\n' "$discussions"
        ;;
    publish)
        payload=$(cat)
        printf '%s\n' "$payload" | jq -e '
            type == "object" and
            (.body | type == "string" and length > 0) and
            (.position |
                type == "object" and
                .position_type == "text" and
                (.base_sha | type == "string" and length > 0) and
                (.start_sha | type == "string" and length > 0) and
                (.head_sha | type == "string" and length > 0) and
                (.old_path | type == "string" and length > 0) and
                (.new_path | type == "string" and length > 0) and
                (.new_line | type == "number" and . > 0 and floor == .)
            )
        ' >/dev/null || {
            printf 'Invalid GitLab discussion payload.\n' >&2
            exit 1
        }

        response=$(printf '%s' "$payload" | glab api "$endpoint/discussions" \
            --method POST \
            --header 'Content-Type: application/json' \
            --input -)
        printf '%s\n' "$response" | jq -e '
            type == "object" and (.id | type == "string" and length > 0)
        ' >/dev/null || {
            printf 'GitLab did not return a valid discussion ID.\n' >&2
            exit 1
        }
        printf '%s\n' "$response"
        ;;
    *)
        usage
        ;;
esac
