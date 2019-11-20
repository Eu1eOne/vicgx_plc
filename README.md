# vicgx_plc
PLC-like control in a Victron GX device via Bash script

Skeleton for a programmable logic controller (PLC)-like functionality within a Victron GX device
(see https://www.victronenergy.com/live/venus-os:start)

Besed on internal code of PetaJoule, s.r.o. and inspired by MihaiR code on the Victron Community Forum
https://community.victronenergy.com/questions/34353/this-is-for-those-who-asked-for-a-solution-to-dump.html

In essence, this code allows you to evaluate the states of various sensors in your systems, perform
logical operations on the results/values and based on the results issue actions (switch relays, sound
alarm etc.)

The use of a bash script is due to its simplicity, but mainly due to its future compatibility.
Contrary to the Python (2.7) on the device, where a future 3.x version might bring some woes,
bash has matured and will probably remain unchanged for quite some years to come.
