#! /bin/bash 

function mqtt_subscribe()
{
    topic_name=$SERIAL_NO
    while read msg;
    do
      echo "[$msg]";
      jobfile=$JOBDIR"/"$msg".json"
      echo "Reading job: [$jobfile]"
      retrieve_tasks $jobfile
      ${JSONENGINE_EXE} -i $jobfile
    done < <(mosquitto_sub -t $topic_name -q 1)
}
