ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

KUBEADDONS_REPO ?= kubeaddons-enterprise
TESTING_BRANCH ?= dev

KIND_VERSION ?= 0.8.1
KUBEADDONS_TEST_KUBECONFIG ?= kubeconfig
KUBERNETES_VERSION ?= 1.17.5
KUTTL_VERSION ?= 0.6.1

OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
MACHINE=$(shell uname -m)
KIND_MACHINE=$(shell uname -m)
ifeq "$(KIND_MACHINE)" "x86_64"
  KIND_MACHINE=amd64
endif

export PATH := $(shell pwd)/bin/:$(PATH)

ARTIFACTS=$(shell realpath dist)

bin/kind_$(KIND_VERSION):
	mkdir -p bin/
	curl -Lo bin/kind_$(KIND_VERSION) https://github.com/kubernetes-sigs/kind/releases/download/v$(KIND_VERSION)/kind-$(OS)-$(KIND_MACHINE)
	chmod +x bin/kind_$(KIND_VERSION)

bin/kind: bin/kind_$(KIND_VERSION)
	ln -sf ./kind_$(KIND_VERSION) bin/kind

bin/kubectl-kuttl_$(KUTTL_VERSION):
	mkdir -p bin/
	curl -Lo bin/kubectl-kuttl_$(KUTTL_VERSION) https://github.com/kudobuilder/kuttl/releases/download/v$(KUTTL_VERSION)/kubectl-kuttl_$(KUTTL_VERSION)_$(OS)_$(MACHINE)
	chmod +x bin/kubectl-kuttl_$(KUTTL_VERSION)

bin/kubectl-kuttl: bin/kubectl-kuttl_$(KUTTL_VERSION)
	ln -sf ./kubectl-kuttl_$(KUTTL_VERSION) bin/kubectl-kuttl


.PHONY: create-kind-cluster
create-kind-cluster: $(KUBEADDONS_TEST_KUBECONFIG)

$(KUBEADDONS_TEST_KUBECONFIG): bin/kind bin/kubectl-kuttl
		@export KIND_TMP=$(shell mktemp -d) && \
		sed -e s/DOCKER_USERNAME/"$(DOCKERHUB_ROBOT_USERNAME)"/ -e s/DOCKER_PASSWORD/"$(DOCKERHUB_ROBOT_TOKEN)"/ $(ROOT_DIR)/hack/kind-config.yaml > $${KIND_TMP}/kind-config.yaml
		KUBECONFIG=$(KUBEADDONS_TEST_KUBECONFIG)
		if test ! -f $KUBECONFIG 
		then
		  bin/kind create cluster --wait 10s --image=kindest/node:v$(KUBERNETES_VERSION) --config $${KIND_TMP}/kind-config.yaml
		  rm -rf $${KIND_TMP}
		fi

.PHONY: kind-test
kind-test: create-kind-cluster
	KUBEADDONS_REPO=$(KUBEADDONS_REPO) TESTING_BRANCH=$(TESTING_BRANCH) KUBEADDONS_TEST_KUBECONFIG=$(KUBEADDONS_TEST_KUBECONFIG) $(ROOT_DIR)/run-tests.sh

.PHONY: clean
clean:
	KUBECONFIG=$(KUBEADDONS_TEST_KUBECONFIG) bin/kind delete cluster
	rm -f $(KUBEADDONS_TEST_KUBECONFIG)
	rm -rf $(ARTIFACTS)
	# delete the checked out repository
	rm -rf $(KUBEADDONS_REPO)
