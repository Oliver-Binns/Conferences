#!/bin/bash

FROM="origin/$GITHUB_BASE_REF"
TO="origin/$GITHUB_HEAD_REF"

commits=$(git log --pretty=format:'%s' --date=relative $FROM..$TO)

echo "Origin: $TO"
echo "Target: $FROM"
echo $commits

echo $commits |
while read -r line; do
  check=$(echo $line | egrep '^(docs|fix|feat|chore|style|refactor|perf|test)(?:\((.*)\))?(!?)\: (.*)$')

  if [ "" = "$check" ]; then
    echo "Commit Message did not conform to Conventional Commits:"
    echo "\"$line\""
    exit 1
  else
    echo "commit ok: $line"
  fi
done
