# Beispielskripte für APRS mit dxlAPRS
Die vorliegenden Skripte können zusammen mit dxlAPRS von Chris OE5DXL dazu
verwendet werden, ein APRS iGate unter Linux bzw. auf dem RaspberryPi zu
betreiben.

# Neuerungen

Update vom 08.02.2025

Die Skripte für digi-tnc wurden aktualisiert. Fehler beim Dupe-Timing und beim 
www-Pfad wurden ausgebessert. 

Update vom 16.11.2024

Die Skripte in denen "ra02" benutzt wird (LoRa Chip am GPIO) haben einen 
zusätzlichen Hinweis erhalten:

Für die neueren Betriebsystemversionen des RaspberryPi (Bookworm ab 2024) haben 
sich die GPIO Bezeichnungen geändert. Dies betrifft den Betrieb von RA02 mit 
einem an die GPIOs angeschlossenen LoRa Chip. Anstatt "ra02 -p 8 10 9 11 ..." 
muss es abhängig vom verwendeten Modell wie folgt lauten (Bitte unten korrigieren.)

- RaspberryPi bis Version 4: "ra02 -p 520 522 521 523 ..."
- RaspberryPi ab Version 5 : "ra02 -p 579 581 580 582 ..."

Überprüfen kann man dies mit dem Befehl: cat /sys/kernel/debug/gpio
unter "gpiochip0:" sind dann die anzugebenden GPIOs für GPIO8,10,9,11 aufgeführt.

Update vom 12.10.2024:

Skripte zur Anbindung eines ESP32 LoRa Boards mit CA2RXU Software hinzugefügt.
Info: https://www.dl1nux.de/lora-aprs-gateway-mit-dxlaprs-und-ttgo-lora-board/

Update vom 01.05.2023

- QRGx.TXT Dateien Hinweis hinzugefügt.
- Update FAQs

Update vom 10.11.2022

Hinzugefügt 2m APRS und 70cm LoRa APRS mit zwei SDR-Sticks:
- start-2-lora-sdr-gui.sh
- start-2-lora-sdr.sh
Anpassungen im Kommentar vorgenommen:
- start-lora-sdr-gui.sh 
- start-lora-sdr.sh

Update vom 13.08.2022

Skripte und Dateien für LoRa APRS Empfang mit SDR-Stick wurden hinzugefügt.
- start-lora-sdr.sh für abgesetzten Betrieb über die Konsole
- start-lora-sdr-gui.sh für überwachten Betrieb in der GUI
- qrglora.txt enthält die QRG Konfiguration für den SDR Server
Damit die Skripte genutzt werden können, muss das Programm "lorarx" von OE5DXL
vorhanden sein. Dieses ist erst seit Mai 2022 verfügbar und muss bei älteren
Installationen ggf. manuell hinzugefügt werden.

Update vom 09.02.2022

Die Variable "DXLPATH" wurde aus der config.txt entfernt, da die Variable bzw.
der Pfad direkt im Skript anhand des Speicherorts des Skripts automatisch
ermittelt wird. Damit existiert eine Fehlerquelle weniger. Es müssen sich
weiterhin alle Skript-Dateien und Textdateien (inkl. config.txt) im selben
Verzeichnis befinden.

Update vom 06.11.2021

In der aktuellen Version der Skripte müssen nicht mehr die Skripte selber an
die eigenen Bedürfnisse angepasst werden. Die wichtigen Einstellungen, die für
den Standarduser notwendig sind, können in einer zentralen Datei (config.txt)
als Variablen hinterlegt werden (z.B. Rufzeichen, Passcode, APRS-Server). Die
Skripte lesen diese Variablen beim Start ein und setzen Sie an die vorgesehne
Stelle im Skript ein.

**Vorteile:**
* Mit einer Konfigurationsdatei können alle Skripte verwendet werden, ohne 
  jedes einzelne anpassen zu müssen.
* Müheloses Eintragen der eigenen Daten und damit Vermeidung von Fehlern. 
* Individuelle Änderungen an den Skripten sind weiterhin möglich.
* Bei Bedarf können zusätzliche eigene Variablen hinzugefügt werden.

# Benötigte Hardware
Für den Empfang von APRS Signalen in AFSK werden USB RTL-SDR Sticks verwendet 
(z.B. Nooelec NESDR Smart). 

Für LoRa APRS können alle Module eingesetzt werden, welche einen SX127X LoRa 
Chip verwenden und direkt über die MISO/MOSI/NSS/SCK Pins angesprochen werden 
können. Außerdem darf im RasPi die SPI-Schnittstelle nicht aktiv sein, da RA02
die GPIO Pins direkt ansprechen möchte. Weitere Infos siehe hier:
https://www.dl1nux.de/lora-aprs-gateway-mit-einem-raspberrypi-diese-methoden-gibt-es/

Inzwischen kann man LoRa APRS auch mit einem RTL SDR USB Stick (nur RX) oder
auch mit einem ESP32 Board per USB (z.B. TTGO LoRa) nutzen.

Der APRS-Digi benötigt ein KISS/SMACK TNC welches über eine serielle 
Schnittstelle oder einen USB/Seriell-Wandler an den Rechner angeschlossen ist.

## Hinweise zur Nutzung eines ESP32 LoRa Boards per USB
Für die ESP32 LoRa Boards gibt es Software, die eine serielle KISS Verbindung
über den USB Anschluss bereitstellen kann. Software aus Polen oder von DL9SAU
konnte das schon länger. Inzwischen ist auch die Software von Ricardo CA2RXU
dafür geeignet. Diese ist auch zu empfehlen, da sie am einfachsten einzurichten
ist. 
Kurzanleitung: 
1. ESP32 über Webflasher von Ricardo mit Software bespielen
2. Einmalig per WLAN Hotspot mit dem ESP32 Board verbinden
3. Über den Browser die Weboberfläche aufrufen und den seriellen KISS Mode
   über USB aktivieren. Weitere Einstellungen sind am ESP32 nicht notwendig.

Die Baudrate liegt standardmäßig bei 115200 Baud. Der notwendige Port /dev/tty...
muss ausfindig gemacht werden (z.B. ttyUSB0 oder ttyACM0). Beides muss in der
config.txt unter TTYBAUD und TTYPORT hinterlegt werden.

Link zur Software: 
https://github.com/richonguzman/LoRa_APRS_iGate
Ausführliche Anleitung: 
https://www.dl1nux.de/lora-aprs-gateway-mit-dxlaprs-und-ttgo-lora-board/

# Welche Anpassungen müssen wo vorgenommen werden?
Alle wichtigen Einstellungen sind in der Datei config.txt zu machen. Damit
die Informationen auch eingelesen werden können, muss sich die Datei im selben
Ordner befinden wie die Skriptdateien (*.sh).

## In der Datei config.txt müssen die folgenden Variablen ZWINGEND gesetzt werden:
* MYCALL = Rufzeichen des iGates inklusive SSID, z.B. DL1XYZ-10
* PASSCODE = APRS-Passcode für die Serververbindung (https://apps.magicbug.co.uk/passcode/)

## Folgende Variablen sind nur bei Bedarf anzupassen
* SERVERURL = URL des entfernten APRS-Servers mit dem sich das iGate verbinden
  soll. Standardmäßig wird ein zufälliger Server im Internet kontaktiert 
  (z.B. rotate.aprs2.net).
* SERVERPORT = Port des entfernten APRS-Servers mit dem sich das iGate verbinden
  soll. Standardmäßig ist das Port 14580. Bei Abweichungen bitte ändern!
* TTYPORT = Devicename und -Pfad zum TNC, z.B. /dev/ttyUSB0 (nur für das Skript
  "start-digi-tnc" oder "start-lora-rx-esp32" erforderlich).
* TTYBAUD = Baudrate der Verbindung zum TNC (nur für das Skript 
  "start-digi-tnc" oder "start-lora-rx-esp32" erforderlich).
* TXDELAY = TX-Delay in *10 ms für den Sender am TNC (nur für das Skript 
  "start-digi-tnc" erforderlich).
* LORARX = Empfangsfrequenz für den LoRa APRS Empfänger (Standard=433.775 MHz).
* LORATX = Sendefrequenz für den LoRa APRS Sender (Standard = 433.775 MHz).

Die letzten beiden Variablen für LoRa APRS werden nur benötigt, wenn dafür
dedizierte Hardware genutzt wird, z.B. eine Aufsteckplatine mit LoRa Chip.
Beim Empfang via SDR-Stick muss die Frequenz manuell in der qrglora.txt
gepflegt werden.

Die Variable DUMMY=Platzhalter-stehen-lassen bitte so stehen lassen. Dies dient
nur dazu hinter der letzten Variable noch eine Zeile stehen zu haben damit die
letzte Variable auch sicher eingelesen wird.

## Sonstiges
Für alle Skripte ist zusätzlich die Datei **netbeacon.txt** anzupassen. Bei 
den Varianten mit Sendezweig (z.B. digi-tnc, LoRa-RxTx) ist zusätzlich noch 
die Datei **digibeacon.txt** anzupassen.

Es ist empfehlenswert die Hinweise in jeder Skriptdatei zu lesen und ggf. zu 
befolgen.

# Welche Dateien gehören wo hin?
Nach dem Download aller Dateien müssen die Skript- und Textdateien (*.txt
und *.sh) in den dxlAPRS Programmordner kopiert werden, also z.B.
nach /home/pi/dxlAPRS/aprs/.

Alle Desktop-Dateien (*.desktop) sind Verknüpfungen, welche in einer grafischen
Oberfläche (z.B. Pixel auf dem Pi) zum Starten der einzelnen Skripte verwendet
werden können. Diese müssen in den "Desktop" Ordner kopiert werden, damit die 
Symbole auf dem Desktop erscheinen. Dieser Ordner befindet sich im Home 
Verzeichnis des Users und heißt in der Regel "Desktop". Auf dem Raspberry Pi 
ist es der Ordner /home/pi/Desktop.

# Welche Skripte machen was?
* start-2.sh (RX only iGate auf 144.800 + 145.825 MHz mit 1x RTL-SDR USB Stick)
* start-70.sh (RX only iGate auf 432.500 mit 1x RTL-SDR USB Stick)
* start-2-70.sh (RX only iGate auf 144.800 + 145.825 + 432.500 MHz mit 2x 
  RTL-SDR USB Sticks)
* start-lora-rx.sh (RX only LoRa APRS iGate mit SX127x Chip am GPIO)
* start-lora-rxtx.sh (RX+TX LoRa APRS iGate mit SX127x Chip am GPIO)
* start-multiaprs.sh (RX only iGate auf 144.800 + 145.825 + 432.500 MHz mit 2x
  RTL-SDR USB Sticks sowie LoRa APRS mit SX127x Chip am GPIO)
* start-digi-tnc.sh (RX/TX Digipeater und iGate unter Verwendung eines TNC mit
  angeschlossenem Funkgerät)
* start-lora-sdr.sh (RX only iGate für LoRa APRS mit RTL-SDR USB Stick)
* start-2-lora-sdr.sh (RX only iGate für 2m AFSK und 70cm LoRa APRS mit 2x 
  RTL-SDR USB Sticks)
* start-lora-rx-esp32.sh (RX only iGate mit ESP32 Board via USB)

Alle Start-Skripte gibt es auch in einer zweiten Variante mit der Endung 
"-gui" im Dateinamen. Diese sind für die Verwendung in einer grafischen 
Oberfläche gedacht (z.B. "Pixel" auf dem RaspberryPi). Dabei wird jedes 
Programm in einem eigenen Fenster dargestellt. Dies ermöglicht das einfache und
bequeme Beobachten der einzelnen Bildschirmausgaben und hilft auch bei der 
Fehlersuche im Fehlerfall. Auch lässt sich damit die Arbeitsweise der dxlAPRS 
Tools gut studieren und erlernen.

Damit dies gelingt muss erst das Programm xfce4-terminal installiert werden.
Installationsroutine siehe weiter unten.
    
## Weitere Skripte
* stop.sh (Beendet alle Prozesse die durch die Tools gestartet wurden)
* monitor.sh (Zeigt alle Pakete an Port 9999 an. Siehe Info weiter unten.)

# Die Bedeutung der Text-Dateien
* config.txt (Enthält die wichtigen Konfigurationsvariablen für die Skripte)
* digibeacon.txt (Hier stehen Baken drin die auf dem Funk-Weg ausgestrahlt 
  werden sollen - nur bei sendenden iGates relevant)
* frametypes.txt (Enthält eine Aufschlüsselung der Pakettypen die bei der 
  Konfiguration eines Digipeaters Anwendung finden)
* netbeacon.txt (Enthält die Bake welche das iGate an das APRS-IS Netzwerk 
  über Internet/Hamnet aussendet)
* qrg2.txt (Frequenzdatei und SDR Parameter für sdrtst für 2m)
* qrg70.txt (Frequenzdatei und SDR Parameter für sdrtst für 70cm AFSK)
* qrglora.txt (Frequenzdatei und SDR Parameter für sdrtst für 70cm LoRa APRS)

# Was macht die Datei "monitor.sh"
monitor.sh startet eine Instanz von udpflex und zeigt alle APRS Pakete an, 
welche an Port 9999 gesendet werden. In allen Skripten werden alle empfangenen
Pakete zusätzlich in Kopie an Port 9999 gesendet. Man kann die Daten an diesem
Port beispielsweise verwenden um sie sich in APRSMAP anzeigen zu lassen. Mit 
der monitor.sh können diese APRS Pakete aber auch an der Konsole "sichtbar" 
gemacht werden, quasi wie in einem "Monitor" wie man es von Packet Radio
Programmen her kennt. Dies ermöglicht einen Live-Blick auf das aktuelle
Empfangsgeschehen am iGate. Dies kann kan auch vermeintlichen Empfangsproblemen
als Unterstützung dienen.

# dxlAPRS Installation (nicht notwendig beim fertigen Image)

## dxlAPRS Grundinstallation:

    cd ~
    wget http://dxlaprs.hamspirit.at/dxlAPRS_armv7hf-current.tgz
    tar xzvf dxlAPRS_armv7hf-current.tgz --strip=1 scripts/updateDXLaprs
    ./updateDXLaprs dxlAPRS_armv7hf-current.tgz

## Alle Programmdateien aktualisieren:

    cd ~
    git clone https://github.com/dl1nux/dxlAPRS-update.git
    cp dxlAPRS-update/dxl-update.sh ~
    ./dxl-update.sh

## Installation des Programmpakets für die Verwendung der USB RTL-SDR Sticks:

    sudo apt install rtl-sdr

## Installation der udev rules, falls Linux die falschen Treiber lädt:

    sudo nano /etc/udev/rules.d/20.rtlsdr.rules

## Dort folgende Zeilen einfügen und speichern mit STRG+O

    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838",GROUP="adm", MODE="0666", SYMLINK+="rtl_sdr"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832",GROUP="adm", MODE="0666", SYMLINK+="rtl_sdr"

## Für die Nutzung der "gui" Skripte wird xfce4-terminal benötigt:

    sudo apt install xfce4-terminal

# AUTOSTART

Möchte man Skripte bei jedem Start des Rechners automatisch starten gibt es 
mehrere Möglichkeiten, hier werden die einfachsten davon genannt.

Wichtig: Die Skripte sollten immer zeitverzögert starten damit das System Zeit 
hat sich sauber hochzufahren. Dazu muss die Auskommentierung der folgenden
Zeile zu Beginn des Skripts entfernt werden (Raute am Zeilenanfang entfernen).

    sleep 10

Dieser Befehl versetzt das Skript 10 Sekunden in eine Warteschleife bevor es 
weiter abgearbeitet wird. Der Zeitwert kann bei Bedarf angepasst werden.

## Autostart an einem System ohne grafische Oberfläche

Start über CRONTAB:

    sudo nano /etc/crontab

Ans Ende der CRON Tabelle setzt ihr folgende Zeile:

    @reboot pi /home/pi/dxlAPRS/aprs/start-skript.sh

Erste Spalte  = Starte beim Reboot
Zweite Spalte = User unter dem der Befehl ausgeführt wird 
                (möglichst als User und nicht als root ausführen)
Dritte Spalte = Kompletter Pfad zum Startskript inkl. richtigem Dateinamen.

Das Skript sollte nun bei jedem Hochfahren des RasPi/Linux Rechners automatisch
als User "pi" starten.

## Autostart in der grafischen Oberfläche

Möchte man eines der Startskripte beim Hochfahren des Rechners mitstarten 
lassen, kopiert man die entsprechende *.desktop Datei für das Starten des 
Skriptes in den Ordner ~/.config/autostart . Die *.desktop Dateien befinden 
sich im Unterordner "Desktop" des Github Repositories. Der Ordner 
~/.config/autostart fehlt meistens und muss erst vorher erstellt werden.

Beispiel: (das Github repository befeindet sich in ~/dxlAPRS-APRS-Skripte/)

    mkdir ~/.config/autostart
    cd ~/dxlAPRS-APRS-Skripte/Desktop
    cp desktop-multiaprs.desktop ~/.config/autostart

Natürlich kann man die *.desktop-Datei auch per Drag & Drop in den Ordner 
kopieren. Falls der Ordner ~/.config nicht sichtbar ist, liegt es daran, dass
der Ordner als "Versteckt" gekennzeichnet ist. Man muss dem Dateimanager erst
sagen, dass er diesen anzeigen soll. Im Dateimanager unter RaspberryPi OS
geschieht dies im Menü des Dateimanagers unter "Ansicht" + "Versteckte 
anzeigen".

# FAQ
**Frage:**
Mein SDR Stick hat keinen TCXO. Wo gebe ich die Freuqenzabweichung in PPM ein?

Antwort:
In der Datei qrg2.txt bzw. qrg70.txt ist dies der Parameter P 5 0. Ersetze die 
0 durch die Abweichung in PPM.

**Frage:**
Mein LoRa Chip liegt nicht genau auf der Frequenz. Wo gebe ich die 
Frequenzabweichung in PPM ein?

Antwort:
Dazu muss beim Aufruf von "ra02" ein zusätzlicher Parameter gesetzt werden. 
Einfach -P <ppm> in die Zeile einfügen.

**Frage:**
Ich habe zwei SDR Sticks an einer Antenne mit einer Weiche 2m/70cm und vermute,
dass die Antenneneingänge vertauscht sind. Dadurch hören die Sticks nichts.
Kann man das durch die Konfiguration beeinflussen ohne die Antennenanschlüsse
zu verändern?

Antwort:
Ja, kann man. Die jeweiligen SDR Sticks werden durch rtl_tcp mit dem 
Parameter -d angesprochen. Vertauscht man nun -d0 mit -d1 bei den beiden
Aufrufen von rtl_tcp, wird jeweils der andere Stick mit dem anderen
Antennenanschluss verwendet. Alternativ kann man natürlich entweder den
Antennenanschluss wechseln oder die zwei USB Sticks an den USB Ports
miteinander vertauschen. Der Effekt ist der Gleiche.

**Frage**
Was ist aus der Datei "99-gpio.rules" geworden die es hier vorher mal gab?

Antwort:
Diese Datei mit udev rules wird nicht mehr benötigt. Chris OE5DXL hat das Tool
ra02 so umgebaut, dass es mit normalen User-Rechten läuft.

**Frage**
Ich habe die QRG2.TXT geändert weil ich nur die Frequenz 144.800 MHz empfangen
möchte, und nun empfange ich gar nichts mehr!

Antwort:
Die QRG2.TXT gehört zu den start-2.sh Skripten und ist für 2-Kanal-Empfangs-
betrieb ausgelegt. Wenn man die zweite Frequenz aus der QRG2.TXT löscht oder
auskommentiert, funktioniert das Skript nicht mehr wie es soll und man
empfängt gar nichts mehr. Für diesen Zweck müsste auch das start-2.sh Skript
geändert werden. Einfacher ist es jedoch das start-70.sh Skript zu verwenden.
Dieses basiert auf 1-Kanal Empfang. Hier kann man einfach in der QRG70.TXT
die Empfangsfrequenz auf 144,800 MHz ändern. Damit die Kanalbezeichnung im
Webinterface dann auch noch passt, kann man im Skript start-70.sh den 
Kanalnamen von #432500 in #144800 ändern.

##############################################################################

Disclaimer:
Diese Anleitung wurde mit bestem Wissen und Gewissen und mit Hilfe des 
Entwicklers Christian OE5DXL erstellt. Aber auch hier kann sich natürlich der 
Fehlerteufel verstecken. Deshalb sind alle Angaben ohne Gewähr! Auch geht die 
Entwicklung der dxlAPRS Tools immer weiter, was auch Veränderungen mit sich 
bringen kann. Wenn ihr einen Fehler findet oder Fragen habt, zögert nicht mich 
zu kontaktieren.

Danksagungen:
- Chris OE5DXL für seine unersatzbare Arbeit an den dxlAPRS Tools
- Michael DL5OCD für die geniale Idee mit der config.txt
- Peter DK4KP für die Perfektonierung der Programmpfadbestimmung
- Al Maecht G0D für viele Inspirationen

Kontaktmöglichkeiten:

    * per E-Mail attila [at] dl1nux . de
    * per IRC Chat im Hamnet (HamIRCNet) im Kanal #hamnet-oberfranken
    * per Packet-Radio im DL/EU Converse Kanal 501

Support:
* dxl-Wiki: http://dxlwiki.dl1nux.de
* Telegram-Gruppe: https://t.me/joinchat/CRNMIBpKRcfQEBTPKLS0zg