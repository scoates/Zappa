#!/bin/bash

npm install doctoc
$(npm bin)/doctoc README.md

git status | grep README.md | grep modified
if [ ! $? -eq 0 ]; then
    echo "No changes."
    exit 0
fi

USER=$(git remote -v | grep origin | grep push | awk {'print $2'} | sed -e 's@\(.*\)[:/]\(.*\)/Zappa.git@\2@g')
HASH=$(git log -n1 | head -n1 | awk {'print $2'})
BRANCH="update-readme-toc-$HASH"
PR_USER="scoates"

git checkout -b $BRANCH

git commit -m"Update README TOC" README.md
git push origin $BRANCH

curl -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"doctoc update\", \"body\": \"via makedoctoc.sh\", \"head\": \"scoates:$BRANCH\", \"base\": \"master\"}" \
  -XPOST https://api.github.com/repos/scoates/Zappa/pulls
