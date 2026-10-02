#!/bin/sh
set -eu

if [ -z "${GITLAB_HOST:-}" ]; then
	printf '%s\n' 'GITLAB_HOST must be set' >&2
	exit 2
fi

case "${GITLAB_SKIP_TLS_VERIFY:-false}" in
	true)
		glab config set skip_tls_verify true --global --host "$GITLAB_HOST"
		;;
	false)
		glab config set skip_tls_verify false --global --host "$GITLAB_HOST"
		;;
	*)
		printf '%s\n' 'GITLAB_SKIP_TLS_VERIFY must be true or false' >&2
		exit 2
		;;
esac

glab auth login --hostname "$GITLAB_HOST" --stdin < /run/secrets/gitlab_token
glab auth status --hostname "$GITLAB_HOST"