#!/bin/bash

work_done=false

function on_exit() {
if [ $work_done ]
then 
echo "Exiting" >> "log.txt"
echo "Exiting, please wait"
list=$(networksetup -listlocations | grep -w Secret)
if [ -n list ]
then 
sudo networksetup -switchtolocation "Main" > /dev/null
sudo networksetup -deletelocation "Secret Location" > /dev/null
fi
echo $'End of session' >> log.txt
exit 1
fi
}

function on_ctrl_c {
on_exit
}

trap on_ctrl_c INT
trap on_exit EXIT
echo $(date) Session started >> log.txt
sudo networksetup -createlocation "Secret Location" populate > /dev/null
sleep 0.1
sudo networksetup -switchtolocation "Secret Location" > /dev/null
sudo networksetup -listallnetworkservices | grep -vw "An asterisk" | while read serv
do
sleep 0.1
echo Creating on $serv >> log.txt
sudo networksetup -setsecurewebproxy "$serv" 127.0.0.1 8118 >> log.txt
echo Done on secure >> log.txt
sleep 0.1
sudo networksetup -setwebproxy "$serv" 127.0.0.1 8118
echo Done on regular >> log.txt
sleep 0.1
sudo networksetup -setsocksfirewallproxy "$serv" 127.0.0.9050
echo Done on socks >> log.txt
echo Set up proxy on service $serv >> log.txt
done

echo $'Press Ctrl+C to exit'

while [ 1 = 1 ]
do
sleep 1
done

