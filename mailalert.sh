#!/bin/bash
 
if [[ $# -lt 3  ]] ; then
    echo -e "\nUsage:\n$0 <to> <subj> <body>  \n"
    exit -1
fi

to=$1
subject=$2
body=$3
 
cat <<EOF | /usr/bin/msmtp $to 
Subject: $subject
From: (Zabbix Monitoring)
$body
EOF