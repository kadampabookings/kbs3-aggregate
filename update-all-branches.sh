#!/bin/bash

cd kbs3
FEATURE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git stash
git checkout staging && git pull && git checkout $FEATURE_BRANCH && git merge --no-commit staging && git stash pop
cd ..

cd kbsx
FEATURE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git stash
git checkout staging && git pull && git checkout $FEATURE_BRANCH && git merge --no-commit staging && git stash pop
cd ..

cd modality-fork
FEATURE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git stash
git checkout sync && git pull && git checkout staging && git merge --no-commit sync && git commit -m "merged from sync"
git checkout staging && git pull && git checkout $FEATURE_BRANCH && git merge --no-commit staging && git stash pop
cd ..
