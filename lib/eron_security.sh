#! /bin/bash 

function security_generate_ca()
{
    iron ca create
}

function security_generate_service()
{
    servicex=$1
    iron service setup $servicex 
    iron service create $servicex 
}

function security_generate_csr()
{
    servicex=$1
    clientx=$2
    iron client setup $servicex $clientx
    iron client csr  $servicex $clientx
}

function security_renew_certificate()
{
    servicex=$1
    clientx=$2
    REMOTE_CA_HOST=127.0.0.1
    REMOTE_CA_PORT=8081
    REMOTE_CA_PROTOCOL=https
    caricandum=$SECURE_HOME/$servicex/certs/$clientx/$clientx.csr
    $certificate=$(curl -F "file=@$caricandum" $REMOTE_CA_PROTOCOL://$REMOTE_CA_HOST:$REMOTE_CA_PORT/upload/$servicex/$clientx)
    echo $certificate > $SECURE_HOME/$servicex/certs/$clientx/$clientx.crt
}
