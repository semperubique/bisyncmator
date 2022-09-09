#!/bin/bash

# todo
# 3 cases:
# 	1) file exists in both directories
# 	2) file only exists in d1
# 	3) file only exists in d2

#for file_d1 in ${d1}*; do # for each file in d1
#	echo "-Checking for $(basename $file_d1) in d1"
#	for file_d2 in ${d2}*; do # for each file in d2
#		echo "--Checking for $(basename $file_d2) in d2"
#		if [ $(basename $file_d1) == $(basename $file_d2) ]; then # if the filenames are the same 
#			if [ $(date -r $file_d1 "+%s") -gt $(date -r $file_d2 "+%s") ]; then # compare timestamps
#				$(rsync -t $file_d1 $file_d2); # file in d1 survives
#				echo "---Synced $(basename $file_d1) from d1 to d2";
#			elif [ $(date -r $file_d1 "+%s") -lt $(date -r $file_d2 "+%s") ]; then
#				$(rsync -t $file_d2 $file_d1); # file in d2 survives
#				echo "---Synced $(basename $file_d2) from d2 to d1";
#			else
#				echo "---Files are in sync";
#			fi
#		else
#			echo "--$(basename $file_d1) exists only in d1";
 #       	fi
#	done
#done

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
	done
}
