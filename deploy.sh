#!/usr/bin/env bash

set -euo pipefail

npm run build
git checkout gh-pages
git pull
rm -rf ./assets/
rm -rf ./build-a-doodlebot/
mv ./dist/* ./
git add index.html assets build-a-doodlebot
git commit -m "Deploy new version"
git push
git checkout main