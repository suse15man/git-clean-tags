#!/usr/bin/env bash

####!/opt/homebrew/bin/bash
#
# git-tag-cleanup
# Author: Abdoul Aw <abdoul.active@gmail.com>
# Summary: clean up old tags given an old date <yyyy-mm-dd>
#

# TRAP for Ctrl+C
trap ctrl_c INT
ctrl_c() {
    echo "The execution of the script was aborted due to user entering Ctrl-c"
    exit 255
}

# USAGE part
# This env variable is useful for checking remote validity of github repository:
export GIT_ASKPASS=true

if [[ ($# -eq 4 || ($# -eq 5 && $5 == '--dry-run')) ]];then
    echo "[pass]: # of arguments"
else
    echo "USAGE: $0 --date 2017-01-18 --repo https://github.com/suse15man/openedx [--dry-run]"
    exit 106
fi
if [[ $1 != '--date' ]];then
    echo "USAGE: $0 --date 2017-01-18 --repo https://github.com/suse15man/openedx [--dry-run]"
    echo "[ERROR] 1st argument must be equal to --date"
    exit 101
fi
if [[ $3 != '--repo' ]];then
    echo "USAGE: $0 --date 2017-01-18 --repo https://github.com/suse15man/openedx [--dry-run]"
    echo "[ERROR] 3rd argument must be equal to --repo"
    exit 103
fi
VALID_DATE=$2
if [[ $VALID_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]];then
    echo "[pass]: date $VALID_DATE matches the format <YYYY-MM-DD>"
else
    echo "USAGE: $0 --date 2017-01-18 --repo https://github.com/suse15man/openedx [--dry-run]"
    echo "[ERROR] 2nd argument date does not matches the format <YYYY-MM-DD>"
    exit 102
fi
if touch -c -d ${VALID_DATE}T00:00:00 /tmp/does-not-exist &> /dev/null;then
    echo "[pass]: date $VALID_DATE is a valid date from epoch" 
else
    echo "USAGE: $0 --date 2017-01-18 --repo https://github.com/suse15man/openedx [--dry-run]"
    echo "[ERROR] 2nd argument date is not a valid date from epoch"
    exit 102
fi
SITE_REPO_URL=$4
git ls-remote "${SITE_REPO_URL}" &> /dev/null
if [[ "$?" -ne 0 ]];then
    echo "USAGE: $0 --date 2017-01-18 --repo https://github.com/suse15man/openedx [--dry-run]"
    echo "[ERROR] 4th argument repo $SITE_REPO_URL is not valid"
    exit 104
fi

# Cloning the public repo openedx
cd git
if [[ -d openedx ]];then
    echo "[pass]: repo openedx already exists here;"
else
    git clone https://github.com/suse15man/openedx.git &> /dev/null
fi
cd openedx

# list the tags <dry-run> or delete the tags
if [[ $5 == '--dry-run' ]];then
    echo "<dry-run> mode: these following tags are the tags to be removed:"
    git for-each-ref --sort=taggerdate --format='%(tag)___%(taggerdate:raw)' refs/tags | grep -v '^___' | awk 'BEGIN {FS="___"} {t=strftime("%Y-%m-%d",$2); printf("%s %s\n", t, $1)}' | grep $VALID_DATE
    exit 105
else
    echo "Deleting tags:"
    git for-each-ref --sort=taggerdate --format='%(tag)___%(taggerdate:raw)' refs/tags | grep -v '^___' | awk 'BEGIN {FS="___"} {t=strftime("%Y-%m-%d",$2); printf("%s %s\n", t, $1)}' | grep $VALID_DATE > /tmp/${VALID_DATE}
    for i in $(awk '{print $NF}' /tmp/${VALID_DATE});do git tag -d $i;done
    git fetch origin --prune --prune-tags
fi
