#!/bin/sh

set -e

source $(dirname $0)/helpers.sh

it_can_get_version() {
  local dest=$TMPDIR/destination

  mkdir $dest

  get_branches_added_removed $dest $'a\nb' "a" "c" | jq -e '
    .version == {branches: "a\nb", "added": "a", "removed": "c"}
  '

  test "$(cat $dest/branches)" = $'a\nb'
  test "$(cat $dest/added)" = "a"
  test "$(cat $dest/removed)" = "c"
}

run it_can_get_version
