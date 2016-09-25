#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_get_version() {
  local dest=$TMPDIR/destination

  mkdir $dest

  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  # NB: these actually end up being the same ref most of the time, since commit
  # shas are computed based on the patch message, and if it's the same code
  # change, message, parent sha, and timestamp, the sha will be the same
  local refa1=$(make_commit_to_branch $repo branch-a)
  local refb1=$(make_commit_to_branch $repo branch-b)

  get_changed_branch $repo $dest "branch-a" "branch-a=$refa1" "branch-b=$refb1" "master=$refmaster1" | jq -e '
    . == {
      destination: $dest,
      request: {
        source: {
          uri: $repo,
          branch: $branch,
        },
        version: {
          ref: $ref,
        }
      },
      version: {
        "changed": $branch,
        "branch-a": $refa1,
        "branch-b": $refb1,
        "master": $refmaster1
      }
    }
  ' --arg dest "$dest" \
    --arg repo "$repo" \
    --arg branch "branch-a" \
    --arg ref "$refa1" \
    --arg refa1 "$refa1" \
    --arg refb1 "$refb1" \
    --arg refmaster1 "$refmaster1"
}

run it_can_get_version
