# Dieses Skript zeigt alle APRS-Pakete in der Konsole an, welche an Port 9999 geschickt werden.
# 
# Konfiguration aus Datei config.txt einlesen
while read line; do    
    export $line    
done < config.txt

# Anwendungspfad definieren
PATH=$DXLPATH:$PATH

# Monitor starten
udpflex -U :0:9999 -V