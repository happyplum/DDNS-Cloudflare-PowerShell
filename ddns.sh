#bash

ip=$(curl -4 -s ip.sb)

if [ "${ip}" == "" ]; then
echo 'Failed to obtain the ip address'
exit 1
fi

echo "current IPv4 address ${ip}"

zoneId='ChangeMe'
authKey='ChangeMe'
email='ChangeMe'

function updatecfip(){

res=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zoneId}/dns_records?name=$1" -H "X-Auth-Email:${email}" -H "X-Auth-Key:${authKey}" -H "Content-Type: application/json" | grep -Po '(?<="content":")[^"]*' | head -1)

resID=$(echo $res | grep -Po '(?<="id":")[^"]*' | head -1)
resIP=$(echo $res | grep -Po '(?<="content":")[^"]*' | head -1)

echo "current $1 cf ip ${resIP}"

if [ "${resIP}" != "" ] && [ "${ip}" != "${resIP}" ]; then
curl -k -X PUT "https://api.cloudflare.com/client/v4/zones/${zoneId}/dns_records/${resID}" \
         -H "X-Auth-Email:${email}" \
	 -H "X-Auth-Key:${authKey}" \
         -H "Content-Type: application/json" \
         --data '{"type":"A","name":"$1","content":"'${ip}'","ttl":1,"proxied":false}'
echo "update $1 cf ip ${ip}"
else
echo 'empty cfData or not set ip'
fi

}

updatecfip ChangeMeDomain
