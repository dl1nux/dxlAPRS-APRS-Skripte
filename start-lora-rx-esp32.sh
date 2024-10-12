#!/usr/bin/bash
#sleep 10
#
# RX only LoRa APRS iGate mit ESP32 LoRa Board und CA2RXU Software
#
# Ausführliche Informationen unter: https://www.dl1nux.de/lora-aprs-gateway-mit-dxlaprs-und-ttgo-lora-board/
#
# Folgende Variablen sind in der Datei config.txt einzutragen:
# - MYCALL = Rufzeichen des Digipeaters inklusive SSID
# - PASSCODE = APRS-Passcode für die Serververbindung  (https://apps.magicbug.co.uk/passcode/)
# - SERVERURL = URL des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - SERVERPORT = Port des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - TTYPORT = Port (/dev/tty...) an dem das ESP32 Board per USB angeschlossen ist (z.B. /dev/ttyACM0, /dev/ttyUSB0 etc.)
# - TTYBAUD = Serielle Baudrate zum ESP32 Board (normalerweise 115200)
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
sudo killall -9 udpgate4 udpbox udpflex
sleep 1

# Starte LoRa APRS Empfänger ESP32
udpflex -t $TTYPORT:$TTYBAUD -U 127.0.0.1:9702:0 -V &
sleep 1

# Hier werden alle AXUDP Pakete dupliziert, für die Weiterleitung an das iGate und für die Verwendung von APRSMAP oder des Monitors auf Port 9999 (monitor.sh)
udpbox -R 127.0.0.1:9702 -l 127.0.0.1:10702 -r 127.0.0.1:9999 -v &
sleep 1

# udpgate4 ist das iGate, welches alle Daten an APRS-IS weiterleitet und das Webinterface bereitstellt
udpgate4 -s $MYCALL -R 127.0.0.1:0:10702#LoRa -H 10080 -I 1440 -u 50 -B 60 -O -n 30:$DXLPATH/netbeacon.txt -g $SERVERURL:$SERVERPORT#m/1,-t/t -p $PASSCODE -t 14580 -w 14501 -D $DXLPATH/www/ -0 -v &
