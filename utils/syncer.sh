#!/bin/bash

source ./utils/connector.sh

function syncConnections {
	for connection in ./connections/*; do
		echo "Syncing connection $(basename -s .cfg $connection):";

		d1=$(awk -F "=" '/d1/ {print $2}' ${connection});
		d2=$(awk -F "=" '/d2/ {print $2}' ${connection});
		

		if [ ! -d $d1 ] || [ ! -d $d2 ]; then
			echo "One or both directories does (do) not exist, skipping this connection";
		else
			if [ ! "$(ls $d1)" ] && [ ! "$(ls $d2)" ]; then
				echo "Both directories are empty, skipping this connection";
			else
				initializeConnectionTime $connection;
				initializeFileHistory $connection;

				lastSyncTime=$(awk -F "=" '/lastSyncTime/ {print $2}' $connection);
				lastFileHistory=$(< ./connection_histories/$(basename -s .cfg $connection).hst);

				# 1: when file exists in both directories
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
				
				# 2: when file exists only in one directory
				for file in $(diff -rs $d1 $d2 | grep "Only" | awk '{print $4}'); do
					fileDirectory=$(diff -rs $d1 $d2 | grep "Only" | grep "$file" | awk '{print substr($3, 1, length($3)-1)}');

					if [ $fileDirectory == $d1 ]; then
						otherDirectory=$d2;
					else
						otherDirectory=$d1;
					fi

					echo "$file exists only in $fileDirectory";

					if [ $(TZ='UTC' date -r ${fileDirectory}${file} "+%s") -ge $lastSyncTime ]; then
						echo "$file is newly added to $fileDirectory, adding it to $otherDirectory too";
						$(cp -p ${fileDirectory}${file} ${otherDirectory}${file});
					else
						#2.1: when file was really deleted
						if [[ "$lastFileHistory" == *$file* ]]; then
							echo "$file is deleted in $otherDirectory, deleting it in $fileDirectory too";
							$(rm -rf ${fileDirectory}${file});
						#2.2: when file is added, but modification time is really old
						else
							echo "$file is newly added to $fileDirectory, adding it to $otherDirectory too";
							$(cp -p ${fileDirectory}${file} ${otherDirectory}${file});
						fi

					fi
					
				done
			fi			
			
			updateConnectionTime $connection;
			updateFileHistory $connection;

		fi
	done
}
