#!/bin/bash

if [[ ! $(git rev-parse --is-inside-work-tree) ]]
then
    # Command already outputs error message to stderr on fail
    exit
fi

TRACKED_FILES=$(git diff --name-only)
echo "Tracked files: $TRACKED_FILES"
echo "--"
if [[ -n "$TRACKED_FILES" ]]; then
    for FILE in $TRACKED_FILES; do
        git diff $FILE

        echo -n "Would you like to stage $FILE? [Y/n]: "
        read YN
        if [[ -n $YN && ! $YN =~ "^[Yy]" ]]; then
            continue
        fi

        git add $FILE

        echo -n "Message to commit $FILE: "
        read MESSAGE
        git commit -m "$MESSAGE"
        echo "--"
    done
fi

UNTRACKED_FILES=($(git ls-files --exclude-standard --others))
echo "Untracked files: ${UNTRACKED_FILES[@]}"
echo "--"
if [[ -n "$UNTRACKED_FILES" ]]; then
    for FILE in ${UNTRACKED_FILES[@]}; do
        echo -n "Would you like to stage $FILE? [Y/n]: "
        read YN
        if [[ -n $YN && ! $YN =~ "^[Yy]" ]]; then
            continue
        fi

        git add $FILE

        echo -n "Message to commit $FILE: "
        read MESSAGE
        git commit -m "$MESSAGE"
        echo "--"
    done
fi

echo -n "Would you like to push these changes? [Y/n]: "
read YN
if [[ -n $YN && ! $YN =~ "^[Yy]" ]]; then
    exit
fi
git push
