# Addon Tests

kubeaddons-enterprise-tests use KUTTL for testing.

### Tests structure

Tests are added in same structure as in original `kubeaddons-enterprise`
 repository structure.

Example:
```
└── tests
    └── kubeaddons-enterprise
        └── addons
            ├── cassandra
                ├── 0.x
                    └── cassandra-install
                        ├── 00-assert.yaml
                        ├── 00-install.yaml
                        ├── 01-assert.yaml
                        └── 01-update.yaml

```
