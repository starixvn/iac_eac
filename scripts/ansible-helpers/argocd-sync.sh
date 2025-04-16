#!/bin/bash
set -eo pipefail

argocd login ${ARGOCD_SERVER} --grpc-web --insecure --username admin --password ${ARGOCD_TOKEN}

if [[ -n "$APP" ]]; then
  # Single app sync
  argocd app sync ${APP}-${ENV} --grpc-web --insecure
  argocd app wait ${APP}-${ENV} --grpc-web --insecure --health
else
  # Full sync
  for app in $(ls argocd/apps); do
    argocd app sync ${app}-${ENV} --grpc-web --insecure
    argocd app wait ${app}-${ENV} --grpc-web --insecure --health
  done
fi