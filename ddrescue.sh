#!/bin/bash

#echo "What is the name of the source device, e.g. sda?"
#read source
source=sda
#echo "What is the name of the destination device, e.g. sdb?"
#read destination
destination=sdb
#echo "What is the name of the recovery?"
#read customer
customer=Erik
#echo "What arguments would you like?"
#read args
#args=

incrementAmount=1000

sudo systemctl mask udisks2.service

totalCount=0
while true
do
	count=0
	./plugoffon.py > /dev/null 
	echo -ne "\n$totalCount time waiting for $source"

	while [[ ! -b /dev/$source ]] && [[ $count -le 60 ]]
	do
		sleep 1
		echo -n " $count"
		count=$(( $count + 1 ))
	done
	echo
	if [ $((totalCount%2)) -eq 1 ]
	then
		reverse=-R
	else
		reverse=
	fi
	sudo touch $customer.log
	currentPosition=$(( `sed '7q;d' $customer.log | cut -d ' ' -f1` + $incrementAmount ))
	sudo ddrescue --mapfile-interval=1 -dfvv -r0 --min-read-rate=1024 --input-position=$currentPosition /dev/$source /dev/$destination $customer.log &
	timeRunning=0
	while [ "$timeRunning" -le 120 ]
	do
		currentTime=$(date +%s)
		fileTime=$(stat $customer.log -c %X)
		timeRunning=$(expr $currentTime - $fileTime)
		#echo "\n\n\n\n$timeRunning"
	done 
	#killall ddrescue
	# -nN
	count=0
	totalCount=$(( $totalCount + 1 ))
done

sudo systemctl unmask udisks2.service

