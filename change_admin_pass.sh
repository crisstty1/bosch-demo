#!/bin/bash

# find out name of logged user  
a=`whoami`
# check is user is member of sudo group
groups | grep sudo
b=$?
# if user is a sudo member then is an admin user
if [ $b -eq 0 ]
then
        echo "user $a is admin";
else
        echo "user $a is not an admin" 
fi
# generate random password
password=$(tr -dc 'A-Za-z0-9!?%=' < /dev/urandom | head -c 10)
# save password in a file
echo $password > pass.txt
# change admin user password
echo ubuntu:${password} | sudo chpasswd
