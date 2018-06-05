#!/bin/bash

set -eo pipefail

#######################################
## Bash script to non-interactively install a live Digicert certificate on a server, vm, or docker container. 
## Can also upload certs to AWS ACM.  Tested on Debian Stretch.
## Tom Porter
## v2.05
#######################################

## Error checking
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }


## Required
apikey=**************************************************************************
domain=frogtownroad.com
commonname=$1
orgid=******

## Change to your details
country=US
state=Virginia
locality=Upperville
organization=Frogtownroad
organizationalunit=TEST
email=tom@frogtownroad.com

## Clear The Screen to make it pretty. 
## printf "\033c"

## Optional
## password=dummypassword

## Generate a key
echo "Creating private key. 0K"
openssl genrsa -des3 -passout pass:password -out private.pem 2048 > /dev/null 2>&1
sleep 1

echo "Signing PEM CSR with private key. 0K" 
openssl rsa -passin pass:password -in private.pem -out privateunencrypted.pem -outform PEM > /dev/null 2>&1
sleep 1

## Remove passphrase from the key. 
## Uncomment the line to remove the passphrase
echo "Removing passphrase from key. 0K" 
openssl rsa -in  private.pem  -passin pass:password -out  private.key.pem -outform PEM > /dev/null 2>&1
sleep 1

## Create the request
echo "Creating CSR. 0K"
openssl req -new -key private.pem -out $commonname.csr -passin pass:password \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email" > /dev/null 2>&1
sleep 1

## Fix CSR
echo "Fixing up CSR. 0K"
csr=$(tr -d ' \t\n\r\f' <$commonname.csr )
sleep 1

## Setup CSR & request 
request_cert=$(cat <<EOF
{
  "certificate": {
    "common_name": "$commonname",
    "csr": "$csr",
    "organization_units": [
      "PlatformDXC"
    ],
    "server_platform": {
      "id": 2
    },
    "signature_hash": "sha256"
  },
  "organization": {
    "id": $orgid
  },
  "validity_years": 1,
  "disable_renewal_notifications": "true"
} 
EOF
)

echo "Request_cert in JSON format"
echo "$request_cert" 

## Issue cert 
request_issue=$(cat <<EOF
{
  "status": "approved"
}
EOF
)

echo "Requesting DigiCert Cert. OK"
echo ""
echo curl -s -H '"X-DC-DEVKEY: '${apikey}'"' -H '"Content-Type: application/json"' --data "'${request_cert}'" https://www.DigiCert.com/services/v2/order/certificate/ssl_plus > order.txt
echo $order
bash order.txt > ordered.txt
sleep 2

echo  "Getting Cert Number. OK"
echo "" 
otherordernumber=$(cat ordered.txt | tr ':' ',' | awk -F',' '$4 ~ /id/ {print $2}')
echo curl -s -H '"X-DC-DEVKEY: '${apikey}'"' -H '"Content-Type: application/json"'  "https://www.DigiCert.com/services/v2/order/certificate/${otherordernumber}" > cert.txt
bash cert.txt > certs.txt

## Sleeping for 10 seconds to allow cert to be issued.
secs=10
while [ "$secs" -gt 0 ]; do
echo -ne "Sleeping for $secs Seconds To Allow Cert to Be Issued.\r"
sleep 1
: $((secs--))
done
echo "" 
echo  "Downloading Cert. OK"
 
certnumber=$(cat certs.txt | tr ':' ',' | awk -F',' '$4 ~ /id/ {print $5}')
echo "" 

## Uncomment for a single .pem file containing all the certs
echo curl -s -H '"X-DC-DEVKEY: '${apikey}'"' -H '"Accept: */*"' "https://www.DigiCert.com/services/v2/certificate/${certnumber}/download/format/pem_all" --output  $commonname.pem > pem.txt
bash pem.txt

## Split the cert
echo "Splitting Cert" 
echo "" 
openssl x509 -in $commonname.pem -outform pem -out host-cert.pem

## Optional -- Upload to AWS:
echo  "Uploading Certs To AWS. OK"
echo "" 

aws acm import-certificate --certificate file://host-cert.pem --certificate-chain file://$commonname.pem  --private-key file://privateunencrypted.pem > awsacm.txt

mkdir -p $commonname
mv *.txt $commonname
mv *.pem $commonname
mv *.csr $commonname
echo "Done. Check AWS ACM Console." 
