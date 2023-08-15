#!/bin/bash
#SBATCH -D /fred/oz005/users/vishnu/compact_nextflow
#SBATCH -J nf-workflow-5EM7dlu4wh0m4G
#SBATCH -o /fred/oz005/users/vishnu/compact_nextflow/nf-5EM7dlu4wh0m4G.log
#SBATCH --no-requeue
set -e
set -o pipefail

# Input variables:
#
# - NXF_UUID: nextflow session id generated by tower
# - NXF_LOG_FILE: nextflow log file name
# - NXF_OUT_FILE: nextflow output file name
# - NXF_IGNORE_RESUME_HISTORY: do not stop for missing nextflow history file
# - NXF_CONFIG_BASE64: nextflow config file encoded as base64 string
# - NXF_SCM_BASE64: nextflow scm file encoded as base64 string
# - NXF_DEBUG: enable debugging mode
# - TOWER_ACCESS_TOKEN: Tower access token
# - TOWER_WORKFLOW_ID: Workflow ID generated by Tower
# - TOWER_CONFIG_BASE64: tower config file encoded as base64 string
# - TOWER_CONFIG_FILE: tower config file name

export NXF_IGNORE_RESUME_HISTORY=true
export NXF_WORK=/fred/oz005/users/vishnu/compact_nextflow/work
export NXF_EXIT_FILE=nf-5EM7dlu4wh0m4G.exit
export NXF_CONFIG_FILE=nf-5EM7dlu4wh0m4G.config
export NXF_OUT_FILE=nf-5EM7dlu4wh0m4G.txt
export NXF_ASSETS=/fred/oz005/users/vishnu/compact_nextflow/work/.nextflow/pipelines/d5411107
export NXF_UUID=a31bfd1d-5c3d-4a8f-a666-a26a4019b031
export NXF_TML_FILE=timeline-5EM7dlu4wh0m4G.html
export TOWER_WORKFLOW_ID=5EM7dlu4wh0m4G
export NXF_ANSI_LOG=false
export NXF_PLUGINS_DEFAULT=nf-tower
export NXF_PRERUN_BASE64=ZXhwb3J0IFRPV0VSX0FDQ0VTU19UT0tFTj1leUpoYkdjaU9pSklVekkxTmlKOS5leUp6ZFdJaU9pSTVPREE1SWl3aWJtSm1Jam94TmpreU1URTRNREF6TENKeWIyeGxjeUk2V3lKMWMyVnlJbDBzSW1semN5STZJblJ2ZDJWeUxXRndjQ0lzSW1WNGNDSTZNVFk1TWpFeU1UWXdNeXdpYVdGMElqb3hOamt5TVRFNE1EQXpmUS5Eb2NBNDhhZmVXa2ZTY2E4ekRBYU1SNVdvcnIwRkM4SXZDNHNzeFRma0o4CmV4cG9ydCBUT1dFUl9SRUZSRVNIX1RPS0VOPWV5SmhiR2NpT2lKSVV6STFOaUo5LllqTTVNR1F4TVRBdFlqazNOQzAwTldFeUxXSmpaV1V0TUdGak9UVTNNelE1WTJGbC5QdUNUNzBmLWxwTVlKSFpoZms4LVVwVjRvYmV0TjBvdzB4UVJzclA4NWJjCmV4cG9ydCBOWEZfU0NNX0ZJTEU9aHR0cHM6Ly9hcGkudG93ZXIubmYvZXBoZW1lcmFsL2FsaDkxR2NHWGFkY1lGX1ZPS3dxTXcK
export NXF_LOG_FILE=nf-5EM7dlu4wh0m4G.log
export NXF_CONFIG_BASE64=dGltZWxpbmUuZW5hYmxlZCA9IHRydWUKdGltZWxpbmUuZmlsZSA9ICIkTlhGX1RNTF9GSUxFIgpwcm9jZXNzLmV4ZWN1dG9yID0gJ3NsdXJtJwp3b3JrRGlyID0gJy9mcmVkL296MDA1L3VzZXJzL3Zpc2hudS9jb21wYWN0X25leHRmbG93L3dvcmsnCg==

[[ $NXF_DEBUG ]] && (env | sort) && set -x
cache_path=".nextflow/cache/$NXF_UUID"

function save_exit() {
    # Save exit code to file: note NXF_EXIT_FILE is expected to always be set; otherwise, the script will fail (return a non-zero exit code) at this point.
    [[ $NXF_EXIT_FILE ]] && printf $1 > $NXF_EXIT_FILE
}

function pre_run() {
    if [[ $NXF_PRERUN_BASE64 ]]; then
      source /dev/stdin <<<"$(cat <(echo $NXF_PRERUN_BASE64 | base64 -d))" > >(tee -a $NXF_OUT_FILE) 2>&1
    fi
}

function post_run() {
    if [[ $NXF_POSTRUN_BASE64 ]]; then
      bash <(echo $NXF_POSTRUN_BASE64 | base64 -d) > >(tee -a $NXF_OUT_FILE) 2>&1 || true
    fi
}

function on_exit() {
    NXF_EXIT_STATUS=$?
    save_exit $NXF_EXIT_STATUS
    rm -rf $NXF_SECRETS_FILE
    export NXF_EXIT_STATUS
    post_run
    exit $NXF_EXIT_STATUS
}

function load_cache() {
    if [[ $TOWER_RESUME_DIR ]]; then
      mkdir -p "$cache_path"
      [ -e "$TOWER_RESUME_DIR/$cache_path" ] && rsync -r "$TOWER_RESUME_DIR/$cache_path"/ "$cache_path" || true
    fi
}

function term_run() {
  kill -TERM $nf_pid
  wait $nf_pid
}

trap 'save_exit $?' EXIT

pre_run
load_cache

if [[ $NXF_CONFIG_BASE64 ]]; then
  echo $NXF_CONFIG_BASE64 | base64 -d > ${NXF_CONFIG_FILE:-nextflow.config}
  unset NXF_CONFIG_BASE64
fi

# save tower config file
if [[ $TOWER_CONFIG_BASE64 ]]; then
  echo $TOWER_CONFIG_BASE64 | base64 -d > $TOWER_CONFIG_FILE
fi

# save secrets
if [[ $NXF_SECRETS_BASE64 ]]; then
  export NXF_SECRETS_FILE=$PWD/nf-${TOWER_WORKFLOW_ID}.secrets.json
  echo $NXF_SECRETS_BASE64 | base64 -d > $NXF_SECRETS_FILE
  chmod 600 $NXF_SECRETS_FILE
fi

[[ $NXF_DEBUG ]] && nextflow -Dcapsule.log=verbose info -dd

trap term_run TERM INT USR2
trap on_exit EXIT
trap '' USR1

nextflow run https\://github.com/erc-compact/compact_nextflow -name shrivelled_snyder -with-tower -r main -profile ozstar > >(tee -a $NXF_OUT_FILE) 2>&1 &
nf_pid=$!
wait $nf_pid
