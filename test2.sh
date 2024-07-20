#!/bin/bash

i=1

while [ $i -le 3 ]
do
    echo -n " PUBLIC_IP_ADDR_$i=\(.public_ip_addr_$i) PRIVATE_IP_ADDR_$i=\(.private_ip_addr_$i)" >> file1.txt
    i=$(( $i + 1 ))
done
a=$(cat file1.txt | cut -c 2-)
b=$(echo "\"\$(jq -r '@sh \"")
c=$(echo \"\'\)\")

eval_string="$b$a$c"
echo $eval_string
rm file1.txt

#eval "${eval_string}"

