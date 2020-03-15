#!/bin/bash

if kubectl config current-context > /dev/null 2>&1; then
    printf "☸k8s"
fi
