#!/bin/bash

# Extract public_ip_addr_1, public_ip_addr_2, public_ip_addr_3, private_ip_addr_1, private_ip_addr_2, private_ip_addr_3 and private_key arguments from the input into
# PUBLIC_IP_ADDR_1, PUBLIC_IP_ADDR_2, PUBLIC_IP_ADDR_3, PRIVATE_IP_ADDR_1, PRIVATE_IP_ADDR_2, PRIVATE_IP_ADDR_3 and PRIVATE_KEY_FILE shell variables.
# jq will ensure that the values are properly quoted and escaped for consumption by the shell.
# eval "$(jq -r '@sh "PUBLIC_IP_ADDR_1=\(.public_ip_addr_1) PUBLIC_IP_ADDR_2=\(.public_ip_addr_2) PUBLIC_IP_ADDR_3=\(.public_ip_addr_3) PRIVATE_IP_ADDR_1=\(.private_ip_addr_1) PRIVATE_IP_ADDR_2=\(.private_ip_addr_2) PRIVATE_IP_ADDR_3=\(.private_ip_addr_3) PRIVATE_KEY_FILE=\(.private_key_file)"')"

#result_1=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_1 "ping -c4 $PRIVATE_IP_ADDR_2"`
#result_2=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_2 "ping -c4 $PRIVATE_IP_ADDR_3"`
#esult_3=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_3 "ping -c4 $PRIVATE_IP_ADDR_1"`


#jq -n --arg result_1 "$result_1" --arg result_2 "$result_2" --arg result_3 "$result_3" '{"result_1":$result_1, "result_2":$result_2, "result_3":$result_3}'

eval "$(jq -r '@sh "NR_INSTANCES=\(.nr_instances) PRIVATE_KEY_FILE=\(.private_key_file)"')"

i=1

while [ $i -le $NR_INSTANCES ]
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

eval "${eval_string}"


i=1
while [ $i -le $NR_INSTANCES ]
do
    j=$(expr $i + 1)
    result_"$i"=`/usr/bin/ssh -i $PRIVATE_KEY_FILE -o 'StrictHostKeyChecking no' ubuntu@$PUBLIC_IP_ADDR_$i "ping -c4 $PRIVATE_IP_ADDR_$j"`
    i=$(( $i + 1 ))
done

i=1
while [ $i -le $NR_INSTANCES ]
do
    echo -n " --arg result_$i \"\$result_$i\"" >> file2.txt
    i=$(( $i + 1 ))
done
e=$(cat file2.txt)

rm file2.txt

i=1
while [ $i -le $NR_INSTANCES ]
do
    echo -n "\"result_$i\":\$result_$i, " >> file3.txt
    i=$(( $i + 1 ))
done
f=$(cat file3.txt)

rm file3.txt

jq1=$(echo $f | sed 's/.$//')
jq2=$(echo "'{")
jq3=$(echo "}'")
jq_arg="$e $jq2$jq1$jq3"
echo $jq_arg

jq -n "$jq_arg"
