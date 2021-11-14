# RX only LoRa APRS iGate mit SX127x Chip am GPIO
#
# Ausführliche Informationen unter: https://www.dl1nux.de/lora-aprs-igate-mit-udpgate4/
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
sudo killall -9 udpgate4 udpbox ra02
sleep 1

# Hier wird der Programmpfad, wo die dxlAPRS Tools und die Textdateien zu finden sind, zum Systempfad hinzugefügt.
PATH=$DXLPATH:$PATH

# Starte LoRa APRS Empfänger ra02
xfce4-terminal --title RA02 -e 'bash -c "ra02 -p 8 10 9 11 -a -L 127.0.0.1:9702:0 -f $LORARX -v"' &
sleep 1

# Hier werden alle AXUDP Pakete dupliziert, für die Weiterleitung an das iGate und für die Verwendung von APRSMAP oder des Monitors auf Port 9999 (monitor.sh)
xfce4-terminal --minimize --title UDPBOX -e 'bash -c "udpbox -R 127.0.0.1:9702 -l 127.0.0.1:10702 -r 127.0.0.1:9999 -v"' &
sleep 1

# udpgate4 ist das iGate, welches alle Daten an APRS-IS weiterleitet und das Webinterface bereitstellt
xfce4-terminal --minimize --title UDPGATE4 -e 'bash -c "udpgate4 -s $MYCALL -R 127.0.0.1:0:10702#LoRa -H 10080 -I 1440 -u 50 -B 60 -O -n 30:$DXLPATH/netbeacon.txt -g $SERVERURL:$SERVERPORT#m/1,-t/t -p $PASSCODE -t 14580 -w 14501 -D $DXLPATH/www/ -0 -v"' &
