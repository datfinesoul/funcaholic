#!/usr/bin/env bash
. "$(git rev-parse --show-toplevel)/gs/example/js/_gs/env.source.bash"
env | sort | grep -e '^\(NODE\|GIT\)_'
