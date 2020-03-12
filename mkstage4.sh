#! /bin/bash
#==========================================================================================#
# Author: Bill Campbell                                                                    #
# Modified Date: 2012.Jul.12                                                               #
#                                                                                          #
# Full System Backup script for Gentoo Linux                                               #
#                                                                                          #
# Change Log                                                                               #
# 2011.May.06 by Bill Campbell                                                             #
# Added symmetric & asymmetric encryption options to the script using GnuPG                #
# to accomodate secure environments                                                        #
# Date: 2011.May.06 by Bill Campbell                                                       #
# Initial Script                                                                           #
# Adapted from backupHome.sh by fdavid                                                     #
# Adapted from mkstage4.sh by nianderson                                                   #
# This is a script to create a custom stage 4 tarball (System and boot backup)             #
# I use this script to make a snapshot of my system. Meant to be done weekly in my case.   #
#==========================================================================================#

#==========================================================================================#
# Used to grab the arguments from the commandline if any exist.
#==========================================================================================#
# SWITCH=${1:-on}
SWITCH=${1:-off}
#SWITCH=$1

#==========================================================================================#
# Please check the options and adjust to your specifics.
#==========================================================================================#
echo -=- Starting the Backup Script...
echo -=-
echo -=- Setting the variables...

#==========================================================================================#
# The location of the stage 4 tarball.
# Be sure to include a trailing /
#==========================================================================================#
stage4Location=/mnt/stage4/stage4-$(hostname)/

#==========================================================================================#
# Setup the date format to be used in the name of the tarball.
#==========================================================================================#
tbzDate=$(eval date +%Y.%m.%d)

#==========================================================================================#
# The name of the stage 4 tarball.
#==========================================================================================#
archive="${stage4Location}$(hostname)-stage4-${tbzDate}.tbz2"

#==========================================================================================#
# Directories/files that will be exluded from the stage 4 tarball.
#
# Add directories that will be recursively excluded, delimited by a space.
# Be sure to omit the trailing /
#==========================================================================================#
dir_excludes="/mnt/* /dev /proc /sys /tmp /var/tmp /usr/local/portage /usr/portage /home/*/.mozilla/firefox/*.default/Cache /home/*/.opera/cache /home/*/vmware"
# /usr/src/*"
# /home/bcampbell/vmware /home/bcampbell/.mozilla/firefox/*.default/Cache /home/bcampbell/.opera/cache"
# /root/vmware /root/.mozilla/firefox/*.default/Cache /root/.opera/cache"

#==========================================================================================#
# Add files that will be excluded, delimited by a space.
# You can use the * wildcard for multiple matches.
# There should always be ${archive} listed or bad things will happen.
#==========================================================================================#
file_excludes="/etc/mtab ${archive} /home/*/.kde4/share/apps/nepomuk/repository/main/*.* /home/*/.kde4/share/apps/nepomuk/repository/main/data/virtuosobackend/*.*"
# .bash_history

#==========================================================================================#
# Combine the two *-excludes variables into the ${excludes} variable
#==========================================================================================#
excludes="$(for i in ${dir_excludes}; do if [ -d $i ]; then \
    echo -n " --exclude=$i/*"; fi; done) $(for i in ${file_excludes}; do \
    echo -n " --exclude=$i"; done)"

#==========================================================================================#
# The options for the stage 4 tarball.
#==========================================================================================#
#tarOptions="${excludes} --create --absolute-names --bzip2 --verbose --totals --file"
tarOptions="${excludes} --create --absolute-names --bzip2 --totals --file"

echo -=- Done setting variables!
echo stage4Location = ${stage4Location}
echo -e " "
echo tbzDate = ${tbzDate}
echo -e " "
echo archive = ${archive}
echo -e " "
echo dir_excludes = ${dir_excludes}
echo -e " "
echo file_excludes = ${file_excludes}
echo -e " "
echo excludes = ${excludes}
echo -e " "
echo tarOptions = ${tarOptions}
echo -e " "
echo SWITCH = ${SWITCH}
echo -e " "
echo -=- Done!
echo -=-
sleep 10

#==========================================================================================#
# Mounting the boot partition
#==========================================================================================#
echo -=- Mounting boot partition...
mount /boot
sleep 1
echo -=- Done!
echo -=-

#==========================================================================================#
# Creating a copy of the boot partition (copy /boot to /bootcpy).
# This will allow the archiving of /boot without /boot needing to be mounted.
# This will aid in restoring the system.
#==========================================================================================#
echo -e "-=- Copying /boot to /bootcpy ...\n"
echo -e "cp -R /boot /bootcpy"
cp -R /boot /bootcpy
echo -=- Done!
echo -=-

#==========================================================================================#
# Unmounting /boot
#==========================================================================================#
echo -=- Unmounting /boot then sleeping for a second...
umount /boot
sleep 1
echo -=- Done!
echo -=-

#==========================================================================================#
# Creating the stage 4 tarball.
#==========================================================================================#
echo -=- Creating custom stage 4 tarball \=\=\> ${archive}
echo -=-
echo -=- Running the following command:
echo tar ${tarOptions} ${archive} /;
tar ${tarOptions} ${archive} /;
echo -=- Done!

#==========================================================================================#
# Uncomment this portion to encrypt the stage4 using asymmetric encryption with GnuPG
# To get a list of available ciphers on your machine do #gpg --version
# Note: only aes aes192 aes256 and twofish should be used for large files (~1Gig & larger)
# To Restore: (cat together if split) and #gpg $(hostname)-stage4-${tbzDate}.tbz2.gpg
#==========================================================================================#
#echo -=- Starting Encryption Process usung asymmetric encryption with a public key  -=-
#cd ${stage4Location}
#gpg --encrypt --batch --recipient [MY_PUB_KEY] --cipher-algo twofish --output ${archive}.gpg ${archive}
#rm ${archive}
#archive=${stage4Location}$(hostname)-stage4-${tbzDate}.tbz2.gpg

#==========================================================================================#
# Uncomment this portion to encrypt the stage4 using symmetric encryption with GnuPG
# # To get a list of ciphers on your machine do #gpg --version
# Note: only aes aes192 aes256 and Twofish should be used for large files (~1 gig & larger)
# To Restore: (cat together if split) and #gpg $(hostname)-stage4-${tbzDate}.tbz2.gpg
#==========================================================================================#
#echo -=- Starting Encryption Process usung symmetric encryption with a password  -=-
#cd ${stage4Location}
#pass=PLEASE_CHANGE_ME_I_BEG_YOU!
#echo $pass | gpg --batch --cipher-algo twofish --passphrase-fd 0 --symmetric ${archive}
#rm ${archive}
#archive=${stage4Location}$(hostname)-stage4-${tbzDate}.tbz2.gpg

#==========================================================================================#
# Split the stage 4 tarball in cd size tar files.
# To combine the tar files after copying them to your
# chroot do the following: "cat *.tbz2 >> $(hostname)-stage4-${tbzDate}.tbz2".
# or if encrypted do the following: "cat *.tbz2.gpg >> $(hostname)-stage4-${tbzDate}.tbz2.gpg".
# Uncomment the following lines to enable this feature.
#==========================================================================================#
#echo -=- Splitting the stage 4 tarball into CD size tar files...
#split --bytes=700000000 ${archive} ${archive}.
#echo -=- Done!

#==========================================================================================#
# Removing the directory /bootcpy.
# You may safely uncomment this if you wish to keep /bootcpy.
#==========================================================================================#
echo -=- Removing the directory /bootcpy ...
echo -e "rm -rf /bootcpy"
rm -rf /bootcpy
echo -=- Done!
echo -=-

#==========================================================================================#
# Backup any VMware images. Change to the known location of the images.
#==========================================================================================#
case "$SWITCH" in
   on|On|ON)
        echo -e "-=- Backing up VMware images -=-\n"
	echo -e "cp -R -p -u -f /home/bcampbell/vmware ${stage4Location}"
	cp -R -p -u -f /home/bcampbell/vmware ${stage4Location}
	echo -e "-=- Done!\n"
	echo -e "-=-\n"
   ;;
   off|Off|OFF)
	echo -e "-=- Not backing up VMware images. It is turned off by default or commandline switch. -=-\n"
        echo -e "During a routine backup we do not backup the VMware Workstation images.\nThey are only backed up when the commandline switch is set to on."
   ;;
   *)
        echo -e "\nInvalid command line option.  USAGE: $0 <on|off>\n"
        echo -e "This will turn on or off the portion of the script that will backup the VMware Workstation images."
        echo -e "During a routine backup we do not backup the VMware Workstation images.\nThey are only backed up when the commandline switch is set to on."
        exit
   ;;
esac

#==========================================================================================#
# This is the end of the line.
#==========================================================================================#
echo -=- The Backup Script has completed!
