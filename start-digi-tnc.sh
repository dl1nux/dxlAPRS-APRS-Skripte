#!/usr/bin/bash
#sleep 10
#
# RX/TX Digipeater und iGate unter Verwendung eines TNC mit angeschlossenem Funkgerät
#
# Warnung: Diese Konfiguration erzeugt ein sendendes APRS iGate. 
# Dieses darf unbemannt nur mit einer gültigen Relais-Genehmigung erfolgen!
#
# Ausführliche Informationen unter: https://www.dl1nux.de/aprs-digi-auf-raspberrypi-oder-linux-mit-dxlaprs-und-tnc/
#
# Folgende Variablen sind in der Datei config.txt einzutragen:
# - MYCALL = Rufzeichen des Digipeaters inklusive SSID (muss zusätzlich noch händisch in der digibeacon.txt angepasst werden!!!)
# - PASSCODE = APRS-Passcode für die Serververbindung  (https://apps.magicbug.co.uk/passcode/)
# - SERVERURL = URL des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - SERVERPORT = Port des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - TTYPORT = Devicename und -Pfad zum TNC
# - TTYBAUD = Baudrate der Verbindung zum TNC
# - TXDELAY = TX-Delay für den Sender. Angabe in *10 ms. Bitte so unbedingt klein wie möglich halten!!!
#
# Folgende Angaben müssen noch händisch angepasst werden:
# - Bakendateien (netbeacon.txt und digibeacon.txt) Koordinaten und Bakentext (sollten bei beiden identisch sein).
# - Aussenderadius in km für APRS-IS Aussendungen über HF (udpgate4 -R ...#10:"20"... entspricht 20km Radius um die angegebenen Koordinaten in der netbeacon.txt)
#   Bitte diesen Wert so klein wie möglich halten! Wird der Wert entfernt, werden trotzdem weiterhin APRS-Nachrichten mit ausgesendet!

# Programmpfad bestimmen und in den Systempfad einfügen
export DXLPATH=$(dirname `realpath $0`)
export PATH=$DXLPATH:$PATH

# Variablen aus Datei config.txt einlesen
while read line; do    
    export $line    
done < $DXLPATH/config.txt

# Sicherheitshalber bereits bestehende Prozesse beenden
killall -9 udpgate4 udpbox udpflex
sleep 1

# KISS Verbindung zum TNC herstellen
udpflex -t $TTYPORT:$TTYBAUD -k -d 5000 -p 1:$TXDELAY -p 2:255 -p 3:10 -p 128:0 -U 127.0.0.1:9201:9299 -u -V &
sleep 1

# APRS Digi starten (Port 9999 dient zum etwaigen monitoren der Frequenz mit "udpflex -U :0:9999 -V" in der Konsole)
# Eine HF-Bake wird periodisch ausgesendet. Der Digipeater ist aktiv.
udpbox -R 127.0.0.1:9201 -l 127.0.0.1:10201 -r 127.0.0.1:9999 -d $MYCALL -p 0,1,2,5,8,17 -t 1740,28 -f p28,29,33,35-39,41-43,46,47,58,59,61,64,91,95,96,123 -k 0/0/20000 -b 600:$DXLPATH/digibeacon.txt -x APLWS*,NOCALL -l 127.0.0.1:9299 -v & 
sleep 1

# udpgate4 ist das iGate, welches alle Daten an APRS-IS weiterleitet und das Webinterface bereitstellt
udpgate4 -s $MYCALL -R 127.0.0.1:9299:10201+10:0#144800 -H 10080 -I 1440 -u 50 -B 60 -O -n 30:$DXLPATH/netbeacon.txt -g $SERVERURL:$SERVERPORT#m/100,-t/t,-u/APLWS*/APRARX -p $PASSCODE -t 14580 -w 14501 -v -D /home/pi/dxlAPRS/aprs/www/ -0 -v &
