# LML DA driver

Used to support monitoring feature of Eclipse PTP 
on the K computer. 

## Installation 

Start Eclipse PTP first and create remote connection
in Eclipse PTP Preferences / Remote Development / Remote Connections.
It is "Built-in SSH" type connections that are used 
for monitoring. 

In Eclipse PTP System Monitoring perspective create
new monitor connection in "Monitors" window.

After you start a monitor connection to a remote system
for the first time, .eclipsesettings directory is created 
in your home directory on the remote system.

Copy files from this repository to the .eclipsesettings directory.

Now your monitor connection in Eclipse PTP should show 
compute nodes map and active jobs of the remote system.
