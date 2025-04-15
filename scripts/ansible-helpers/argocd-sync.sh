#!/bin/bash
set -eo pipefail

echo "🔄 Syncing ArgoCD applications"
cd ${CI_PROJECT_DIR}/argocd

# Login to ArgoCD
argocd login ${ARGOCD_SERVER} ${ARGOCD_OPTS} --username admin --password ${ARGOCD_TOKEN}

# Sync each application
for app in $(ls apps); do
  echo "Syncing $app..."
  argocd app sync $app ${ARGOCD_OPTS}
  argocd app wait $app ${ARGOCD_OPTS} --health
  argocd app get $app ${ARGOCD_OPTS}
done