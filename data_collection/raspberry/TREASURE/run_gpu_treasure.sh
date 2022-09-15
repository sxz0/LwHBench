#!/bin/bash

if [ -e /sys/class/net/eth0 ]; then
	mac=$( cat /sys/class/net/eth0/address | tr : _ )
elif [ -e /sys/class/net/enx* ]; then
	mac=$( cat /sys/class/net/enx*/address | tr : _ )
elif [ -e /sys/class/net/wlan0 ]; then
	mac=$( cat /sys/class/net/wlan0/address | tr : _ )
else
	mac=$( cat /sys/class/net/wlx*/address | tr : _ )
fi

model=$( cat /proc/device-tree/model | sed 's/\x0//g' )
loop1=39
loop2=19
core=3
secs=120
random=100000000


#sudo export PYTHONHASHSEED=0 #Disable random hash seed

sudo sysctl kernel.randomize_va_space=0 #Disable random memory ASLR

if [[ $model == *"Pi 4"* ]];
then
	#sudo export PYTHONPATH=sandbox/
	for s in `seq 0 $loop1` #39
	do
		for i in `seq 0 $loop2`
		do
			sudo PYTHONHASHSEED=0 PYTHONPATH=sandbox/ chrt --rr 99 taskset -c $core python3 TREASURE_tests_VC6.py >> feat_gpu_$mac
		done
		sleep 2
	done
elif [[ $model == *"Pi 3"* ]];
then
	for s in `seq 0 $loop1` #39
	do
		for i in `seq 0 $loop2`
		do
			sudo PYTHONHASHSEED=0 chrt --rr 99 taskset -c $core python3 TREASURE_tests_VC4.py >> feat_gpu_$mac
		done
		sleep 2
	done
else
	for s in `seq 0 $loop1` #39
	do
		for i in `seq 0 $loop2`
		do
			sudo PYTHONHASHSEED=0 chrt --rr 10 python3 TREASURE_tests_VC4.py >> feat_gpu_$mac
		done
		sleep 2
	done
fi

sudo reboot

#done

