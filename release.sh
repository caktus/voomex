#!/bin/bash
set -ex

rm -rf tmp/build
mkdir -p tmp/build
git archive --format=tar release-updates | tar x -C tmp/build/
cd tmp/build

docker build -f Dockerfile.releaser -t voomex:releaser .

DOCKER_UUID=$(uuidgen)

docker run -ti --name voomex_releaser_${DOCKER_UUID} voomex:releaser /bin/true
docker cp voomex_releaser_${DOCKER_UUID}:/opt/voomex.tar.gz ../
docker rm voomex_releaser_${DOCKER_UUID}
