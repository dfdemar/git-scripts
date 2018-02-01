#!/bin/bash

# Delete any earlier instances of hashlog
rm hashlog

# Get the name of the current branch
BRANCH=`git symbolic-ref --short HEAD`
echo $BRANCH
# Get the hash of the first commit of the branch
FIRST_COMMIT=$(git log master..$BRANCH --pretty="%H" | tail -1)
echo $FIRST_COMMIT

# LATER: check $FIRST_COMMIT for null

# Get the name of the base branch
BASE_BRANCH=$(git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//')
echo $BASE_BRANCH

# Before the rebase, save the timestamps and commit messages of all the commits to a file
git log --pretty='%ct %at %s' $FIRST_COMMIT^...preserve-commit-dates > hashlog

# Do the rebase
git rebase $BASE_BRANCH

# The hash of first commit has now changed, so get the new one
FIRST_COMMIT=$(git log master..$BRANCH --pretty="%H" | tail -1)

git filter-branch -f --env-filter '
	__date=$(__log=$(git log -1 --pretty="%at %s" $GIT_COMMIT);
	grep -m 1 "$__log" ../../hashlog | cut -d" " -f1);
	test -n "$__date" && export GIT_COMMITTER_DATE=$__date || cat
' $FIRST_COMMIT^...$BRANCH