# Git Branches Resource

Tracks the set of branches that exist in a [git](http://git-scm.com/)
repository.

## Installation

Add the following `resource_types` entry to your pipeline:

```yaml
---
resource_types:
- name: git-branches
  type: docker-image
  source: {repository: vito/git-branches-resource}
```

## Source Configuration

* `uri`: *Required.* The location of the repository.

* `private_key`: *Optional.* Private key to use when pulling/pushing.
    Example:
    ```
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAtCS10/f7W7lkQaSgD/mVeaSOvSF9ql4hf/zfMwfVGgHWjj+W
      <Lots more text>
      DWiJL+OFeg9kawcUL6hQ8JeXPhlImG6RTUffma9+iGQyyBMCGd1l
      -----END RSA PRIVATE KEY-----
    ```

* `username`: *Optional.* Username for HTTP(S) auth when pulling/pushing.
  This is needed when only HTTP/HTTPS protocol for git is available (which does not support private key auth)
  and auth is required.

* `password`: *Optional.* Password for HTTP(S) auth when pulling/pushing.

* `skip_ssl_verification`: *Optional.* Skips git ssl verification by exporting
  `GIT_SSL_NO_VERIFY=true`.

* `git_config`: *Optional*. If specified as (list of pairs `name` and `value`)
  it will configure git global options, setting each name with each value.

  This can be useful to set options like `credential.helper` or similar.

  See the [`git-config(1)` manual page](https://www.kernel.org/pub/software/scm/git/docs/git-config.html)
  for more information and documentation of existing git options.

### Example

Resource configuration for a private repo:

``` yaml
resources:
- name: source-code
  type: git-branches
  source:
    uri: git@github.com:concourse/git-resource.git
    private_key: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAtCS10/f7W7lkQaSgD/mVeaSOvSF9ql4hf/zfMwfVGgHWjj+W
      <Lots more text>
      DWiJL+OFeg9kawcUL6hQ8JeXPhlImG6RTUffma9+iGQyyBMCGd1l
      -----END RSA PRIVATE KEY-----
```

## Behavior

### `check`: Check for changes to the branch set.

The repository is cloned (or pulled if already present), all remote branches
are enumerated, and compared to the existing set of branches.

If any branches are new or removed, a new version is emitted including the
delta.

### `in`: Produce the version's info as files.

Produces the following files based on the version being fetched:

* `branches`: A file containing the list of current branches, one per line.
* `added`: A file containing the newly cretated branches, one per line.
* `removed`: A file containing the branches that have been removed, one per
  line.


### `out`: No-op.

*Not implemented.*
