git_pwd="$(git rev-parse --show-prefix 2> /dev/null)"
git_rel="$(git rev-parse --show-cdup 2> /dev/null)"
export git_pwd git_rel
