#!/bin/bash

forks=("modality-fork" "webfx-extras-fork" "webfx-fork" "webfx-lib-javacupruntime-fork" "webfx-parent-fork" "webfx-platform-fork" "webfx-stack-parent-fork")
for i in "${forks[@]}"
do
    cd $(pwd)/$i
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git stash
    git checkout sync
    git pull origin sync
    git checkout staging
    git merge --no-commit sync
    git commit -m "merged from sync"
    # git push origin staging
    git checkout $CURRENT_BRANCH
    git stash pop
    cd ..
done
