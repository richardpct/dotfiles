#!/usr/bin/env bash

function aws_cost {
  START_DATE=$(date +"%Y-%m-01")
  END_DATE=$(date +"%Y-%m-%d")

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

if [[ -f $AWS_CONFIG && -f $AWS_CRED ]]; then
  if [ ! -f $CURRENT_AWS_COST ] || [ $(find $CURRENT_AWS_COST -mmin +10 | wc -l) -eq 1 ]; then
    aws_cost > $CURRENT_AWS_COST
  fi
fi

cat $CURRENT_AWS_COST
