#! /bin/bash
# Program:
# Create users for nis using file of "teams"
# Or
# Create users and passwords with file you give as a argument
# History:
# 2014/09/25	Ansersion	1.0

# PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# export PATH
# HomeDir=/robocup3D
source ./envset
declare -a usersArray
declare -a passwdArray
userID=2000
groupadd -g 2000 $GROUP
mkdir -p -m 755 $HomeDir

if [ "x$1" == "x" ]; then
	rm -f usersPasswd.txt
	for username in $users
	do
		userID=$(($userID+1))
		PASSWD=$(cat /proc/sys/kernel/random/uuid | cut -b 1-6)
		useradd -m -u $userID -d $HomeDir/$username -g $GROUP $username
		mkdir -p -m 755 $HomeDir/$username/log
		mkdir -p -m 755 $HomeDir/$username/.bin
		cp -p ./sim3dStart/* $HomeDir/$username/.bin
		echo "PATH=$PATH:$HomeDir/$username/.bin" >> $HomeDir/$username/.bashrc
		#(echo $password;sleep 1;echo $password)|sudo passwd $curuser
		(echo $PASSWD;sleep 1;echo $PASSWD) | sudo passwd $username
		echo "user: $username password: $PASSWD" >> usersPasswd.txt
	done
else
	users=$(cat $1 | awk '{print $2}')
	PASSWD=$(cat $1 | awk '{print $4}')
	
	countUsers=0;
	for username in $users
	do
		usersArray[$countUsers]=$username;
		countUsers=$(($countUsers+1))
	done

	countPasswd=0;
	for Passwd in $PASSWD
	do
		passwdArray[$countPasswd]=$Passwd;
		countPasswd=$(($countPasswd+1))
	done

	if [ "$countUsers" != "$countPasswd" ];then
		echo "Error in your password file!"
		exit 1
	fi
	
	echo -e "The number of users: $countUsers\n";

	for((i = 0; i < $countUsers; i++))
	do
		userID=$(($userID+1))
		# echo "ID: $userID user: ${usersArray[$i]} password: ${passwdArray[$i]}"
		useradd -u $userID -d $HomeDir/${usersArray[$i]} -g $GROUP ${usersArray[$i]}
		mkdir -p -m 755 $HomeDir/${usersArray[$i]}/log
		mkdir -p -m 755 $HomeDir/${usersArray[$i]}/.bin
		cp -p ./sim3dStart/* $HomeDir/${usersArray[$i]}/.bin
		echo "PATH=$PATH:$HomeDir/${usersArray[$i]}/.bin" >> $HomeDir/${usersArray[$i]}/.bashrc
		(echo ${passwdArray[$i]};sleep 1;echo ${passwdArray[$i]})| sudo passwd ${usersArray[$i]}
	done
fi
