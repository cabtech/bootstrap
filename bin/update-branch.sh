#!/bin/bash
branch=${1:-main}
git fetch
git merge origin/${branch}
git push
git branch -rv
exit 0
