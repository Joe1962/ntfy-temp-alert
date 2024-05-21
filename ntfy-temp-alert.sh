#!/bin/bash 
#
# ntfy-temp-alert.sh
# by Joe1962
# Send a ntfy alert on temperature over threshold.
# version 0.0.1
#
# Dependencies: bash, bc, curl.
#
# set up in /etc/crontab.
# example every 1 minute:
# * * * * * root /root/scripts/ntfy-temp-alert.sh >/dev/null 2>&1
# example every 5 minutes:
# /5 * * * * root /root/scripts/ntfy-temp-alert.sh >/dev/null 2>&1
#

# NTFY server parameters:
NTFY_SERVER="http://ntfy.cenpalab.cu"
PUB_USER="server_ntfy"		# RO user that handles notifications for servers...
PUB_USER_PW="123"
PUB_TOPIC="temp_alert"		# NTFY topic for temperature alerts...

# HOST parameters:
HOST=`hostname`
T_THRESHOLD=50000			# Temperature alert threshold. Adapt to your hardware...
T_THRESHOLD_PRINT=`echo $(($T_THRESHOLD / 1000))`

# SCRIPT parameters:
SHOW_DECIMALS="Y"			# 'Y' if you want temp with decimals, 'N' if not...
ALWAYS_SEND_TEMP="N"		#send temperature regardless of threshold...

TIME=$(date +%F-%k:%M:%S)
TEMP=`cat /sys/class/thermal/thermal_zone0/temp`			# Adapt to your hardware...

if [[ $SHOW_DECIMALS = "Y" ]]
then
	TEMP_PRINT=`echo "scale=2; $TEMP/1000" | bc`
else
	TEMP_PRINT=`echo $(($TEMP / 1000))`
fi

if [ $TEMP -gt $T_THRESHOLD ];
then
	# push to ntfy:
	curl -H "X-Priority: 5" -u $PUB_USER":"$PUB_USER_PW -d "TEMP ALERT $HOST excede $T_THRESHOLD_PRINT @ $TIME" $NTFY_SERVER"/"$PUB_TOPIC >> /dev/null 2>&1 & 
else
	if [ $ALWAYS_SEND_TEMP  = "Y" ];
	then
		curl -u $PUB_USER":"$PUB_USER_PW -d "TEMP de $HOST = $TEMP_PRINT"C" @ $TIME" $NTFY_SERVER"/"$PUB_TOPIC >> /dev/null 2>&1 & 
	fi
fi

