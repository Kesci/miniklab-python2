#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

tag="$(git rev-parse --short HEAD)"

if [ "$1" == "tags" ]; then
	tag=$(git describe --abbrev=0 --tags)
fi

diffname=""
if [[ $TRAVIS_PULL_REQUEST = true ]]
then
	git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
	git fetch
	diffname=$(git diff --name-only  origin/master)
else
	diffname=$(git diff --name-only HEAD~1)
fi

if [[ $diffname =~ "Dockerfile" ]]
then
	echo "docker file changed, push it."
	docker tag  klabteam/miniklab klabteam/miniklab:$tag-python2
	docker push klabteam/miniklab:$tag-python2
	docker push klabteam/miniklab:latest-python2
	exit 0
else
	echo "docker file not changed, skip it."
fi
