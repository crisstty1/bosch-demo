#!/bin/bash

# Extract public_ip_addr_1, public_ip_addr_2, public_ip_addr_3, private_ip_addr_1, private_ip_addr_2, private_ip_addr_3 and private_key arguments from the input into
# PUBLIC_IP_ADDR_1, PUBLIC_IP_ADDR_2, PUBLIC_IP_ADDR_3, PRIVATE_IP_ADDR_1, PRIVATE_IP_ADDR_2, PRIVATE_IP_ADDR_3 and PRIVATE_KEY_FILE shell variables.
# jq will ensure that the values are properly quoted and escaped for consumption by the shell.
eval "$(jq -r '@sh "PUBLIC_IP_ADDR_1=\(.public_ip_addr_1) PUBLIC_IP_ADDR_2=\(.public_ip_addr_2) PUBLIC_IP_ADDR_3=\(.public_ip_addr_3) PRIVATE_IP_ADDR_1=\(.private_ip_addr_1) PRIVATE_IP_ADDR_2=\(.private_ip_addr_2) PRIVATE_IP_ADDR_3=\(.private_ip_addr_3) PRIVATE_KEY_FILE=\(.private_key_file)"')"

# pass the result of each ping in a variable
result_1=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_1 "ping -c4 $PRIVATE_IP_ADDR_2"`
result_2=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_2 "ping -c4 $PRIVATE_IP_ADDR_3"`
result_3=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_3 "ping -c4 $PRIVATE_IP_ADDR_1"`

# create one result in JSON format.
# -n -> Don't read any input at all.
# --arg -> This option passes a value to the jq program as a predefined variable.
jq -n --arg result_1 "$result_1" --arg result_2 "$result_2" --arg result_3 "$result_3" '{"result_1":$result_1, "result_2":$result_2, "result_3":$result_3}'

