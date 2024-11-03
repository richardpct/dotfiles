#!/usr/bin/env bash

set -e -u

function next_mounth() {
  local CURRENT_MOUNTH=$1
  local DECEMBER_MOUNTH=12
  local NEXT_MOUNTH=$((${CURRENT_MOUNTH#0} + 1))

  if [ $NEXT_MOUNTH -ge $DECEMBER_MOUNTH ]; then
    NEXT_MOUNTH=$DECEMBER_MOUNTH
  fi

  printf %02d $NEXT_MOUNTH
}

function aws_cost() {
  local START_DATE=$(date +"%Y-%m-01")
  local NEXT_MOUNTH=$(next_mounth $(date +"%m"))
  local END_DATE="$(date +"%Y")-$NEXT_MOUNTH-01"

  aws ce get-cost-and-usage \
    --time-period "Start=$START_DATE,End=$END_DATE" \
    --metrics 'UnblendedCost' \
    --granularity 'MONTHLY' \
    --query 'ResultsByTime[*].Total.[UnblendedCost]' \
    --output 'json' \
    | jq -r '.[0].[0].Amount' | sed -e 's#\([^.]*\.[0-9]\{2\}\).*#aws: \$\1#'
}

CURRENT_AWS_COST=/tmp/aws_cost.txt
AWS_CONFIG=~/.aws/config
AWS_CRED=~/.aws/credentials
RETENTION=1440

if [[ -f $AWS_CONFIG && -f $AWS_CRED ]]; then
  if [ ! -f $CURRENT_AWS_COST ] || [ $(find $CURRENT_AWS_COST -mmin +${RETENTION} | wc -l) -eq 1 ]; then
    aws_cost > $CURRENT_AWS_COST
  fi
fi

cat $CURRENT_AWS_COST
