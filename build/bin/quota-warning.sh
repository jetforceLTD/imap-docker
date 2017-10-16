#!/bin/sh
PERCENT=$1
USER=$2
ADMIN="admin@example.dom"
FROM="hostmaster@example.com"

msg="From: $FROM
To: $USER
Bcc: $ADMIN
Subject: Qota-Warnung $PERCENT% für dein Postfach "$USER" 

Lieber Nutzer,
    
das Postfach $USER ist derzeit zu $PERCENT% gefuellt.

Ist das Postfach voll, werden keine EMails mehr entgegen genommen!

Bitte den Papierkorb leeren und nicht mehr benoetigte Mails loeschen.
       
Herzlichen Dank


echo -e "$msg" | /usr/sbin/sendmail -t -f $FROM "$USER"

exit 0
