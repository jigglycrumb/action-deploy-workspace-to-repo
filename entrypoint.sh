#!/bin/sh -l

echo "⭐️ Starting deployment"

echo "⭐️ Configuring git"

apk add jq
COMMIT_EMAIL=$(jq '.pusher.email' ${GITHUB_EVENT_PATH})
COMMIT_NAME=$(jq '.pusher.name' ${GITHUB_EVENT_PATH})
#COMMIT_MESSAGE=$(jq '.commits[0].message' ${GITHUB_EVENT_PATH})
COMMIT_SHA=$(jq '.commits[0].sha' ${GITHUB_EVENT_PATH})

git config --global user.email "${COMMIT_EMAIL}"
git config --global user.name "${COMMIT_NAME}"

DEST_REPO_PATH="https://${GITHUB_ACCESS_TOKEN}@github.com/$DEST_OWNER/$DEST_REPO.git"

echo "⭐️ Cloning $DEST_REPO"
cd $GITHUB_WORKSPACE
git clone $DEST_REPO_PATH

echo "⭐️ Cleaning old files"
cd $DEST_REPO
eval "$DEST_PREDEPLOY_CLEANUP"

echo "⭐️ Copying files from $SRC_FOLDER"
mkdir -p $GITHUB_WORKSPACE/$DEST_REPO/$DEST_FOLDER # in case the folder was deleted by cleanup
cd $GITHUB_WORKSPACE/$SRC_FOLDER
cp -R * $GITHUB_WORKSPACE/$DEST_REPO/$DEST_FOLDER

echo "⭐️ Committing changes"
cd $GITHUB_WORKSPACE/$DEST_REPO
git add .
git commit -m "Automated release: $(date '+%Y-%m-%d, %H:%M:%S') ($COMMIT_SHA)"

echo "⭐️ Pushing changes to $DEST_BRANCH"
git push $DEST_REPO_PATH $DEST_BRANCH

echo "⭐️ Finished"
