#!/bin/bash -s

cp mypjstat ../
cp runlml ../
mkdir ../rms/PJM
cp rms/PJM/* ../rms/PJM/
cp samples/* ../samples/
echo -e "If you see no errors then PJM support for LML DA driver was installed.\nYou can now open Eclipse PTP and start Monitor connection to this machine.\n"

