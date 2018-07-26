#! /bin/bash 

function import_json_job()
{
    tgzfile=$1
    tar -xvf $tgzfile -C $ERON_HOME --strip-components=1
}

function export_json_job()
{
    jobname=$1
    json=$JOBDIR"/"$jobname".json"
    TMPDIR=$(mktemp -d /tmp/eron_job_export_XXXXXX)
    CURRENT_DATE=$(date '+%Y%m%d')
    mkdir -p $TMPDIR"/job-"$jobname
    mkdir -p $TMPDIR"/job-"$jobname"/tasks"
    mkdir -p $TMPDIR"/job-"$jobname"/jobs"
    for x in $( $JSONENGINE_EXE -p $json ); do
        echo "Processing task [$x]"; 
        if [ ! -f ${WORKDIR}/${x} ]; then  
            secure_get ${GET_BACKEND}/$x > ${TMPFILE}
            cat ${TMPFILE} | python -c 'import sys, json; print json.load(sys.stdin)["content"]' | base64 -d > ${WORKDIR}/${x}
        else 
          echo "Task [$x] already present";
        fi
        cp ${WORKDIR}/${x} $TMPDIR"/job-"$jobname"/tasks/"
    done
    cp $json $TMPDIR"/job-"$jobname"/jobs/"
    tar cvfz "job-"$jobname"-"$CURRENT_DATE".tar.gz" -C $TMPDIR "job-"$jobname 
}

function list_local_jobs()
{
   idx=1
   for f in $( find $JOBDIR ); do 
       base_file=$(basename $f | sed -e s/.json$//;) 
       echo $idx $base_file
   appidx=$((idx+1))
   idx=$appidx
   done
}

function print_job_list()
{
    joblist=$(list_jobs) 
    idx=1
    for t in $joblist; do
       echo "$idx $t"
       appidx=$((idx+1))
       idx=$appidx
    done
}
function print_task_list()
{
    tasklist=$(list_tasks) 
    idx=1
    for t in $tasklist; do
       echo "$idx $t"
       appidx=$((idx+1))
       idx=$appidx
    done
}
