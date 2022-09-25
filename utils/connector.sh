#!/bin/bash

function showConnections() {
	echo "Showing all connections:";
	echo $(ls ./connections/ | cut -d "." -f 1);
}

function addConnection {
	echo "Adding a new connection";
	echo -e "Enter the new connection name: \c"; read connectionName;
	echo -e "Enter the first directory: \c"; read d1;
	echo -e "Enter the second directory: \c"; read d2;

	if [ -z $d1 ] || [ -z $d2 ]; then
			echo "Directory name is null, adding this connection failed";
	else
		if [ ${d1: -1} != "/" ] || [ ${d2: -1} != "/" ]; then
				echo "Problem with directory name, please make sure it ends with forward slash ('/'), adding this connection failed";
		else
			echo "d1=${d1}" >> ./connections/${connectionName}.cfg;
			echo "d2=${d2}" >> ./connections/${connectionName}.cfg;

			$(touch ./connection_histories/${connectionName}.hst);
		fi
	fi
}

function removeConnection {
	echo "Removing a connection";
	echo -e "Enter the name of connection you want to remove: \c"; read connectionName;
	$(rm -f ./connections/${connectionName}.cfg);
	$(rm -f ./connection_histories/${connectionName}.hst);
}

function initializeConnectionTime {
	lastSyncTime=$(awk -F "=" '/lastSyncTime/ {print $2}' $1);
	d1=$(awk -F "=" '/d1/ {print $2}' $1);
	d2=$(awk -F "=" '/d2/ {print $2}' $1);

	if [ -z $lastSyncTime ]; then
		echo "The connection is new, initializing the last-sync time to the oldest file in both directories";
		oldestFile=$(find $d1 $d2 -type f -printf '%T+ %p\n' | sort | head -1 | awk '{print $2}');
		oldestFileName=$(TZ='UTC' date -r $oldestFile "+%s");
		echo "Oldest file: $oldestFile";
		echo "lastSyncTime=${oldestFileName}" >> $1;
	else
		echo "Last synced: $(TZ='UTC' date -d @$lastSyncTime)";
	fi
}

function updateConnectionTime {
	timeNow=$(TZ='UTC' date "+%s")
	$(sed -i "s/lastSyncTime=.*/lastSyncTime=${timeNow}/" $1);
	echo "Last-sync time is updated to $(TZ='UTC' date)";	

}

function initializeFileHistory {
	lastFileHistory=$(< ./connection_histories/$(basename -s .cfg $1).hst);

	d1=$(awk -F "=" '/d1/ {print $2}' ${1});
	d2=$(awk -F "=" '/d2/ {print $2}' ${1});
	
	if [[ -z $lastFileHistory ]]; then
		echo "Initializing the file history for this connection";

		for file in $(find $d1 $d2 -printf '%P\n' | sort | uniq -d); do # for files that exist in both directories
			echo "$file" >> ./connection_histories/$(basename -s .cfg $1).hst;
		done

		for file in $(diff -rs $d1 $d2 | grep "Only" | awk '{print $4}'); do # for files that only exist in one directory
			echo "$file" >> ./connection_histories/$(basename -s .cfg $1).hst;
		done

	else
		echo -e "Last file history:\n${lastFileHistory}";
	fi

}

function updateFileHistory {
	d1=$(awk -F "=" '/d1/ {print $2}' ${1});
	d2=$(awk -F "=" '/d2/ {print $2}' ${1});

	$(> ./connection_histories/$(basename -s .cfg $1).hst); # reset the history file

	for file in $(find $d1 $d2 -printf '%P\n' | sort | uniq -d); do # for files that exist in both directories
			echo "$file" >> ./connection_histories/$(basename -s .cfg $1).hst;
	done

}