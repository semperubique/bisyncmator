#!/bin/bash

function list_connections {
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
