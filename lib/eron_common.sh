#! /bin/bash 

function diagnostic()
{
    diag_file=$(mktemp /tmp/diag_XXXXXX)
    HOST=$(hostname)
    KERNEL=$(uname -a)
    D='/sys/class/net'
    for nic in $( ls $D ); do
    if  grep -q up $D/$nic/operstate; then
        #nic_address=$(cat $D/$nic/address)
        IP=$(ip addr show $nic | awk '/inet / {print $2}' | cut -d/ -f 1)
        MAC=$(ip link show $nic | awk '/ether/ {print $2}')
        echo "{\"serial\": \"$SERIAL_NO\", \"hostname\": \"$HOST\", \"ip\": \"$IP\", \"mac\": \"$MAC\","\
	" \"device\": \"$nic\", \"kernel\": \"$KERNEL\"}" >> $diag_file
    fi
    done
    joc_title=$SERIAL_NO
    cat $diag_file | base64 > /tmp/base64_enc.txt
    joc_content=$(tr -d '\n' < /tmp/base64_enc.txt)
    joc_code=$SERIAL_NO
}

function retrieve_tasks()
{
    json=$1
    for x in $( $JSONENGINE_EXE -p $json ); do
        echo "Retrieving task [$x]"; 
        if [ ! -f ${WORKDIR}/${x} ]; then  
            secure_get ${GET_BACKEND}/$x > ${TMPFILE}
            cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["content"]' | base64 -d > ${WORKDIR}/${x}
        else 
          echo "Task [$x] already present";
        fi
    done
}

function list_remote_content()
{
    secure_get ${GET_BACKEND} > ${TMPFILE}
    cat ${TMPFILE} |  python -c 'import sys, json; print json.dumps(json.load(sys.stdin),indent=4)'
}

function create_remote_content()
{
    joc_tag="post"
    collect_input_from_user 
    dispatch 
}

function boot_from_job()
{
    job=$1
    diagnostic
    dispatch 
    jobfile=$JOBDIR"/"$job".json"
    secure_get ${GET_BACKEND}/$2 > ${TMPFILE}
    cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["content"]' | base64 -d > $jobfile
    echo "Reading job: [$jobfile]"
    retrieve_tasks $jobfile
    ${JSONENGINE_EXE} -i $jobfile
}

function retrieve_remote_content()
{
    code=$1
    secure_get ${GET_BACKEND}/$code > ${TMPFILE}
    cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["content"]' | base64 -d
}

function execute_named_job()
{
    job=$1
    jobfile=$JOBDIR"/"$job".json"
    echo "Reading job: [$jobfile]"
    retrieve_tasks $jobfile
    ${JSONENGINE_EXE} -i $jobfile
}

function cron_set_single_job()
{
    TMP_CRON_FILE=$(mktemp /tmp/unsecure_XXXXXXXX)
    read_cron $1
    ${JSONENGINE_EXE} -C $TMP_CRON_FILE
}

function cron_append_job()
{
    TMP_CRON_FILE=$(mktemp /tmp/unsecure_XXXXXXXX)
    read_cron $1
    ${JSONENGINE_EXE} -c $TMP_CRON_FILE
}

function execute_job_from_file()
{
    job_file=$1
    retrieve_tasks $job_file
    ${JSONENGINE_EXE} -i $job_file
}
