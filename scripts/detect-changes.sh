#!/bin/bash
set -eo pipefail

# Detect changed application based on git diff or tag pattern
function detect_changed_app() {
  if [[ "$1" =~ ^deploy-(.+)-(.+)$ ]]; then
    # Extract from tag for deploy jobs
    echo "${BASH_REMATCH[1]}"
  else
    # Detect changed apps from file changes
    if [[ -d "applications" ]]; then
      # IaC repo pattern
      changed=$(git diff --name-only "$1" | grep -oE 'applications/([^/]+)/' | cut -d'/' -f2 | sort | uniq)
    elif [[ -d "argocd/apps" ]]; then
      # EaC repo pattern
      changed=$(git diff --name-only "$1" | grep -oE 'argocd/apps/([^/]+)/' | cut -d'/' -f3 | sort | uniq)
    fi
    
    if [ -z "$changed" ]; then
      echo "No application changes detected"
      exit 0
    elif [ $(echo "$changed" | wc -l) -gt 1 ]; then
      echo "Multiple applications changed: $changed"
      exit 1
    else
      echo "$changed"
    fi
  fi
}

# Determine reference based on pipeline source
if [[ "$CI_PIPELINE_SOURCE" == "merge_request_event" ]]; then
  REF="origin/$CI_MERGE_REQUEST_TARGET_BRANCH_NAME"
elif [[ -n "$CI_COMMIT_TAG" ]]; then
  REF="$CI_COMMIT_TAG"
else
  REF="HEAD~1"
fi

# Execute detection
detect_changed_app "$REF"