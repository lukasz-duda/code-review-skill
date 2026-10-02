#!/bin/sh
set -eu

/usr/local/bin/login.sh

if [ "$#" -gt 0 ]; then
	exec "$@"
fi