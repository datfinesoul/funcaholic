#!/usr/bin/env bash
. "$(git rev-parse --show-toplevel)/gs/example/_scripts/env.source.bash"
env | sort -f | grep -e '^git_'
