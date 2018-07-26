#! /bin/bash 

function secure_get()
{
	url=$1
	if [ "$MODE" = "wget" ]; then
		GET_COMMAND="wget -q  -O - --ca-certificate=${CA_CERTIFICATE} --certificate=${CERTIFICATE} --private-key=${PRIVATE_KEY}  --certificate-type=PEM --no-check-certificate" 
	fi

	if [ "$MODE" = "curl" ]; then
		#GET_COMMAND="curl -s --cacert ${CA_CERTIFICATE} --cert ${CERTIFICATE} --key ${PRIVATE_KEY} --socks5-hostname localhost:9050 --cert-type PEM -k "
		GET_COMMAND="curl -s --cacert ${CA_CERTIFICATE} --cert ${CERTIFICATE} --key ${PRIVATE_KEY}  --cert-type PEM -k "
	fi
	$GET_COMMAND $url
}

function dispatch()
{
	curl -k --cert-type pem \
 		--cacert ${CA_CERTIFICATE}\
		--cert ${CERTIFICATE}\
 		--key ${PRIVATE_KEY}\
		-H "Content-Type: application/json" \
        	--data  "{\"domain\":\"${joc_domain}\",\"title\":\"${joc_title}\", \"content\":\"${joc_content}\", \"tag\":\"${joc_tag}\" ,\"code\":\"${joc_code}\" }" \
        	${POST_BACKEND}
}
