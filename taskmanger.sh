#!/bin/bash

cursor=0
sub_cursor=-1
flag=0
sssub_cursor=0
F=0


input="   "

function logo() {
	echo ""
	echo '______                     _    _             '
	echo '| ___ \                   | |  (_)             '
	echo '| |_/ / _ __   __ _   ___ | |_  _   ___   ___  '
	echo '|  __/ |  __| / _  | / __|| __|| | / __| / _ \ '
	echo '| |    | |   | (_| || (__ | |_ | || (__ |  __/ '
	echo '\_|    |_|    \__,_| \___| \__||_| \___| \___| '
	echo ""
	echo '(_)       | |    (_)                    '
	echo ' _  _ __  | |     _  _ __   _   _ __  __'
	echo '| ||  _ \ | |    | ||  _ \ | | | |\ \/ /'
	echo '| || | | || |____| || | | || |_| | >  < '
	echo '|_||_| |_|\_____/|_||_| |_| \__,_|/_/\_\'
	echo ""
}

function logo_chohee() {
	clear
	echo ''
	echo '                   _   _  _____                                '
	echo '                  | \ | ||  _  |                               '
	echo '                  |  \| || | | |				     '
	echo '                  |   ` || | | |                               '
	echo '                  | |\  |\ \_/ /                               '
	echo '                  \_| \_/ \___/   			     '
	echo '____  ____ ____ ___ ___ _____   _____  _____ _____ ______  _   _ '
	echo '|__ \| __|| __ \|  \/  ||_  _| /  ___|/  ___||_  _||  _  || \ | |'
	echo '| |_/| |_ | |_ /| .  . |  ||   \ `__  \ `__    ||  | | | ||  \| |'
	echo '| |  |  _||   / | |\/| |  ||    `__ \  `__ \   ||  | | | || . ` |'
	echo '| |  | |_ ||\ \ | |  | | _||_ /\__/ //\__/ /  _||_ \ \_/ /| |\  |'
	echo '|_|  |___||| \\\\_|  |_/|____|\____/ \____/   \__/  \___/ \_| \_/'     
}		  

function getUsers() {
	#using ps, get Uers, return to arrUsers
	arrUsers=(`ps -ef | cut -f 1 -d " " | sed "1d" | sort | uniq`)
}

function getCmds() {
	#IFS : Internal Field Separator 내부 필드 구분자

	#using ps, get CMDs, return to arrCmds
	ps -ef > temp
	grep ^$1 temp | sort -k2 -g -r > psfu
	rm ./temp
	IFS_backup="$IFS"
	# backup IFS
	IFS=$'\n'
	arrCmds=(`cat psfu | cut -c 51-70`)
	arrPIDs=(`cat psfu | cut -c 11-15`)
	arrSTIMEs=(`cat psfu | awk '{print$5}'`)
	#arrSTIMEs=(`cat psfu | cut -c 25-29`)

	IFS="$IFS_backup"
	# restore IFS
}

function getSTAT() {
	
	ps -aux > tempo
	grep ^$1 tempo | sort -k2 -g -r > stfu
	rm ./tempo
	LFS_backup="$LFS"	
	LFS=$'\n'
	arrSTAT=(`cat stfu | awk '{print$8}'`)
	
	LFS="$LFS_backup"
}

getUsers
getCmds ${arrUsers[$cursor]}
getSTAT ${arrUsers[$cursor]}

numUsers=${#arrUsers[*]}
numCmds=${#arrCmds[*]}


highlight() {
	if [ $2 = $1 ]; then
		echo -n [$3m
	fi
}



until [ "$input" = "q" -o "$input" = "Q" ]; do
clear
	getUsers
	getCmds ${arrUsers[$cursor]}
	getSTAT ${arrUsers[$cursor]}
	
	numSTAT=${#arrSTAT[*]}
	numUsers=${#arrUsers[*]}
	numCmds=${#arrCmds[*]}
	 
	# 1 + 20 + 1 + 20 + 1 + 7 + 1 + 9 + 1
	logo
	echo "-NAME-----------------CMD--------------------PID-----STIME-----"
	for (( i=0; i<20; i++)); do
        printf "|"
		highlight $i $cursor 41
		printf "%20s" ${arrUsers[$i]}
		echo -n [0m
        printf "|"
		IFS_backup="$IFS"
		IFS=$'\n'
        highlight $i $sub_cursor 42
	if [ $sssub_cursor -eq 0 ]; then
		B=`echo ${arrSTAT[$i]} | rev | cut -c -1 | rev`; 
		if [ $i -lt $numSTAT ]; then
			if [ `echo $B` == "+" ]; then
				printf "F%+21.20s|%7s|%9s" ${arrCmds[$i]} ${arrPIDs[$i]} ${arrSTIMEs[$i]}
			else
				printf "B%+21.20s|%7s|%9s" ${arrCmds[$i]} ${arrPIDs[$i]} ${arrSTIMEs[$i]}
			fi
		else
			printf "%+22.20s|%7s|%9s" ${arrCmds[$i]} ${arrPIDs[$i]} ${arrSTIMEs[$i]}
		fi
	elif [ $sssub_cursor -gt 0 ]; then
		H=`expr $i + $sssub_cursor`;
		C=`echo ${arrSTAT[$H]} | rev | cut -c -1 | rev`;
		if [ $i -lt $numSTAT ]; then
                        if [ `echo $B` == "+" ]; then
                                printf "F%+21.20s|%7s|%9s" ${arrCmds[$H]} ${arrPIDs[$H]} ${arrSTIMEs[$H]}
                        else
                                printf "B%+21.20s|%7s|%9s" ${arrCmds[$H]} ${arrPIDs[$H]} ${arrSTIMEs[$H]}
                        fi
                else
                        printf "%+22.20s|%7s|%9s" ${arrCmds[$i]} ${arrPIDs[$i]} ${arrSTIMEs[$i]}
                fi
	fi
        echo -n [0m
        printf "|"
		IFS="$IFS_backup"
		printf "\n"
	done
	echo "---------------------------------------------------------------"
	echo "If you want to exit , Please Type 'q' or 'Q'":
   printf ""
	read -n 3 -t 3 input
	case "$input" 
	in
	        [A) if [ $flag -eq 0 ]; then
                                [ $cursor -gt 0 ] && cursor=`expr $cursor - 1`
                        elif [ $flag -eq 1 ]; then
                                if [ $sub_cursor -gt 0 ]; then
                                        sub_cursor=`expr $sub_cursor - 1`
				elif [ $sub_cursor -eq 0 ]; then
					[ $sssub_cursor -gt 0 ] && sssub_cursor=`expr $sssub_cursor - 1 `
                                fi
                        fi;;				
		[B) if [ $flag -eq 0 ]; then 
				[ $cursor -lt `expr $numUsers - 1` ] && cursor=`expr $cursor + 1`
			elif [ $flag -eq 1 ]; then 
				if [ $sub_cursor -lt 19 ]; then		 
                [ $sub_cursor -lt `expr $numCmds - 1` ] && sub_cursor=`expr $sub_cursor + 1`
				elif [ $sub_cursor -eq 19 ]; then				[ $sub_cursor -lt `expr $numCmds - 1` ] && sssub_cursor=`expr $sssub_cursor + 1`  
                		fi
			fi;;
        [C) [ $flag -eq 0 ] && sub_cursor=0 && flag=1;;
        [D) [ $flag -eq 1 ] && flag=0 && sub_cursor=-1 sssub_cursor=0 ;;
	"")  A=${arrPIDs[$sub_cursor]} && kill -9 $A || logo_chohee && sleep 0.5;; 
	esac
done


