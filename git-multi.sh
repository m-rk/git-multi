#!/bin/bash
echo ""
echo "#### Git multi-repo operations #####"
echo ""
echo "Perform selected Git operations on ALL repositories in the current directory."
echo ""

PS3='Choose an action: '
options=("Discard file(s)..." "Stash & Checkout..." "Pull" "Create & Push..." "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Discard file(s)...")
            echo "Discard file(s) based on a specified pattern. Use ** for all subdirs, e.g. **/package-lock.json"
            read -p "File pattern [*]: " filepattern
            break
            ;;
        "Stash & Checkout...")
            echo "Stash all changes and checkout a specified branch"
            #read -p "Stash name []: " stash
            read -p "Branch name [master]: " branch
            branch=${branch:-master}
            break
            ;;
        "Pull")
            echo "Pull"
            break
            ;;
        "Create & Push...")
            echo "Create a new branch, add all existing changes, commit and push to origin"
            read -p "Branch name []: " branch
            read -p "Commit message []: " message
            break
            ;;
        "Quit")
            exit 0
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

for D in *; do
    if [ -d "${D}" ]; then
        cd ${D}

        echo "${D}"

        case $opt in
            "Discard file(s)...")
                git checkout -- $filepattern
                ;;
            "Stash & Checkout...")
                git stash save --keep-index --include-untracked
                git checkout "$branch"
                ;;
            "Pull")
                git pull
                ;;
            "Create & Push...")
                git checkout -b "$branch"
                git add *
                git commit -m "$message"
                git push -u origin HEAD
                ;;
        esac

        cd ..
    fi
done
