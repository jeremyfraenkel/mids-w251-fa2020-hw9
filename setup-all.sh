#!/bin/bash
# set -x

# This script sets up the instances in instances.json
RED='\033[0;31m'
GRN='\033[0;32m'     
LGRN='\033[1;32m'
NC='\033[0m'

echoinfo() { echo -e "${GRN}${1}${NC}"; }
echoimp() { echo -e "${LGRN}${1}${NC}"; }
echoissue() { echo -e "${RED}${1}${NC}"; }

# from https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}"; }

DNSNAMES=$(jq -r '.[]|.[]|.Instances|.[]|.PublicDnsName' instances.json)
for inst in $DNSNAMES
do
    echoimp "Setting up $inst..."
    ssh -o StrictHostKeyChecking=accept-new -i ~/.w251hw3.pem ubuntu@${inst} < setup-instance.sh
done

echoimp "Hosts have all been configured; openseq2seq container is running on all instances."

NAMES=($DNSNAMES)
PRIV_IPS=$(jq -r '.[]|.[]|.Instances|.[]|.PrivateIpAddress' instances.json)
IP_LIST=$(join_by , $PRIV_IPS)

TESTMPI="docker exec openseq2seq bash -c \"mpirun -n 4 -H ${IP_LIST} --allow-run-as-root hostname\""
ssh -i ~/.w251hw3.pem ubuntu@${NAMES[1]} "bash -c '$TESTMPI'"
