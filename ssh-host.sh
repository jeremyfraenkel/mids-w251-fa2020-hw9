#!/bin/bash

DNSNAMES=($(jq -r '.[]|.[]|.Instances|.[]|.PublicDnsName' instances.json))

INSTIDX=${1:-0}
INSTANCE=${DNSNAMES[$INSTIDX]}

echo "ssh-ing into host ${INSTANCE}..."
ssh -i ~/.w251hw3.pem ubuntu@${INSTANCE}
