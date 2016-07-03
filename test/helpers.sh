#!/bin/sh

set -e -u

set -o pipefail

resource_dir=/opt/resource

run() {
  export TMPDIR=$(mktemp -d ${TMPDIR_ROOT}/git-tests.XXXXXX)

  echo -e 'running \e[33m'"$@"$'\e[0m...'
  eval "$@" 2>&1 | sed -e 's/^/  /g'
  echo ""
}

init_repo() {
  (
    set -e

    cd $(mktemp -d $TMPDIR/repo.XXXXXX)

    git init -q

    # start with an initial commit
    git \
      -c user.name='test' \
      -c user.email='test@example.com' \
      commit -q --allow-empty -m "init"

    # back to master
    git checkout master

    # print resulting repo
    pwd
  )
}

make_commit_to_file_on_branch() {
  local repo=$1
  local file=$2
  local branch=$3
  local msg=${4-}

  # ensure branch exists
  if ! git -C $repo rev-parse --verify $branch >/dev/null 2>&1; then
    git -C $repo branch $branch master
  fi

  # switch to branch
  git -C $repo checkout -q $branch

  # modify file and commit
  echo x >> $repo/$file
  git -C $repo add $file
  git -C $repo \
    -c user.name='test' \
    -c user.email='test@example.com' \
    commit -q -m "commit $(wc -l $repo/$file) $msg"

  # output resulting sha
  git -C $repo rev-parse HEAD
}

make_commit_to_branch() {
  make_commit_to_file_on_branch $1 some-file $2
}

check_uri() {
  jq -n '{
    source: {
      uri: $uri
    }
  }' --arg uri "$1" | ${resource_dir}/check | tee /dev/stderr
}

check_uri_from() {
  jq -n '{
    source: {
      uri: $uri
    },
    version: {
      branches: $branches
    }
  }' --arg uri "$1" --arg branches "$2" | ${resource_dir}/check | tee /dev/stderr
}

get_branches_added_removed() {
  jq -n '{
    version: {
      branches: $branches,
      added: $added,
      removed: $removed
    }
  }' --arg branches "$2" --arg added "$3" --arg removed "$4" \
    | ${resource_dir}/in "$1" | tee /dev/stderr
}
