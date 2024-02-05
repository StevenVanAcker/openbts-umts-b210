#!/bin/bash -e

HERE=$(dirname $(readlink -f $0))
# FIXME
# https://github.com/84KaliPleXon3/OpenBTS-UMTS?tab=readme-ov-file#programming-your-own-usim-card

sqlite3 /etc/OpenBTS/OpenBTS-UMTS.db <<EOF
update CONFIG set VALUESTRING="901" where KEYSTRING="GSM.Identity.MCC";
update CONFIG set VALUESTRING="901" where KEYSTRING="UMTS.Identity.MCC";
update CONFIG set VALUESTRING="70" where KEYSTRING="GSM.Identity.MNC";
update CONFIG set VALUESTRING="70" where KEYSTRING="UMTS.Identity.MNC";
update CONFIG set VALUESTRING="NinjaTelCo" where KEYSTRING="GSM.Identity.ShortName";
update CONFIG set VALUESTRING="2" where KEYSTRING="GSM.Radio.RxGain";
update CONFIG set VALUESTRING="20" where KEYSTRING="UMTS.Radio.RxGain";
update CONFIG set VALUESTRING="^90170" where KEYSTRING="Control.LUR.OpenRegistration";
update CONFIG set VALUESTRING="0" where KEYSTRING="GSM.Radio.PowerManager.MaxAttenDB";
update CONFIG set VALUESTRING="1" where KEYSTRING="GPRS.Enable";
update CONFIG set VALUESTRING="0" where KEYSTRING="GGSN.Firewall.Enable";
update CONFIG set VALUESTRING="8.8.8.8" where KEYSTRING="GGSN.DNS";
update CONFIG set VALUESTRING="900" where KEYSTRING="UMTS.Radio.Band";
update CONFIG set VALUESTRING="3050" where KEYSTRING="UMTS.Radio.C0";
EOF

sipauthserve &

cat $HERE/simcards.csv |grep -v '#' | while read msisdn imsi ki opc;
do
	echo "Provisioning IMSI $imsi (MSISDN=$msisdn)"

	/opt/OpenBTS/NodeManager/nmcli.py sipauthserve subscribers create ue$msisdn IMSI$imsi $msisdn $ki; 
done

# chown asterisk: /var/lib/asterisk/sqlite3dir/*

cat > /etc/odbcinst.ini <<EOF
[SQLite]
Description=SQLite ODBC Driver
Driver=libsqliteodbc.so
Setup=libsqliteodbc.so
UsageCount=1

[SQLite3]
Description=SQLite3 ODBC Driver
Driver=libsqlite3odbc.so
Setup=libsqlite3odbc.so
UsageCount=1
EOF
