# Dieses Skript zeigt alle APRS-Pakete in der Konsole an, welche an Port 9999 geschickt werden.
# 
# Programmpfad bestimmen und in den Systempfad einfügen
export DXLPATH=$(dirname `realpath $0`)
export PATH=$DXLPATH:$PATH

# Monitor starten
udpflex -U :0:9999 -V