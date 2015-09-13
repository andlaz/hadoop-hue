#!/usr/bin/env bash

# Translates relevant docker environment values
# to configure.rb parameters
# ----------------------------------------------

# Allow parameters to configure.rb to come from CONFIGURE_PARAMS as opposed to stdin
# This is to support parameterizing via Compose in particular. The two lines below are equivalent in effect:
# docker run -e "CONFIGURE_PARAMS=cassandra --dc daas-1 --calculate-tokens 1:1" -ti --name c1 --rm andlaz/hadoop-cassandra
# docker run -ti --name c1 --rm andlaz/hadoop-cassandra cassandra --dc daas-1 --calculate-tokens 1:1
P=${CONFIGURE_PARAMS:-$(echo $*)}
set -- $P

add_hue_options () {
	
	local opts=""
	
	if [ $NAMENODE_NAME ] && [ ! "$*" == *"--hdfs-default-fs"* ]; then opts="$opts --hdfs-default-fs hdfs://namenode:8020"; fi
	if [ $RESOURCEMANAGER_NAME ] && [ ! "$*" == *"--yarn-resource-manager-host"* ]; then opts="$opts --yarn-resource-manager-host resourcemanager --yarn-resource-manager-url http://resourcemanager:8088"; fi
	if [ $OOZIE_NAME ] && [ ! "$*" == *"--oozie-url"* ]; then opts="$opts --oozie-url http://oozie:11000/oozie"; fi
	if [ $HISTORYSERVER_NAME ] && [ ! "$*" == *"--history-server-url"* ]; then opts="$opts --history-server-url http://historyserver:19888"; fi
	
	echo $opts
}

case $1 in
	hue) ruby /root/configure.rb $* `add_hue_options $*` && supervisord -c /etc/supervisord.conf ;;
	help) cat << EOM
The image's entry point script will populate the following -parameters from Docker environment variables:
EOM
	echo -e "\nhue\t\t\t:" `add_hue_options $*` "\n"
	ruby /root/configure.rb $* ;;
	*) ruby /root/configure.rb $* ;;
esac