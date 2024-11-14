#!/usr/bin/bash
set -euo pipefail
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

require_var CI_TYPE
require_var REPO_TYPE
require_var MY_GITHUB_ORG
require_var MY_GITLAB_ORG

SAMPLE_REPO_HOST=github.com
SAMPLE_REPO_ORG=redhat-appstudio

case "$REPO_TYPE" in
build)
    SAMPLE_REPO=devfile-sample-nodejs-dance
    ;;

gitops)
    SAMPLE_REPO=tssc-dev-gitops
    ;;

*)
    fail_msg "REPO_TYPE var must 'build' or 'gitops'"
    exit 1
    ;;

esac

case "$CI_TYPE" in
github)
    GIT_HOST=github.com
    GIT_ORG="${MY_GITHUB_ORG}"
    ;;

gitlab)
    GIT_HOST=gitlab.com
    GIT_ORG="${MY_GITLAB_ORG}"
    ;;

jenkins)
    GIT_HOST=github.com
    GIT_ORG="${MY_GITHUB_ORG}"
    ;;

*)
    fail_msg "CI_TYPE var must be 'github', 'gitlab', or 'jenkins'"
    exit 1
    ;;

esac

# Upstream sample repo
UPSTREAM_GIT_URL="git@$SAMPLE_REPO_HOST:$SAMPLE_REPO_ORG/$SAMPLE_REPO"

# Sample repo fork
REPO_NAME="$SAMPLE_REPO-$CI_TYPE"
HTTPS_GIT_URL="https://$GIT_HOST/$GIT_ORG/$REPO_NAME"
SSH_GIT_URL="git@$GIT_HOST:$GIT_ORG/$REPO_NAME"
LOCAL_REPO_DIR="$LOCAL_WORK_DIR/$CI_TYPE-$REPO_TYPE"
# We could call the remote "origin" but I have a hunch we could
# refactor this to do it all from one local git repo, so I'm
# preempting that possibility by naming the new remote like this
REMOTE_NAME="origin-$CI_TYPE"
