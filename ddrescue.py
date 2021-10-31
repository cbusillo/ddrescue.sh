#!/usr/bin/python3
import os
import sys
import time

#source = input("What is the name of the source device, e.g. sda? ") or "sdb"
#destination = input("What is the name of the destination device, e.g. sdb? ") or "sda"
#customer = input("What is the name of the recovery? ") or "Bad2"
#arguments = input("What arguments would you like? ") or ""
source = "sdb"
destination = "sda"
customer = "Bad2"
arguments = ""


incrementAmount = 1000000000
retryAttempts = 20
restartTime = 4
currentPosition = 0
ddArgs="--cpass=1"

logfile = open(customer + ".log", 'a')
os.system("sudo systemctl mask udisks2.service")

totalCount = 0
currentRetry = 0

while 1:
	count=0
	print("Plug off")
	#os.system("sudo uhubctl -a off -l 2-1 > /dev/null ")
	#time.sleep(1)
	#os.system("sudo killall ddrescue")
	#os.system("sudo uhubctl -a on -l 2-1 > /dev/null ")
	print("Plug on")
	
	try:
		lines = logfile.readline()
		currentRetry = lines[7]
	except Exception as e:
		print("First run")
	print(currentRetry)
"""
	
	currentRetry=`sed '7q;d' Bad.log | tr -s " " | cut -d ' ' -f3`
	echo -ne "\nRuns: $totalCount Retry: $currentRetry Current increment: $incrementAmount Current Postion: $currentPosition time waiting for $source: "
	
	while [[ ! -b /dev/$source ]] && [[ $count -le 10 ]]
	do
		sleep 1
		echo -n " $count"
		count=$(( $count + 1 ))
	done
	echo -ne "\n"

	if [ "$currentRetry" -eq 2 ] 
	then 
		restartTime=10
		incrementAmount=10000000
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 3 ] 
	then 
		restartTime=10
		incrementAmount=100000
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 4 ] 
	then 
		restartTime=10
		incrementAmount=1000
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 5 ] 
	then 
		restartTime=10
		incrementAmount=100
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 6 ] 
	then 
		restartTime=10
		incrementAmount=10
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 7 ] 
	then 
		restartTime=10
		incrementAmount=5
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 8 ] 
	then 
		restartTime=10
		incrementAmount=1
		ddArgs="--cpass=1-4"
	elif [ "$currentRetry" -eq 9 ] 
	then 
		restartTime=20
		incrementAmount=0
		ddArgs="--cpass=1-5"
	fi
		
	sudo touch $customer.log
	sudo ddrescue --mapfile-interval=1 -dfvv -r$retryAttempts $ddArgs --min-read-rate=1024 --input-position=$currentPosition /dev/$source /dev/$destination $customer.log &
	
	timeRunning=0
	while [ "$timeRunning" -le "$restartTime" ]
	do
		currentTime=$(date +%s)
		fileTime=$(stat $customer.log -c %X)
		timeRunning=$(expr $currentTime - $fileTime)
	done
	#if [ "$timeRunning" -ge "$restartTime" ]
	#then
	#	./plugoffon.py > /dev/null
	#fi
	currentPosition=$(( `sed '7q;d' $customer.log | cut -d ' ' -f1` + $incrementAmount ))
	totalCount=$(( $totalCount + 1 ))
done

sudo systemctl unmask udisks2.service

"""