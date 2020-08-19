#!/usr/bin/env bash
set -euo pipefail

TESTING_BRANCH=${TESTING_BRANCH:-dev}
KUBEADDONS_REPO=${KUBEADDONS_REPO:-kubeaddons-enterprise}
KUBEADDONS_TESTS_PATH="$(dirname $0)/tests"
KUTTL_TEST_CONFIGURATION_PATH="${KUBEADDONS_TESTS_PATH}/${KUBEADDONS_REPO}/kuttl-test.yaml"
printf "testing %s branch %s\n" "${KUBEADDONS_REPO}" "${TESTING_BRANCH}"

if [ -d "./addons" ]
then
  printf "Running inside the %s repository\n" "${KUBEADDONS_REPO}"
  KUBEADDONS_REPO="."
elif [ -d "${KUBEADDONS_REPO}" ]
then
  git -C "${KUBEADDONS_REPO}" checkout ${TESTING_BRANCH}
else
  git clone --depth 1 https://github.com/mesosphere/${KUBEADDONS_REPO}.git --branch ${TESTING_BRANCH} --single-branch
fi

KUBEADDONS_ABS_PATH=$(realpath -L "${KUBEADDONS_REPO}")

for i in $(find "${KUBEADDONS_REPO}"/addons -mindepth 2 -maxdepth 2 -type d)
do
    printf "addon directory detected: %s\n" "${i}"
    if [ ! -d "${KUBEADDONS_TESTS_PATH}/${i}" ]
    then
      printf "missing tests for addon directory %s\n" "${KUBEADDONS_TESTS_PATH}/${i}"
      exit 1
    fi
done

printf "Path %s\n" "${KUBEADDONS_ABS_PATH}"
for i in $(find "${KUBEADDONS_REPO}"/addons -mindepth 2 -maxdepth 2 -type d)
do
    printf "running tests in %s\n" "${KUBEADDONS_TESTS_PATH}/${i}"
    mkdir -p dist/${i////_}
    KUBEADDONS_ABS_PATH="${KUBEADDONS_ABS_PATH}" kubectl-kuttl test --artifacts-dir=./dist/${i////_} --config=${KUTTL_TEST_CONFIGURATION_PATH} ${KUBEADDONS_TESTS_PATH}/${i} --report xml
done
