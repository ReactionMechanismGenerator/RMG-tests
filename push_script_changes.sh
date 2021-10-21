#!/bin/bash

git branch -D rmgpy-surface_diff
git branch -c rmgpy-surface_diff
git checkout rmgpy-surface_diff
git commit --allow-empty -m "rmgpy-4dacc59a69412a233fb2d000d06855624e3bcd88"
git push -uf origin rmgpy-surface_diff


