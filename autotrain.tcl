#!/usr/bin/expect
set username ""
set password ""
set old_password ""
set CPE_ip_addr [lindex $argv 0]
set ip_addr [lindex $argv 1]
set Co [lindex $argv 2]
spawn telnet $ip_addr
expect "*ogin*"
send "$username\n"
expect "*sswor*"
send "$password\n"

expect {
	 "*incorr*" {
	 expect "*ogin*"
	 send "$username\n"
	 expect "*sswor*"
	 send "$old_password\n"
	 }
	 "*>*" {
}
}


expect "*>*"
send "show chassis fpc 1\n"

set timeout 10
expect {
	"Online" {
		}
		
	"Offline" {
		set log_msg "SHDSL module did not work - offline"
		exit
		}
		
	"Empty" {
		set log_msg "SHDSL module did not work - empty"
		exit
		}
	
	"Present" {
		set log_msg "SHDSL module not Online"
		exit
		}
	}

send "start shell\n"
expect "*%*"
send "su\n"
expect "*ass*"
send "$password\n"

expect {
	"refused" {
	expect "*%*"
	send "su\n"
	expect "*ass*"
	send "$old_password\n"
	}
	
	"*root*" {
	}
}

send "vty 1\n"
sleep 3
send "connect 17\n"
sleep 3
send "set mshdsl-set-co $Co\n"
sleep 10
send \003
send "exit\n"
sleep 1
send "exit\n"
sleep 1
send "exit\n"
sleep 1
send "exit\n"
sleep 1
send "exit\n"
set log_msg "$CPE_ip_addr start bulid SHDSL"
expect eof

if { [string length $log_msg] > 0 } {
set fd [open /home/handyman/SRX_Train/SHDSL.log a]
puts $fd "[clock format [clock seconds] -format "%Y/%m/%d %H:%M:%S"] $log_msg"
close $fd
}
