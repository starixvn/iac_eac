#!/bin/bash
set -eo pipefail

# Authenticate with GitLab API
curl --header "PRIVATE-TOKEN: ${CI_JOB_TOKEN}" \
  --request DELETE \
  "${GITLAB_API_URL}/projects/${CI_PROJECT_ID}/repository/tags/${CI_COMMIT_TAG}"

echo "Successfully deleted tag ${CI_COMMIT_TAG}"
#- curl --request DELETE --header "PRIVATE-TOKEN:$CI_JOB_TOKEN" $GITLAB_API_URL/projects/$CI_PROJECT_ID/repository/tags/$CI_COMMIT_TAG ;