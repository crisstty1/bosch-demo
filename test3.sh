#!/bin/bash

i=1
while [ $i -le 3 ]
do
    echo -n " --arg result_$i \"\$result_$i\"" >> file2.txt
    i=$(( $i + 1 ))
done
e=$(cat file2.txt)

rm file2.txt

i=1
while [ $i -le 3 ]
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