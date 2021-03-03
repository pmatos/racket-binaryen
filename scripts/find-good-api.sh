#! /bin/bash
#
# Returns the SHA of the last good binaryen sha for which this API works

set -e

EXPECTED_SHA=$1
BINARYEN_PATH=$(mktemp -d)

git clone -q https://github.com/WebAssembly/binaryen.git ${BINARYEN_PATH}

FOUND_SHA=

cd $BINARYEN_PATH
for sha in `git log --pretty=format:"%H" --no-merges`; do
    git checkout -q $sha 
    sum=`sha1sum src/binaryen-c.h | cut -d ' ' -f1`
    if diff -q <(echo ${EXPECTED_SHA}) <(echo ${sum}); then
        break;
    fi
    BROKEN_SHA=$sha
done

echo "First broken: ${BROKEN_SHA}"
echo "Last good: $sha"

git checkout main
git --no-pager diff $sha..HEAD -- src/binaryen-c.h

rm -r ${BINARYEN_PATH}
