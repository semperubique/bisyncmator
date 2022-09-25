#!/bin/bash

source ./utils/connector.sh
source ./utils/syncer.sh

function action {
	if [ $1 == "1" ]; then
		showConnections;
	elif [ $1 == "2" ]; then
		addConnection;
	elif [ $1 == "3" ]; then
		removeConnection;
	elif [ $1 == "4" ]; then
		syncConnections;
	else
		echo "Not available";
	fi
}

while true; do
	echo "1. Show all connections";
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

