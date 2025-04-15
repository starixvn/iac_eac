#!/bin/bash
set -eo pipefail

APP=$1
ACTION=${2:-sync}

case "$ACTION" in
  sync)
    argocd app sync $APP --grpc-web
    ;;
  health)
    argocd app wait $APP --health --timeout 300
    ;;
  *)
    echo "Usage: $0 <app-name> [sync|health]"
    exit 1
    ;;
esac