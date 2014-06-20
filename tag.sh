#!/bin/sh

git push --delete origin 'Podspec-2.0.0'

git tag -f 'Podspec-2.0.0'

git push --tags

