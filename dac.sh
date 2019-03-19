#!/bin/bash

read_and_commit() {
    local MESSAGE=""
    read -p "Commit Message: " MESSAGE
    MESSAGE=$(echo $MESSAGE | sed -e "s/^[[:space:]]*//" | sed -e "s/*[[:space:]]$//")
    MESSAGE=${MESSAGE:-"Minor changes"}
    git commit -m "$MESSAGE"
}

if [[ ! $(git rev-parse --is-inside-work-tree) ]]
then
    # Command already outputs error message to stderr on fail
    exit
fi

# Get into the git root directory if we aren't there
GITROOT=$(git rev-parse --git-dir | rev | cut -c 5-| rev)
if [[ ! -z "${GITROOT// }" ]]; then
    echo "Changing to git root at $GITROOT..."
    cd $GITROOT
fi

# Committed flag
COMMITTED=0

STAGED_FILES=$(git diff --cached --name-only)
echo "Staged files: $STAGED_FILES"
echo "--"
if [[ -n "$STAGED_FILES" ]]; then
    for FILE in $STAGED_FILES; do
        COMMITTED=1

        echo "$FILE"
        read_and_commit
        echo "--"
    done
fi

TRACKED_FILES=$(git diff --name-only)
echo "Tracked files: $TRACKED_FILES"
echo "--"
if [[ -n "$TRACKED_FILES" ]]; then
    for FILE in $TRACKED_FILES; do
        git diff $FILE

        read -p "Stage $FILE? [Y/n]: " YN
        if [[ -n $YN && ! $YN =~ "^[Yy]" ]]; then
            continue
        fi
        COMMITTED=1

        git add $FILE

        read_and_commit
        echo "--"
    done
fi

UNTRACKED_FILES=($(git ls-files --exclude-standard --others))
echo "Untracked files: ${UNTRACKED_FILES[@]}"
echo "--"
if [[ -n "$UNTRACKED_FILES" ]]; then
    for FILE in ${UNTRACKED_FILES[@]}; do
        less $FILE

        read -p "Stage $FILE? [Y/n]: " YN
        if [[ -n $YN && ! $YN =~ "^[Yy]" ]]; then
            continue
        fi
        COMMITTED=1

        git add $FILE

        read_and_commit
        echo "--"
    done
fi

if [[ $COMMITTED == 0 ]]; then
    echo "Bye"
    exit
fi

read -p "Push? [Y/n]: " YN
if [[ -n $YN && ! $YN =~ "^[Yy]" ]]; then
    echo "Bye"
    exit
fi
git push
