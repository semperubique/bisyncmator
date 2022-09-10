#!/bin/bash

function sync_connections {
	for connection in ./connections/*; do
		echo "Syncing connection $(basename -s .cfg $connection):";
		d1=$(awk -F "=" '/d1/ {print $2}' ${connection});
		d2=$(awk -F "=" '/d2/ {print $2}' ${connection});
		
		# 1st case: when file exists in both directories
		for file in $(find $d1 $d2 -printf '%P\n' | sort | uniq -d); do
			if [ $(date -r ${d1}${file} "+%s") -gt $(date -r ${d2}${file} "+%s") ]; then
				echo "$file: d1 version is newer, syncing from d1 to d2";
				$(rsync -t ${d1}${file} ${d2}${file});
			elif [ $(date -r ${d1}${file} "+%s") -lt $(date -r ${d2}${file} "+%s") ]; then
				echo "$file: d2 version is newer, syncing from d2 to d1";
				$(rsync -t ${d2}${file} ${d1}${file});
			else
				echo "$file: in sync in both directories";
			fi
		done
		
		# 2nd case: when file exists only in one directory
		for file in $(diff -rs $d1 $d2 | grep "Only" | awk '{print $4}'); do
			echo "$file ony in $(diff -rs $d1 $d2 | grep "Only" | grep "$file" | awk '{print $3}')";
		done
	done
}
