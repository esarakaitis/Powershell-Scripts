{\rtf1\ansi\ansicpg1252\cocoartf1138\cocoasubrtf470
{\fonttbl\f0\fnil\fcharset0 Calibri;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab720
\pard\pardeftab720

\f0\fs28 \cf0 get-brokerdesktop | Where \{$_.powerstate -eq "off"\} | select machinename, lastconnectionuser > c:\\temp.txt}