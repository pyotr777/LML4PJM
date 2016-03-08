#!/bin/bash

mkdir -p ../rms/PJM

cp mypjstat ../
cp runlml ../
cp rms/PJM/* ../rms/PJM/
cp samples/* ../samples/
printf "If you see no errors then PJM support for LML DA driver was installed.\nYou can now open Eclipse PTP and start Monitor connection to this machine.\n"

