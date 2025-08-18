GIT_PWD="$(git rev-parse --show-prefix 2> /dev/null)"
GIT_REL="$(git rev-parse --show-cdup 2> /dev/null)"
export GIT_PWD GIT_REL
