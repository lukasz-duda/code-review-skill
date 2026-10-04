#!/bin/sh
set -eu

/usr/local/bin/login.sh

pi Hello

if [ "$#" -gt 0 ]; then
	exec "$@"
fi