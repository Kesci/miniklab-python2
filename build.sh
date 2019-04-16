#!/bin/bash
set -e
set -o pipefail

diffname=""
if [[ $TRAVIS_PULL_REQUEST = true ]]
then
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch
	diffname=$(git diff --name-only  origin/master)
else
	diffname=$(git diff HEAD~1 --name-only)
fi

if [[ $diffname =~ "Dockerfile" ]]
then
	echo "docker file changed, build it."
	docker build -t klabteam/miniklab .
	exit 0
else
	echo "docker file not changed, skip it."
fi
