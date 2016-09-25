#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_check_from_no_version() {
  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  # NB: these actually end up being the same ref most of the time, since commit
  # shas are computed based on the patch message, and if it's the same code
  # change, message, parent sha, and timestamp, the sha will be the same
  local refa1=$(make_commit_to_branch $repo branch-a)
  local refb1=$(make_commit_to_branch $repo branch-b)

  check_uri $repo | jq -e '
    . == [{
      changed: "branch-a",
      "branch-a": $refa1,
      "branch-b": $refb1,
      "master": $refmaster1
    },{
      changed: "branch-b",
      "branch-a": $refa1,
      "branch-b": $refb1,
      "master": $refmaster1
    },{
      changed: "master",
      "branch-a": $refa1,
      "branch-b": $refb1,
      "master": $refmaster1
    }]
  ' --arg refa1 "$refa1" --arg refb1 "$refb1" --arg refmaster1 "$refmaster1"
}

it_can_check_from_no_version_with_filter() {
  set -e

  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  # NB: these actually end up being the same ref most of the time, since commit
  # shas are computed based on the patch message, and if it's the same code
  # change, message, parent sha, and timestamp, the sha will be the same
  local refa1=$(make_commit_to_branch $repo matched-a)
  local refb1=$(make_commit_to_branch $repo matched-b)

  make_commit_to_branch $repo not-matched-a

  make_commit_to_branch $repo ignored-a
  make_commit_to_branch $repo ignored-b

  check_uri_branches $repo 'matched-*' | jq -e '
    . == [{
      changed: "matched-a",
      "matched-a": $refa1,
      "matched-b": $refb1
    },{
      changed: "matched-b",
      "matched-a": $refa1,
      "matched-b": $refb1
    }]
  ' --arg refa1 "$refa1" --arg refb1 "$refb1"
}

it_can_check_from_no_version_with_filters() {
  set -e

  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  # NB: these actually end up being the same ref most of the time, since commit
  # shas are computed based on the patch message, and if it's the same code
  # change, message, parent sha, and timestamp, the sha will be the same
  local refa1=$(make_commit_to_branch $repo matched-a)
  local refb1=$(make_commit_to_branch $repo matched-b)

  local refc1=$(make_commit_to_branch $repo also-matched-c)

  make_commit_to_branch $repo ignored-a
  make_commit_to_branch $repo ignored-b

  check_uri_branches $repo 'matched-*' 'also-*' | jq -e '
    . == [{
      changed: "also-matched-c",
      "matched-a": $refa1,
      "matched-b": $refb1,
      "also-matched-c": $refc1
    },{
      changed: "matched-a",
      "matched-a": $refa1,
      "matched-b": $refb1,
      "also-matched-c": $refc1
    },{
      changed: "matched-b",
      "matched-a": $refa1,
      "matched-b": $refb1,
      "also-matched-c": $refc1
    }]
  ' --arg refa1 "$refa1" --arg refb1 "$refb1" --arg refc1 "$refc1"
}

it_can_check_with_updated_branch() {
  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  local refa1=$(make_commit_to_branch $repo branch-a)
  local refb1=$(make_commit_to_branch $repo branch-b)

  local refa2=$(make_commit_to_branch $repo branch-a)

  check_uri_from $repo "branch-a=$refa1" "branch-b=$refb1" "master=$refmaster1" | jq -e '
    . == [{
      changed: "branch-a",
      "branch-a": $refa2,
      "branch-b": $refb1,
      "master": $refmaster1
    }]
  ' --arg refa2 "$refa2" --arg refb1 "$refb1" --arg refmaster1 "$refmaster1"
}

it_can_check_with_updated_branches() {
  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  local refa1=$(make_commit_to_branch $repo branch-a)
  local refb1=$(make_commit_to_branch $repo branch-b)

  local refa2=$(make_commit_to_branch $repo branch-a)
  local refb2=$(make_commit_to_branch $repo branch-b)

  check_uri_from $repo "branch-a=$refa1" "branch-b=$refb1" "master=$refmaster1" | jq -e '
    . == [{
      changed: "branch-a",
      "branch-a": $refa2,
      "branch-b": $refb2,
      "master": $refmaster1
    }, {
      changed: "branch-b",
      "branch-a": $refa2,
      "branch-b": $refb2,
      "master": $refmaster1
    }]
  ' --arg refa2 "$refa2" --arg refb2 "$refb2" --arg refmaster1 "$refmaster1"
}

it_can_check_with_added_branch() {
  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  local refa1=$(make_commit_to_branch $repo branch-a)
  local refb1=$(make_commit_to_branch $repo branch-b)

  local refc1=$(make_commit_to_branch $repo branch-c)

  check_uri_from $repo "branch-a=$refa1" "branch-b=$refb1" "master=$refmaster1" | jq -e '
    . == [{
    changed: "branch-c",
    "branch-a": $refa1,
    "branch-b": $refb1,
    "branch-c": $refc1,
    "master": $refmaster1
  }]
  ' --arg refa1 "$refa1" --arg refb1 "$refb1" --arg refc1 "$refc1" --arg refmaster1 "$refmaster1"
}

it_can_check_with_removed_branch() {
  local repo=$(init_repo)

  local refmaster1=$(git -C $repo rev-parse master)

  local refa1=$(make_commit_to_branch $repo branch-a)

  check_uri_from $repo "branch-a=$refa1" "branch-b=bogus-ref" "master=$refmaster1" | jq -e '
    . == []
  ' --arg refa1 "$refa1" --arg refmaster1 "$refmaster1"
}

run it_can_check_from_no_version
run it_can_check_from_no_version_with_filter
run it_can_check_from_no_version_with_filters
run it_can_check_with_updated_branch
run it_can_check_with_updated_branches
run it_can_check_with_added_branch
run it_can_check_with_removed_branch
