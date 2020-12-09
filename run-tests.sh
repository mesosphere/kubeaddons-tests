#!/usr/bin/env bash
set -euo pipefail

TESTING_BRANCH=${TESTING_BRANCH:-dev}
KUBEADDONS_REPO=${KUBEADDONS_REPO:-kubeaddons-enterprise}
KUBEADDONS_TEST_KUBECONFIG=${KUBEADDONS_TEST_KUBECONFIG:-kubeconfig}
KUBEADDONS_TESTS_PATH="$(dirname "${0}")/tests"
KUTTL_TEST_CONFIGURATION_PATH="${KUBEADDONS_TESTS_PATH}/${KUBEADDONS_REPO}/kuttl-test.yaml"

run_test() {
    local ARTIFACT="dist/${1////_}"
    local KUBECONFIG="${KUBEADDONS_TEST_KUBECONFIG}"
    local TEST="${KUBEADDONS_TESTS_PATH}/${1}"
    export ARTIFACT KUBECONFIG TEST

    # if there are no tests, return
    if ! test "$( ls "${TEST}" )"; then
        return
    fi

    printf "running tests in %s\n" "${TEST}"
    mkdir -p "${ARTIFACT}"
    kubectl-kuttl test \
        --artifacts-dir="${ARTIFACT}" \
        --config="${KUTTL_TEST_CONFIGURATION_PATH}" \
        --report xml \
        "${TEST}"

}

printf "testing %s branch %s\n" "${KUBEADDONS_REPO}" "${TESTING_BRANCH}"

if [ -d "./addons" ]
then
  printf "Running inside the %s repository\n" "${KUBEADDONS_REPO}"
  KUBEADDONS_TESTS_PATH="${KUBEADDONS_TESTS_PATH}/${KUBEADDONS_REPO}"
  KUBEADDONS_REPO="."
elif [ -d "${KUBEADDONS_REPO}" ]
then
  git -C "${KUBEADDONS_REPO}" checkout "${TESTING_BRANCH}"
else
  git clone "https://github.com/mesosphere/${KUBEADDONS_REPO}.git" \
      --depth 1 \
      --branch "${TESTING_BRANCH}" \
      --single-branch
fi

ADDON_LIST=()
while IFS=  read -r -d $'\0'; do
    ADDON_LIST+=("$REPLY")
done < <(find "${KUBEADDONS_REPO}/addons" -maxdepth 2 -type d -print0)

KUBEADDONS_ABS_PATH=$(realpath -L "${KUBEADDONS_REPO}")
export KUBEADDONS_ABS_PATH
echo ${ADDON_LIST[*]}

for i in ${ADDON_LIST[*]}
do
    printf "addon directory detected: %s\n" "${i}"
    if [ ! -d "${KUBEADDONS_TESTS_PATH}/${i}" ]
    then
      printf "missing tests for addon directory %s\n" "${KUBEADDONS_TESTS_PATH}/${i} -- ignoring"
    fi
done

printf "Path %s\n" "${KUBEADDONS_ABS_PATH}"
for i in ${ADDON_LIST[*]}
do
    run_test "$i"
done
