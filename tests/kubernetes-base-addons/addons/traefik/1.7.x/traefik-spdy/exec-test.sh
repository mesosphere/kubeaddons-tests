#!/bin/bash
set -euo pipefail

cleanup() {
    rc=$?
    rm ${TMPKUBECONFIG}
    exit $rc
}

OUTDIR=${ARTIFACT:-/tmp}
SERVER=$(kubectl -n kubeaddons get svc traefik-kubeaddons \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}")
SECRET=$(kubectl -n "${NAMESPACE}" get serviceaccount kuttlaccount -o jsonpath="{ .secrets[0].name }")
TOKEN=$(kubectl -n "${NAMESPACE}" get secret "${SECRET}" -o go-template="{{.data.token | base64decode }}")
TMPKUBECONFIG=$(mktemp)
trap cleanup EXIT
cp "${KUBECONFIG}" "${TMPKUBECONFIG}"
mkdir -p ${OUTDIR}

kubectl --kubeconfig "${TMPKUBECONFIG}" config set-credentials kuttl --token="${TOKEN}"
kubectl --kubeconfig "${TMPKUBECONFIG}" config set-context kuttl --cluster=cluster --user=kuttl
kubectl --kubeconfig "${TMPKUBECONFIG}" config use-context kuttl
kubectl --kubeconfig "${TMPKUBECONFIG}" --namespace "${NAMESPACE}" -v 9 -s https://"${SERVER}"/testpath exec -ti testpod -- echo SUCCESS 2>${OUTDIR}/kubectl-spdy-exec.log | grep SUCCESS
