#!/bin/bash

###
#  Shell script for registering agents automatically with the 
#  Copyright (C) 2020 Vsec, Inc. All rights reserved.
#  Vsec.com
#
#  This program is a free software; you can redistribute it
#  and/or modify it under the terms of the GNU General Public
#  License (version 2) as published by the FSF - Free Software
#  Foundation.
###

WORKSPACE=$1
HOSTNAME=$2
DIRECTORY_PACKAGES=$3
echo -e "You enter the path installation package is:"
echo -e "$DIRECTORY_PACKAGES"

if [ "$#" -ne 3 ]; then
    echo "syntax error!!! You should provide both WORKSPACE NAME and AGENT HOSTNAME DIRECTORY_PACKAGES"
    echo "For ex : vadar-centos.sh vadar kt01 /root/vadar-agent-4.1.2-1.msi"
fi

ROOT_UID=0 # Only users with $UID 0 have root privileges.
E_XCD=86 # Can't change directory?
E_NOTROOT=87 # Non-root exit error.
# Run as root, of courese.
if [ "$UID" -ne "$ROOT_UID" ]
then
    echo "Must be root to run this script."
    exit $E_NOTROOT
fi

#### Install wazuh agent 
WAZUH_AGENT_GROUP="default,$WORKSPACE" WAZUH_AGENT_NAME="$WORKSPACE-$HOSTNAME" \
rpm -ivh --force $DIRECTORY_PACKAGES
STATUS=$?

#Enable Service
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl restart wazuh-agent
