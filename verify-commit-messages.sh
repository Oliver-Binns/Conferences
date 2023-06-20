#!/bin/bash

FROM="origin/main"
TO="$(git branch --show-current)"

commits=$(git log --pretty=format:'%s' --date=relative $FROM..$TO)

echo $commits

echo $commits |
while read -r line; do
  check=$(echo $line | egrep '^(docs|fix|feat|chore|style|refactor|perf|test)(?:\((.*)\))?(!?)\: (.*)$')

  echo "commit ok: $line"

  if [ "" = "$check" ]; then
    echo "Commit Message did not conform to Conventional Commits:"
    echo "\"$line\""
    exit 1
  fi
done
