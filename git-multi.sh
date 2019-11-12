#!/bin/bash
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
echo ""
echo -e "${CYAN}#### Git multi-repo operations #####${NC}"
echo ""
echo "Perform selected Git operations on ALL repositories in the current directory."
echo ""

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

PS3="Choose an action: "
options=("Status" "Pull" "Discard file(s)..." "Stash & checkout..." "Create branch, commit & push..." "Prune")
select opt in "${options[@]}"
do
    case $opt in
        "Status")
            echo "Status"
            break
            ;;
        "Pull")
            echo "Pull"
            break
            ;;
        "Discard file(s)...")
            echo "Discard file(s) based on a specified pattern. Use ** for all subdirs, e.g. **/package-lock.json"
            read -p "File pattern [**/package-lock.json]: " filepattern
            filepattern=${filepattern:-**/package-lock.json}
            break
            ;;
        "Stash & checkout...")
            echo "Stash all changes and checkout a specified branch"
            #read -p "Stash name []: " stash
            read -p "Branch name [master]: " branch
            branch=${branch:-master}
            break
            ;;
        "Create branch, commit & push...")
            echo "Create a new branch, add all existing changes, commit and push to origin"
            read -p "Branch name []: " branch
            read -p "Commit message []: " message
            break
            ;;
        "Prune")
            echo "Prune"
            if ! confirm "This is a destructive operation. Are you sure? [y/N]";
            then
                exit 0
            fi
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
            "Status")
                git status
                ;;
            "Pull")
                git pull
                ;;
            "Discard file(s)...")
                git checkout -- $filepattern
                ;;
            "Stash & checkout...")
                git stash save --keep-index --include-untracked
                git checkout "$branch"
                ;;
            "Create branch, commit & push...")
                git checkout -b "$branch"
                git add .
                git commit -m "$message"
                git push -u origin HEAD
                ;;
            "Prune")
                echo -e "${CYAN}git remote prune origin${NC}"
                git remote prune origin
                ;;
        esac

        cd ..
    fi
done
