#! /bin/bash 

function write_empty_config()
{
	echo "ENDPOINT="> $CFG_FILE
	echo "SECURE_HOME=">> $CFG_FILE
	echo "SECURE_SERVICE=">> $CFG_FILE
	echo "SECURE_CLIENT=">> $CFG_FILE
	echo "joc_domain=">> $CFG_FILE
	echo "Edit config file: [$CFG_FILE]"
}

function test_config()
{
	test -f $CFG_FILE || write_empty_config 
}

