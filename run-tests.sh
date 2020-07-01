#!/usr/bin/env bash
set -euo pipefail

TESTING_BRANCH=${TESTING_BRANCH:-dev}
KUBEADDONS_ENTERPRISE_PATH=${KUBEADDONS_ENTERPRISE_PATH:-kubeaddons-enterprise}
KUBEADDONS_ENTERPRISE_TESTS_PATH="./tests"
KUTTL_TEST_CONFIGURATION_PATH="kuttl-test.yaml"
printf "testing kubeaddons-enterprise branch %s\n" "$TESTING_BRANCH"

if [ -d "./addons" ]
then
  printf "Running inside the kubeaddons-enterprise repository"
  KUBEADDONS_ENTERPRISE_PATH="."
  KUBEADDONS_ENTERPRISE_TESTS_PATH="kubeaddons-enterprise-tests/tests/kubeaddons-enterprise"
  KUTTL_TEST_CONFIGURATION_PATH="kubeaddons-enterprise-tests/kuttl-test.yaml"
elif [ -d "$KUBEADDONS_ENTERPRISE_PATH" ]
then
  git -C "${KUBEADDONS_ENTERPRISE_PATH}" checkout ${TESTING_BRANCH}
else
  git clone --depth 1 https://github.com/mesosphere/kubeaddons-enterprise.git --branch ${TESTING_BRANCH} --single-branch
fi

KUBEADDONS_ENTERPRISE_ABS_PATH=$(realpath -L "${KUBEADDONS_ENTERPRISE_PATH}")

for i in $(find "${KUBEADDONS_ENTERPRISE_PATH}"/addons -mindepth 2 -maxdepth 2 -type d)
do
    printf "addon directory detected: %s\n" "$i"
    if [ ! -d "${KUBEADDONS_ENTERPRISE_TESTS_PATH}/$i" ]
    then
      printf "missing tests for addon directory %s\n" "${KUBEADDONS_ENTERPRISE_TESTS_PATH}/$i"
      exit 1
    fi
done

printf "Path %s\n" "$KUBEADDONS_ENTERPRISE_ABS_PATH"
for i in $(find "${KUBEADDONS_ENTERPRISE_PATH}"/addons -mindepth 2 -maxdepth 2 -type d)
do
    mkdir -p dist/${i////_}
    KUBEADDONS_ENTERPRISE_ABS_PATH="$KUBEADDONS_ENTERPRISE_ABS_PATH" kubectl-kuttl test --artifacts-dir=./dist/${i////_} --config=${KUTTL_TEST_CONFIGURATION_PATH} ${KUBEADDONS_ENTERPRISE_TESTS_PATH}/$i --report xml
done
