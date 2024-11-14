#!/usr/bin/bash
set -euo pipefail

GIT_TOP_LEVEL=$(git rev-parse --show-toplevel)

LOCAL_WORK_DIR="$GIT_TOP_LEVEL/_ci_tmp"

clean_work_dir() {
    rm -rf "$LOCAL_WORK_DIR"
}

# Ensure that a particular env var is present
require_var() {
    local var_name="$1"
    set +u
    local var_value=""${!var_name}
    set -u
    if [ -z $var_value ]; then
        fail_msg "Required var $var_name is not present"
        exit 1
    fi
}

# Use for tidier output when displaying paths
relative_path() {
    realpath -s --relative-to="${GIT_TOP_LEVEL}" "$1"
}

# For pretty output
nice_title() {
    local msg="$*"
    local line=$(echo "   $msg" | tr '[:print:]' '-')
    echo "$line"
    echo "👷 $msg"
    echo "$line"
}

nice_msg() {
    echo 🔧 $*
}

fail_msg() {
    echo ⛔ $*
}
