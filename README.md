# kubeaddons-enterprise-tests

This repository hosts tests for the `github.com/mesosphere/kubeaddons-enterprise` repository. 


`mesosphere/kubeaddons-enterprise` is hosted as default catalog in many kubernetes clusters. The intention is to keep that repository clean of any overhead that might break the catalog integration.


## Testing from kubeaddons-enterprise

- Clone this repo inside the kubeaddons-enterprise
- Run kubeaddons-enterprise-tests/run-tests.sh



## Testing a branch of kubeaddons-enterprise from this repository

```
export TESTING_BRANCH=dev
make kind-test
```

The above command will clone the git branch `TESTING_BRANCH` of `kubeaddons-enterprise` in local path and
run the tests for all addons using a KIND cluster


## Adding tests

`kubeaddons-enterprise` repository is used as default backend in many 
Konvoy Clusters. For that reason each addon in the `kubeaddons-enterprise` 
you need to add a respective test in this repository.

For example to add tests for cassandra `0.x` addon, add the KUTTL based 
steps with a directory structure like: 
```
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
