#!/usr/bin/bash
set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
source "${SCRIPTDIR}/utils.sh"

# Set this if you want to run just some of them
CI_TYPES=${CI_TYPES:-"github gitlab jenkins"}
REPO_TYPES=${REPO_TYPES:-"build gitops"}

clean_work_dir

for CI_TYPE in $CI_TYPES; do
    for REPO_TYPE in $REPO_TYPES; do
        nice_title "Preparing $REPO_TYPE repo for $CI_TYPE"
        source $SCRIPTDIR/clone-sample-repo.sh
    done
done
