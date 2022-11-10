#!/usr/bin/bash
#sleep 10
#
# RX only 2m AFSK (144,800 und 145,825 MHz) und 70cm LoRa APRS iGate mit zwei RTL-SDR USB-Sticks
#
# Folgende Variablen sind in der Datei config.txt einzutragen:
# - MYCALL = Rufzeichen des Digipeaters inklusive SSID
# - PASSCODE = APRS-Passcode für die Serververbindung  (https://apps.magicbug.co.uk/passcode/)
# - SERVERURL = URL des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - SERVERPORT = Port des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# 
# Die Frequenz für den LoRa Empfang wird in der Datei loraqrg.txt angegeben und kann bei Bedarf verändert werden
#
# Folgende Angaben müssen noch händisch angepasst werden:
# - Bakendatei netbeacon.txt: Koordinaten und Bakentext 

# Programmpfad bestimmen und in den Systempfad einfügen
export DXLPATH=$(dirname `realpath $0`)
export PATH=$DXLPATH:$PATH

# Variablen aus Datei config.txt einlesen
while read line; do    
    export $line    
done < $DXLPATH/config.txt

# Vorsorglich beenden wir erstmal alle eventuell laufenden Prozesse
killall -9 rtl_tcp sdrtst udpgate4 udpbox lorarx afskmodem
sleep 1

# Wir starten die SDR Server
xfce4-terminal --minimize --title RTL_TCP_2 -e 'bash -c "rtl_tcp -a 127.0.0.1 -d0 -p 18100 -n 1"' &
sleep 1
xfce4-terminal --minimize --title RTL_TCP_LORA -e 'bash -c "rtl_tcp -a 127.0.0.1 -d1 -p 18101"' &
sleep 1

# Soundpipes anlegen
mknod $DXLPATH/aprspipe p 2> /dev/null
mknod $DXLPATH/lorapipe p 2> /dev/null

# Wir initialisieren die SDR-Empfänger. Bei abweichenden Frequenzen bitte Dateien qrg2.txt und/oder qrglora.txt anpassen
xfce4-terminal --minimize --title SDRTST_2 -e 'bash -c "sdrtst -t 127.0.0.1:18100 -r 16000 -s $DXLPATH/aprspipe -c $DXLPATH/qrg2.txt -e -k -v"' &
sleep 1
xfce4-terminal --minimize --title SDRTST_LORA -e 'bash -c "sdrtst -t 127.0.0.1:18101 -r 250000 -s $DXLPATH/lorapipe -c $DXLPATH/qrglora.txt -k -v"' &
sleep 1

# AFSKMODEM dekodiert die APRS Aussendungen auf 2m
xfce4-terminal --title AFSKMODEM -e 'bash -c "afskmodem -f 16000 -o $DXLPATH/aprspipe -c 2 -M 0 -c 0 -L 127.0.0.1:9201:0 -M 1 -c 1 -L 127.0.0.1:9202:0"' &
sleep 1
# lorarx dekodiert die LoRA APRS Aussendungen auf 70cm
xfce4-terminal --title LORARX -e 'bash -c "lorarx -i $DXLPATH/lorapipe -f i16 -b 7 -s 12 -L 127.0.0.1:9702 -v"' &
sleep 1

# Hier werden alle AXUDP Pakete dupliziert, für die Weiterleitung an das iGate und für die Verwendung von APRSMAP oder des Monitors auf Port 9999 (monitor.sh)
xfce4-terminal --minimize --title UDPBOX -e 'bash -c "udpbox -R 127.0.0.1:9201 -l 127.0.0.1:10201 -r 127.0.0.1:9999 -R 127.0.0.1:9202 -l 127.0.0.1:10202 -r 127.0.0.1:9999 -R 127.0.0.1:9702 -l 127.0.0.1:10702 -r 127.0.0.1:9999 -v"' &
sleep 1

# udpgate4 ist das iGate, welches alle Daten an APRS-IS weiterleitet und das Webinterface bereitstellt
xfce4-terminal --minimize --title UDPGATE4 -e 'bash -c "udpgate4 -s $MYCALL -R 127.0.0.1:0:10201#144800 -R 127.0.0.1:0:10202#145825 -R 127.0.0.1:0:10702#LoRa -H 10080 -I 1440 -u 50 -B 60 -O -n 30:$DXLPATH/netbeacon.txt -g $SERVERURL:$SERVERPORT#m/1,-t/t -p $PASSCODE -t 14580 -w 14501 -D $DXLPATH/www/ -0 -v"' &
