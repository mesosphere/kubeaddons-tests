#!/usr/bin/env bash


TESTING_BRANCH=${TESTING_BRANCH:-dev}
KUBEADDONS_ENTERPRISE_PATH=${KUBEADDONS_ENTERPRISE_PATH:-kubeaddons-enterprise}
printf "testing kubeaddons-enterprise branch %s\n" "$TESTING_BRANCH"

if [ -d "$KUBEADDONS_ENTERPRISE_PATH" ]
then
  pushd $KUBEADDONS_ENTERPRISE_PATH
  git checkout ${TESTING_BRANCH}
  popd
else
  git clone --depth 1 https://github.com/mesosphere/kubeaddons-enterprise.git --branch ${TESTING_BRANCH} --single-branch
fi

KUBEADDONS_ENTERPRISE_ABS_PATH=$(realpath -L "${KUBEADDONS_ENTERPRISE_PATH}")

for i in $(find "${KUBEADDONS_ENTERPRISE_PATH}"/addons -mindepth 2 -type d)
do
    printf "addon directory detected: %s\n" "$i"
    if [ ! -d "./tests/$i" ]
    then
      printf "missing tests for addon directory %s\n" "./tests/$i"
      exit 1
    fi
done

go get github.com/jstemmer/go-junit-report
mkdir -p dist

printf "Path %s\n" "$KUBEADDONS_ENTERPRISE_ABS_PATH"
for i in $(find "${KUBEADDONS_ENTERPRISE_PATH}"/addons -mindepth 2 -type d)
do
    KUBEADDONS_ENTERPRISE_ABS_PATH="$KUBEADDONS_ENTERPRISE_ABS_PATH" kubectl-kuttl test tests/"$i" | tee /dev/fd/2 | go-junit-report -set-exit-code > dist/addons_test_report.xml
done
