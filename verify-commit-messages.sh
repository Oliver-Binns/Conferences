#!/bin/bash

FROM="origin/$GITHUB_BASE_REF"
TO="origin/$GITHUB_HEAD_REF"

git log --pretty=format:"%h %s" $FROM..$TO

commits=$(git log --date=relative $FROM..$TO --pretty=format:"%s
")

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
