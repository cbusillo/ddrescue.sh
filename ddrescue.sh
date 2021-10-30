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
retryAttempts=0
restartTime=4
currentPosition=0

secondPass=0

if [ $secondPass -eq 1 ]
then
	incrementAmount=0
	retryAttempts=31
	restartTime=4
fi

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
	echo -ne "\n$totalCount time waiting for $source"

	while [[ ! -b /dev/$source ]] && [[ $count -le 10 ]]
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
	
	sudo ddrescue --mapfile-interval=1 -dfvv -r$retryAttempts --min-read-rate=1024 --input-position=$currentPosition /dev/$source /dev/$destination $customer.log &
	
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

