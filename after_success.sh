#!/bin/bash

set -e # exit with nonzero exit code if anything fails

echo "Executing after script tasks..."

./ok.sh _format_json \
    state="success" \
    context="continuous-integration/rmg-tests" \
    description="The RMG-tests build passed" \
    target_url=$BUILD_URL \
    | ./ok.sh _post $GITHUB_STATUS_PATH > /dev/null

GIT_NAME="Travis Deploy"
GIT_EMAIL="travisci@rmg.edu"
echo GIT_NAME: $GIT_NAME
echo GIT_EMAIL: $GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

REPO=https://${GH_TOKEN}@github.com/ReactionMechanismGenerator/RMG-tests.git
git push $REPO --delete $BRANCH > /dev/null
