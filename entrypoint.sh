#!/bin/bash

if ! ${DIFF_BASE+false};
then
	changedFiles=$(git --no-pager diff --name-only FETCH_HEAD $(git merge-base FETCH_HEAD $DIFF_BASE) -- '*.swift')

	if [ -z "$changedFiles" ]
	then
		echo "No Swift file changed"
		exit
	fi
fi

set -o pipefail && swiftlint "$@" --reporter github-actions-logging -- $changedFiles
