#! /bin/bash -x

REMOTE_USER=
REMOTE_HOST= 
TMPLATE=/tmp/rrexe_XXXXXXXXXXXX

function remote_run()
{
	TREXE=$(ssh ${REMOTE_USER}@${REMOTE_HOST} mktemp ${TMPLATE})
	scp $1 ${REMOTE_USER}@${REMOTE_HOST}:${TREXE}
	ssh ${REMOTE_USER}@${REMOTE_HOST} "chmod 755 ${TREXE}"
	ssh ${REMOTE_USER}@${REMOTE_HOST} "sh ${TREXE}"
}

if [ "$#" = 1 ];then
	image_name=$1
	remote_run ${image_name}  
else
	echo "Usage: $0 <image_name>"
	exit -1
fi
