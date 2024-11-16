#!/usr/bin/bash
set -euo pipefail
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "$SCRIPTDIR/utils.sh"

# This sets many vars based on $CI_TYPE and $REPO_TYPE
source "$SCRIPTDIR/config-vars.sh"

# Check that the expected "fork" repo exists and maybe create it if it doesn't
ensure_fork_exists() {
    local http_status=$(curl -s -o /dev/null -I -w "%{http_code}" "$HTTPS_GIT_URL")
    if [ $http_status == 200 ]; then
        true

    elif [ "$GIT_HOST" == "github.com" ]; then
        gh repo create "$REPO_NAME" --public
        nice_msg "Repo $REPO_NAME created"

    elif [ "$GIT_HOST" == "gitlab.com" ]; then
        # Todo: Create the GitLab repo here using the rest API
        fail_msg "Please create a public repo at $HTTPS_GIT_URL"
        fail_msg "(It should allow force pushes to main branch)"
        exit 1
    fi
}

# Set up a local git clone
clone_sample_repo() {
    mkdir -p "$LOCAL_REPO_DIR"
    cd "$LOCAL_REPO_DIR"

    # Clone from the "upstream" repo to begin with
    nice_msg "Cloning repo $UPSTREAM_GIT_URL to $(relative_path $LOCAL_REPO_DIR)"
    git clone -q "$UPSTREAM_GIT_URL" .

    # Remove the upstream remote and create a new one pointing to the fork
    nice_msg "Creating remote $REMOTE_NAME as $SSH_GIT_URL"
    git remote rm origin
    git remote add "$REMOTE_NAME" "$SSH_GIT_URL"

    # Force push to main branch
    nice_msg "Force pushing to main branch to remote $REMOTE_NAME"
    set +e
    git push --quiet --force "$REMOTE_NAME" main:main
    if [ "$?" != "0" ]; then
        echo "Push to $SSH_GIT_URL failed!"
        echo "Ensure the repo allows force push to main branch."
        exit 1
    fi
    set -e

    cd "$GIT_TOP_LEVEL"
}

copy_pipeline_definition() {
    local src="generated/$REPO_TYPE_SUBDIR/$CI_TYPE_SUBDIR/$PIPELINE_DEFINITION_FILE"
    local dest="$LOCAL_REPO_DIR/$PIPELINE_DEFINITION_FILE"

    nice_msg "Updating $PIPELINE_DEFINITION_FILE in $(relative_path "$LOCAL_REPO_DIR")"

    # Copy the pipeline file
    mkdir -p $(dirname "$dest")
    cp "$src" "$dest"

    # Make a commit
    cd "$LOCAL_REPO_DIR"
    git add "$PIPELINE_DEFINITION_FILE"
    git commit -q -m "ci: Add or update $CI_TYPE pipeline" \
        -m "Commit created automatically" \
        -m "See https://github.com/redhat-appstudio/tssc-dev-multi-ci/tree/main/test"

    cd "$GIT_TOP_LEVEL"
}

ensure_fork_exists
clone_sample_repo
copy_pipeline_definition
