#!/usr/bin/env bash
. "$(git rev-parse --show-toplevel)/gs/example/js/_gs/env.source.bash"
env | sort -f | grep -e '^\(NODE_ENV\|git_\)'
