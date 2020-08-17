# kubeaddons-tests

This repository hosts tests for kubeaddons repositories.

The intention of this repo is to keep kubeaddons repositories clean of any overhead that might break the catalog integration.

## Testing from kubeaddons repositories

- Clone this repo inside the repository
- Run kubeaddons-tests/run-tests.sh

## Testing a branch from this repository

```shell
make kind-test TESTING_BRANCH=dev KUBEADDONS_REPO=kubeaddons-enterprise
```

The above command will clone the git branch `dev` of `kubeaddons-enterprise` in local path and
run the tests for all addons using a [kind][kind] cluster.

## Adding tests

Add addon tests in the respective kubeaddons-repository directory:
`kubernetes-base-addons`,
`kubeaddons-enterprise`,
etc.

For example to add tests for cassandra `0.x` addon in the `kubeaddons-enterprise` repo, add the [kuttl][kuttl] based steps with a directory structure like:

```text
└── tests
    └── kubeaddons-enterprise
        └── addons
            ├── cassandra
                ├── 0.x
                    └── cassandra-install-0-x
                        ├── 00-assert.yaml
                        ├── 00-install.yaml
                        ├── 01-assert.yaml
                        └── 01-update.yaml

```

[kind]: https://github.com/kubernetes-sigs/kind
[kuttl]: https://github.com/kudobuilder/kuttl
