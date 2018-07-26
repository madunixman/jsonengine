#! /bin/bash 

function collect_input_from_user()
{
	echo "Title:"
	read joc_title
	echo "Content:"
	read joc_uncoded
	echo $joc_uncoded | base64 > /tmp/base64_enc.txt
	joc_content=$(tr -d '\n' < /tmp/base64_enc.txt)
	echo "Code:" 
	read joc_code 
}

function collect_cron_input()
{
	input_file=$1
	echo "Code:"
	read joc_code
	joc_title=$joc_code
	cat $input_file | base64 > /tmp/base64_jenc.txt
	joc_content=$(tr -d '\n' < /tmp/base64_jenc.txt)
}

function collect_file_input()
{
	input_file=$1
	joc_title=$(head -1 $input_file)
	cat $input_file | base64 > /tmp/base64_enc.txt
	joc_content=$(tr -d '\n' < /tmp/base64_enc.txt)
	echo "Code:"
	read joc_code
}

function read_cron()
{
    job_name=$1
    echo "Insert hour" 
    read hour
    echo "Insert minute" 
    read minute
    echo "Insert dayOfMonth" 
    read dayOfMonth
    echo "Insert dayOfWeek" 
    read dayOfWeek
    echo "Insert month" 
    read month
    echo "Insert command" 
    command="$0 -x $job_name"
    bcommand=$(echo $command| base64) 
    echo "{ \"hour\":\"$hour\", \"minute\":\"$minute\", \"dayOfMonth\":\"$dayOfMonth\", \"month\":\"$month\", \"dayOfWeek\":\"$dayOfWeek\", \"command\":\"$bcommand\" }" > $TMP_CRON_FILE
}
