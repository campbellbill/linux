#!/bin/bash
echo "Remediate Repos started."

## create dirs for backup
mkdir -p /remediation/etc/yum.repos.d
chmod -R 600 /remediation
chown -R root /remediation

## backup old repo files
if ! [ -z "$(ls -A /etc/yum.repos.d)" ]
then
    mv /etc/yum.repos.d/*  /remediation/etc/yum.repos.d/
fi

if [[ -r '/etc/centos-release' ]]; then
	wget -O /etc/yum.repos.d/pearson_monthly.repo http://10.25.5.80/repos/yum_repo_files/centos_pearson_monthly.repo && \
	wget -O /etc/yum.repos.d/pearson_base.repo http://10.25.5.80/repos/yum_repo_files/centos_pearson_base.repo
elif [[ -r '/etc/redhat-release' ]]; then
	wget -O /etc/yum.repos.d/pearson_monthly.repo http://10.25.5.80/repos/yum_repo_files/rhel_pearson_monthly.repo && \
	wget -O /etc/yum.repos.d/pearson_base.repo http://10.25.5.80/repos/yum_repo_files/rhel_pearson_base.repo
fi

yum clean all; yum repolist; yum update -y




# function get_distro_name {
#     if [[ -r '/etc/lsb-release' ]]; then
#         . /etc/lsb-release
#         [[ "$DISTRIB_ID" ]] && n="$DISTRIB_ID"
#     elif [[ -r '/etc/release' ]]; then
#         n=`head -1 /etc/release | sed 's/ *\([[^0-9]]*\) [0-9].*/\1/'`
#     elif [[ -r '/etc/arch-release' ]]; then
#         n="Arch Linux"
#     elif [[ -r '/etc/debian_version' ]]; then
#         n='Debian'
#     elif [[ -r '/etc/gentoo-release' ]]; then
#         n='Gentoo'
#     elif [[ -r '/etc/knoppix-version' ]]; then
#         n='Knoppix'
#     elif [[ -r '/etc/mandrake-release' ]]; then
#         n='Mandrake'
#     elif [[ -r '/etc/pardus-release' ]]; then
#         n='Pardus'
#     elif [[ -r '/etc/puppyversion' ]]; then
#         n='Puppy Linux'
#     elif [[ -r '/etc/redhat-release' ]]; then
#         n='Red Hat'
#     elif [[ -r '/etc/sabayon-release' ]]; then
#         n='Sabayon'
#     elif [[ -r '/etc/slackware-version' ]]; then
#         n='Slackware'
#     elif [[ -r '/etc/SuSE-release' ]]; then
#         n='SuSE'
#     elif [[ -r '/etc/xandros-desktop-version' ]]; then
#         n='Xandros'
#     elif [[ -r '/etc/zenwalk-version' ]]; then
#         n="Zenwalk"
#     fi
#     [[ "${n:-}" = '' ]] &&  \echo "ERROR: Could not determine the distro name" >&2 && \exit 1
# } # get_distro_name
