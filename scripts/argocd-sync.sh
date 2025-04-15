#!/bin/bash
set -eo pipefail

APP=$1
ENV=${2:-dev}

argocd app sync $APP \
  --server "${ARGOCD_SERVER}" \
  --grpc-web \
  --environment "$ENV"

# Health check
argocd app wait $APP \
  --health \
  --timeout 300