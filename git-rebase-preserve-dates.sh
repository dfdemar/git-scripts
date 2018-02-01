#!/bin/bash

function restore_dates() {
	__date=$(__log=$(git log -1 --pretty="%at %s" $GIT_COMMIT)
	grep -m 1 "$__log" ../../hashlog | cut -d" " -f1)
	test -n "$__date" && export GIT_COMMITTER_DATE=$__date || cat
}

BRANCH=`git symbolic-ref --short HEAD`
echo $BRANCH
FIRST_COMMIT=$(git log master..$BRANCH --pretty="%H" | tail -1)
echo $FIRST_COMMIT

#check $FIRST_COMMIT for null

BASE_BRANCH=$(git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//')
echo $BASE_BRANCH

git log --pretty='%ct %at %s' $FIRST_COMMIT^...preserve-commit-dates > hashlog

git rebase $BASE_BRANCH

FIRST_COMMIT=$(git log master..$BRANCH --pretty="%H" | tail -1)

git filter-branch -f --env-filter restore_dates $FIRST_COMMIT^...$BRANCH

rm hashlog