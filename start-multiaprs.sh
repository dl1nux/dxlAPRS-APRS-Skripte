# RX only iGate auf 144.800 + 145.825 + 432.500 MHz mit 2x RTL-USB Stick sowie LoRa APRS mit SX127x Chip am GPIO
#
# Ausführliche Informationen unter: https://www.dl1nux.de/portables-multi-aprs-igate/
#
# Änderungen zum 08.11.2021
# - Ports über alle Skripte hinweg vereinheitlicht
# - Variablen aus der Datei config.txt werden eingelesen und beim Aufruf automatisch in die Zeilen eingefügt.
#
# Folgende Variablen sind in der Datei config.txt einzutragen:
# - DXLPATH = Pfad zu den Programm- und Textdateien
# - MYCALL = Rufzeichen des Digipeaters inklusive SSID
# - PASSCODE = APRS-Passcode für die Serververbindung  (https://apps.magicbug.co.uk/passcode/)
# - SERVERURL = URL des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - SERVERPORT = Port des entfernten APRS-Servers mit dem sich das iGate verbinden soll
# - LORARX = Empfangsfrequenz für LoRa APRS (Standard = 433.775)
#
# Folgende Angaben müssen noch händisch angepasst werden:
# - Bakendatei netbeacon.txt: Koordinaten und Bakentext (sollten bei beiden identisch sein).
#
# Variablen aus Datei config.txt einlesen
while read line; do    
    export $line    
done < config.txt

# Vorsorglich beenden wir erstmal alle eventuell laufenden Prozesse
sudo killall -9 rtl_tcp sdrtst udpgate4 udpbox afskmodem ra02
sleep 1

# Hier wird der Programmpfad, wo die dxlAPRS Tools und die Textdateien zu finden sind, zum Systempfad hinzugefügt.
PATH=$DXLPATH:$PATH

# Wir starten die SDR Server
rtl_tcp -a 127.0.0.1 -d0 -p 18100 -n 1 &
sleep 1
rtl_tcp -a 127.0.0.1 -d1 -p 18101 -n 1 &
sleep 1

# Soundpipes anlegen
mknod $DXLPATH/aprspipe2 p 2> /dev/null
mknod $DXLPATH/aprspipe70 p 2> /dev/null

# Wir initialisieren die SDR-Empfänger. Bei abweichenden Frequenzen bitte Dateien qrg2.txt und qrg70.txt anpassen
sdrtst -t 127.0.0.1:18100 -r 16000 -s $DXLPATH/aprspipe2 -c $DXLPATH/qrg2.txt -e -k -v &
sleep 1
sdrtst -t 127.0.0.1:18101 -r 16000 -s $DXLPATH/aprspipe70 -c $DXLPATH/qrg70.txt -e -k -v &
sleep 1

# AFSKMODEM dekodiert die APRS Aussendungen
afskmodem -f 16000 -o $DXLPATH/aprspipe2 -c 2 -M 0 -c 0 -L 127.0.0.1:9201:0 -M 1 -c 1 -L 127.0.0.1:9202:0 &
sleep 1
afskmodem -f 16000 -o $DXLPATH/aprspipe70 -c 1 -M 0 -c 0 -L 127.0.0.1:9701:0 &
sleep 1

# Starte LoRa APRS Empfänger ra02
ra02 -p 8 10 9 11 -a -L 127.0.0.1:9702:0 -f $LORARX -v &
sleep 1

# Hier werden alle AXUDP Pakete dupliziert, für die Weiterleitung an das iGate und für die Verwendung von APRSMAP oder des Monitors auf Port 9999 (monitor.sh)
udpbox -R 127.0.0.1:9201 -l 127.0.0.1:10201 -r 127.0.0.1:9999 -R 127.0.0.1:9202 -l 127.0.0.1:10202 -r 127.0.0.1:9999 -R 127.0.0.1:9701 -l 127.0.0.1:10701 -r 127.0.0.1:9999 -R 127.0.0.1:9702 -l 127.0.0.1:10702 -r 127.0.0.1:9999 -v &
sleep 1

# udpgate4 ist das iGate, welches alle Daten an APRS-IS weiterleitet und das Webinterface bereitstellt
udpgate4 -s $MYCALL -R 127.0.0.1:0:10201#144800 -R 127.0.0.1:0:10202#145825 -R 127.0.0.1:0:10701#432500 -R 127.0.0.1:0:10702#LoRa -H 10080 -I 1440 -u 50 -B 60 -O -n 30:$DXLPATH/netbeacon.txt -g $SERVERURL:$SERVERPORT#m/1,-t/t -p $PASSCODE -t 14580 -w 14501 -D $DXLPATH/www/ -0 -v &
