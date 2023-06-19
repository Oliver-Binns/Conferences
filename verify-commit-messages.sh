#!/bin/bash

FROM="main"
TO="$(git branch --show-current)"

git log --pretty=format:'%h %s' --abbrev-commit --date=relative $FROM..$TO |
while read -r line; do
  MSG=${line:8}

  check=$(echo $MSG | egrep '^(docs|fix|feat|chore|style|refactor|perf|test)(?:\((.*)\))?(!?)\: (.*)$')

  if [ "" = "$check" ]; then
    echo "Commit Message did not conform to Conventional Commits:"
    echo "\"$MSG\""
    exit 1
  fi
done
