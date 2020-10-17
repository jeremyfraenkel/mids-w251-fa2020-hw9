#!/bin/bash
set -x

# This script starts the training process
RED='\033[0;31m'
GRN='\033[0;32m'     
LGRN='\033[1;32m'
NC='\033[0m'

echoinfo() { echo -e "${GRN}${1}${NC}"; }
echoimp() { echo -e "${LGRN}${1}${NC}"; }
echoissue() { echo -e "${RED}${1}${NC}"; }

# from https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-an-array-in-bash
function join_by { local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}"; }

PRIV_IPS=$(jq -r '.[]|.[]|.Instances|.[]|.PrivateIpAddress + ":1"' instances.json)
IP_LIST=$(join_by , $PRIV_IPS)
DNSNAMES=$(jq -r '.[]|.[]|.Instances|.[]|.PublicDnsName' instances.json)
NAMES=($DNSNAMES)
TRAINMPI="docker exec openseq2seq bash -c \"cd /opt/OpenSeq2Seq && nohup mpirun --allow-run-as-root -n 4 -H $IP_LIST -bind-to none -map-by slot --mca btl_tcp_if_include ens5 -x NCCL_SOCKET_IFNAME=ens5 -x NCCL_DEBUG=INFO -x LD_LIBRARY_PATH python run.py --config_file=/data/transformer-base.py --use_horovod=True --mode=train_eval &\""
ssh -i ~/.w251hw3.pem ubuntu@${NAMES[1]} "bash -c '$TRAINMPI'"
