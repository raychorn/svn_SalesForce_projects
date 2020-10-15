#!/bin/bash

git init
find * -size +4M -type f -print >> .gitignore
git add -A
git commit -m "first commit"
git branch -M main
git remote add origin https://raychorn:e76b2e3abb75de40bbdadff5dff795f2f3ef674d@github.com/raychorn/svn_SalesForce_projects.git
git push -u origin main
