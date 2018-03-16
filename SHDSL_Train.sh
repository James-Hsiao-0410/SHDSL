#!/bin/bash
echo "$(date "+%Y/%m/%d %H:%M:%S") SHDSL Check start" >> /home/handyman/SRX_Train/SHDSL.log
cat /home/handyman/SRX_Train/list | while read i
do
CO_ip=$(echo $i | awk -F' ' '{print $2}')
CPE_ip=$(echo $i | awk -F' ' '{print $1}')
err_ip_count=$(grep -c -w $CPE_ip /home/handyman/SRX_Train/Err_ip_list)
Recheck_ip_count=$(grep -c -w $CPE_ip /home/handyman/SRX_Train/Recheck_ip_list)
ping -c 3 -W 1 $CPE_ip  &> \dev\null
	if [ $? -eq 0 ]
	then
		echo "Sucess" &> \dev\null
		if [ $err_ip_count -ne 0 ] || [ $Recheck_ip_count -ne 0 ]
			then
			sed -i "/$CPE_ip/d" /home/handyman/SRX_Train/Err_ip_list
			sed -i "/$CPE_ip/d" /home/handyman/SRX_Train/Recheck_ip_list
			echo "$(date "+%Y/%m/%d %H:%M:%S") $CPE_ip SHDSL has been established" >> /home/handyman/SRX_Train/SHDSL.log
		fi
	else
		if [ $err_ip_count -eq 0 ]
		then
			if [ $Recheck_ip_count -eq 0 ]
			then
				ping -c 3 -W 1 $CO_ip &> \dev\null
				if [ $? -eq 0 ]
				then
					expect /home/handyman/SRX_Train/autotrain.tcl $i
					echo $CPE_ip >> /home/handyman/SRX_Train/Recheck_ip_list
				else
					echo "$(date "+%Y/%m/%d %H:%M:%S") $CPE_ip CO site equipment connect failure" >> /home/handyman/SRX_Train/SHDSL.log
					echo $CPE_ip >> /home/handyman/SRX_Train/Err_ip_list
					sed -i "/$CPE_ip/d" /home/handyman/SRX_Train/Recheck_ip_list
				fi
			else
				echo $CPE_ip >> /home/handyman/SRX_Train/Err_ip_list
				sed -i "/$CPE_ip/d" /home/handyman/SRX_Train/Recheck_ip_list
			fi
		fi
	fi
done
echo "$(date "+%Y/%m/%d %H:%M:%S") SHDSL Check Finish" >> /home/handyman/SRX_Train/SHDSL.log
