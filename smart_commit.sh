#!/usr/bin/env bash

# Adds all modified, untracked files then prompts for
# commit message and the branch then pushes to github
git add .
echo Enter commit message
read message
git commit -m "$message"
echo Which branch
read branch
git push origin $branch
