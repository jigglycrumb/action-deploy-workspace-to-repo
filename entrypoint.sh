#!/bin/sh -l

echo "⭐️ Starting deployment"

echo "⭐️ Configuring git"

apk add jq
COMMIT_EMAIL=$(jq '.pusher.email' ${GITHUB_EVENT_PATH})
COMMIT_NAME=$(jq '.pusher.name' ${GITHUB_EVENT_PATH})
COMMIT_MESSAGE=$(jq '.commits[0].message' ${GITHUB_EVENT_PATH})

git config --global user.email "${COMMIT_EMAIL}"
git config --global user.name "${COMMIT_NAME}"

REPOSITORY_PATH="https://${GITHUB_ACCESS_TOKEN}@github.com/$DEST_OWNER/$DEST_REPO.git"

echo "⭐️ Cloning $DEST_REPO"
cd $GITHUB_WORKSPACE
git clone $REPOSITORY_PATH

echo "⭐️ Cleaning old files"
cd ./$DEST_REPO
eval "$DEST_PREDEPLOY_CLEANUP"

echo "⭐️ Coping files from $SRC_FOLDER"
cd ../$SRC_FOLDER
cp -R * ../$DEST_REPO/$DEST_FOLDER

echo "⭐️ Commiting changes with message: $COMMIT_MESSAGE"
cd ../$DEST_REPO
git add .
git commit -m "Release: $COMMIT_MESSAGE"

echo "⭐️ Pushing changes to $DEST_BRANCH"
git push $REPOSITORY_PATH $DEST_BRANCH

echo "⭐️ Finished"
