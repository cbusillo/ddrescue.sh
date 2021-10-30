#echo "What is the name of the source device, e.g. sda?"
#read source
source=sdb
#echo "What is the name of the destination device, e.g. sdb?"
#read destination
destination=sda
#echo "What is the name of the recovery?"
#read customer
customer=Bad
#echo "What arguments would you like?"
#read args
#args=

incrementAmount=1000
retryAttempts=20
restartTime=4
currentPosition=0
ddArgs="--cpass=1"


sudo systemctl mask udisks2.service

totalCount=0
while true
do
	count=0
	sudo killall ddrescue
	#./plugoffon.py > /dev/null old cloud plug
	echo Plug off
	sudo uhubctl -a off -l 2-1 > /dev/null 
	sleep 1
	echo Plug on
	sudo uhubctl -a on -l 2-1 > /dev/null 
	echo -ne "\n$totalCount time waiting for $source "

	while [[ ! -b /dev/$source ]] && [[ $count -le 10 ]]
	do
		sleep 1
		echo -n " $count"
		count=$(( $count + 1 ))
	done
	currentRetry=`sed '7q;d' Bad.log | tr -s " " | cut -d ' ' -f3`
	if [ "$currentRetry" -eq 2 ] 
	then 
		restartTime=10
		incrementAmount=500
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 3 ] 
	then 
		restartTime=10
		incrementAmount=100
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 4 ] 
	then 
		restartTime=10
		incrementAmount=50
		ddArgs="--cpass=1"
	elif [ "$currentRetry" -eq 5 ] 
	then 
		restartTime=10
		incrementAmount=25
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
	currentPosition=$(( `sed '7q;d' $customer.log | cut -d ' ' -f1` + $incrementAmount ))
	
	timeRunning=0
	while [ "$timeRunning" -le "$restartTime" ]
	do
		currentTime=$(date +%s)
		fileTime=$(stat $customer.log -c %X)
		timeRunning=$(expr $currentTime - $fileTime)
	done 
	totalCount=$(( $totalCount + 1 ))
done

sudo systemctl unmask udisks2.service

