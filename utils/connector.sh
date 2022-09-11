#!/bin/bash

function list_connections() {
	echo "Listing all connections:";
	echo $(ls ./connections/ | cut -d "." -f 1);
}

function add_connection {
	echo "Adding a new connection";
	echo -e "Enter the new connection name: \c"; read connection_name;
	echo -e "Enter the first directory: \c"; read d1;
	echo -e "Enter the second directory: \c"; read d2;
	echo "d1=${d1}" >> ./connections/${connection_name}".cfg";
	echo "d2=${d2}" >> ./connections/${connection_name}".cfg";
}

function remove_connection {
	echo "Removing a connection";
	echo -e "Enter the name of connection you want to remove: \c"; read connection_name;
	$(rm -f ./connections/${connection_name}".cfg");
}

function sync_time_of_connection {
	last_sync_time=$(awk -F "=" '/last_sync_time/ {print $2}' $1);
	d1=$(awk -F "=" '/d1/ {print $2}' $1);
	d2=$(awk -F "=" '/d2/ {print $2}' $1);

	if [ -z $last_sync_time ]; then
		echo "The connection is new, initializing the last-sync time to the oldest file in both directories";
		oldest_file=$(find $d1 $d2 -type f -printf '%T+ %p\n' | sort | head -1 | awk '{print $2}');
		oldest_file_time=$(TZ='UTC' date -r $oldest_file "+%s");
		echo "Oldest file: $oldest_file";
		echo "last_sync_time=${oldest_file_time}" >> $1;
	else
		echo "Last synced: $(TZ='UTC' date -d @$last_sync_time)";
	fi
}
