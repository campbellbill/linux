#!/bin/bash
#==========================================================================================#
# Author:	Bill Campbell
# Written On:	2012.Mar.02
# Modified On:	2015.Aug.06
#
# Meets the criteria for a Full DOD Standard Disk Wipe if used with a minimum of 7 passes.
#
# Change Log
# 2012.03.02 by Bill Campbell
# Initial Script
#	This is a script to wipe the specified device to the Department of Defense
#	standards. This means that it writes ZERO's to every sector on the drive a minimum
#	of seven (7) times. Use this script to wipe the hard drives of any systems being
#	decommissioned.
#
# 2012.Mar.07
#	Minor bug fixes or code rearrangement and wording changes.
# 2012.Mar.13
#	Corrected the wipe commands so that they will do more than the first 5.1 GB on
#	each drive.
# 2015.Aug.06
#	Modified to allow for a smaller number of passes.
#	Modified from 1k to 4k block sizes.
#==========================================================================================#


#==========================================================================================#
# Used to grab the arguments from the commandline if any exist.
#==========================================================================================#
# Used to hold the device that the user wants to wipe...
DevSd=$1
# used for the number of times to run the command...
WipePassCnt=$2

#==========================================================================================#
# Please check the options and adjust to your specifics.
#==========================================================================================#
echo -=- Starting the Script...
echo -=-
echo -=- Checking the parameters passed in...

# Check the Left four (4) characters of a string...
# ${var1:0:4} means the first four characters of $var1
#if [ "${var1:0:4}" == "mtu " ]; then
#	<commands>
#fi

if [ "${DevSd:0:2}" != "sd" ]; then
	if [ "${DevSd:0:2}" != "hd" ]; then
		echo -e "Error - Device node must begin with 'sd' or 'hd' otherwise we don't know where to write the URANDOM data and ZERO's!"
		echo -e "\tSyntax : $0 'DeviceNode' 'WipePassCount'"
        	echo -e "\tExample:"
	        echo -e "\t\t$0 sdb 7"
		exit 1
	fi
fi

if [ ${WipePassCnt} -lt 2 ]; then
#	echo -e "Error - Number of wipe passes CANNOT be less than the 'Department of Defense' standard of 7 passes!"
	echo -e "Error - Number of wipe passes CANNOT be less than 2 passes!"
	echo -e "\tSyntax : $0 'Device' 'WipePassCount'"
	echo -e "\tExample:"
#	echo -e "\t\t$0 sdb 7"
	echo -e "\t\t$0 sdb 2"
	exit 1
#fi
elif [ ${WipePassCnt} -gt 99 ]; then
	echo -e "Error - Number of wipe passes CANNOT exceed 99 passes at this time."
	echo -e "\tSyntax : $0 'Device' 'WipePassCount'"
	echo -e "\tExample:"
	echo -e "\t\t$0 sdb 7"
	exit 1
fi

for (( i = 1; i <= ${WipePassCnt}; i++ ))
do
	echo -e "Wipe Pass $i"
	echo -e "\tWriting URANDOM data to device /dev/${DevSd} ..."
	dd if=/dev/urandom of=/dev/${DevSd} bs=4k
	# count=5000000
	echo -e "\tWriting ZERO's to device /dev/${DevSd} ..."
	dd if=/dev/zero of=/dev/${DevSd} bs=4k
	# count=5000000
done

echo -e "WIPE COMPLETE!!! \nThe ${WipePassCnt} passes of writing URANDOM data and ZERO's to /dev/${DevSd} \nhas DESTROYED ALL DATA on the drive/device."
