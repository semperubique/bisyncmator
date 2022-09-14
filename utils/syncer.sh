#!/bin/bash

source ./utils/connector.sh

function sync_connections {
	for connection in ./connections/*; do
		echo "Syncing connection $(basename -s .cfg $connection):";
		sync_time_of_connection $connection;
		last_sync_time=$(awk -F "=" '/last_sync_time/ {print $2}' $connection);		
		d1=$(awk -F "=" '/d1/ {print $2}' ${connection});
		d2=$(awk -F "=" '/d2/ {print $2}' ${connection});
			
		if [ -z $d1 ] && [ -z $d2 ]; then
			echo "Both directories are empty, skipping this connection";
			break;
		else
			# 1st case: when file exists in both directories
			for file in $(find $d1 $d2 -printf '%P\n' | sort | uniq -d); do
				if [ $(TZ='UTC' date -r ${d1}${file} "+%s") -gt $(TZ='UTC' date -r ${d2}${file} "+%s") ]; then
					echo "$file: d1 version is newer, syncing from d1 to d2";
					$(rsync -t ${d1}${file} ${d2}${file});
				elif [ $(TZ='UTC' date -r ${d1}${file} "+%s") -lt $(TZ='UTC' date -r ${d2}${file} "+%s") ]; then
					echo "$file: d2 version is newer, syncing from d2 to d1";
					$(rsync -t ${d2}${file} ${d1}${file});
				else
					echo "$file: in sync in both directories";
				fi
			done
			
			# 2nd case: when file exists only in one directory
			for file in $(diff -rs $d1 $d2 | grep "Only" | awk '{print $4}'); do
				file_directory=$(diff -rs $d1 $d2 | grep "Only" | grep "$file" | awk '{print substr($3, 1, length($3)-1)}');
				if [ $file_directory == $d1 ]; then
					other_directory=$d2;
				else
					other_directory=$d1;
				fi
				echo "$file exists only in $file_directory";
				if [ $(TZ='UTC' date -r ${file_directory}${file} "+%s") -ge $last_sync_time ]; then
					echo "$file is newly added to $file_directory, adding it to $other_directory too";
					$(cp -p ${file_directory}${file} ${other_directory}${file});
				else
					echo "$file is deleted in $other_directory, deleting it in $file_directory too";
					$(rm -rf ${file_directory}${file});
				fi
				
			done
		fi			
		
		time_now=$(TZ='UTC' date "+%s")
		$(sed -i "s/last_sync_time=.*/last_sync_time=${time_now}/" $connection);
		echo "Last-sync time is updated to $(TZ='UTC' date)";
	done
}
