#!/bin/bash
ENV=$1
STATUS=$2
MESSAGE="Deploy ${CI_PROJECT_NAME} to ${ENV} ${STATUS}"

curl -X POST -H "Content-Type: application/json" \
  -d "{\"text\":\"${MESSAGE}\"}" \
  ${SLACK_WEBHOOK_URL}

# Ghi log audit
echo "$(date +%FT%T%z) | ${CI_USER_NAME} | ${MESSAGE}" >> /var/log/audit.log