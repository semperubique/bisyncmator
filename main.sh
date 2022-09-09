#!/bin/bash

source ./utils/connector.sh
source ./utils/syncer.sh

function action {
	if [ $1 == "1" ]; then
		list_connections;
	elif [ $1 == "2" ]; then
		add_connection;
	elif [ $1 == "3" ]; then
		remove_connection;
	elif [ $1 == "4" ]; then
		sync_connections;
	else
		echo "Not available";
	fi
}

while true; do
	echo "1. List all connections";
	echo "2. Add a new connection";
	echo "3. Remove a connection";
	echo "4. Sync connections";
	echo "5. Quit";
	echo -e "Enter you choice: \c"; read choice;
	if [ $choice == "5" ]; then
		echo "Quitting";
		break;
	else
		action $choice;	
	fi
done

