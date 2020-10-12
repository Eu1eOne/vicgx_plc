#!/bin/bash
# PLC-like control on Victron GX Devices
# (c) 2019-present PetaJoule, s.r.o.
# https://github.com/petajoulecorp/vicgx_plc
# MIT License

VENDOR='com.victronenergy'

CMD="dbus-send --print-reply --system --dest=$VENDOR"

GetValue=$VENDOR.BusItem.GetValue
SetValue="$VENDOR.BusItem.SetValue variant:int32"

Int32='$2 ~ /int32/ { print $3 }'

# define paths for values of interest "Name-to-Path"

declare -A N2P=(
    [GRID]=/Ac/Grid/L1/Power                           # are we on grid? yes if > 0
    [REL]=/Relay/0/State                               # relay of CCGX
    [SPK]=/Buzzer/State                                # speaker/buzzer of CCGX
    [ACO_L1]=/Ac/ConsumptionOnOutput/L1/Power          # AC-out L1
)

GRID_TIMER_OUTAGE=0   # how long the grid has been off
GRID_TIMER_DELAY=60   # how long do we wait during grid failure until e.g. alarm

sleep 1
# main loop (endless)
# for constant monitoring, an endless loop with a defined sleep interval
# seems less demanding than establishing a cron job
main() {
    for (( ; ; ))
    do
        GRID=$(qry GRID)
        REL=$(qry REL)     # get relay status
        NO_GRID=$(isnt GRID)   # get grid status

        echo $NO_GRID $GRID $REL $SECONDS $GRID_TIMER

        ### PLC start

        if [[ $GRID -eq 0 && $GRID_TIMER -eq 0 ]]; then
            GRID_TIMER=$SECONDS
        elif [[ $GRID -gt 0 ]]; then
            GRID_TIMER=0
            exe REL 0        
        fi

        if [[ "$GRID_TIMER" -gt 0 && $(($SECONDS - $GRID_TIMER)) -gt 5 ]]; then
            echo "Man the battle stations!"
            exe REL 1
            blip 3
        fi

        ### PLC end

        sleep 1
    done
}

# query status of a dbus endpoint
qry() {
    $CMD.system ${N2P[$1]} $GetValue | awk "$Int32"
}
# query status of a dbus endpoint
is() {
    TMPVAL=$(qry $1)
    [ "$TMPVAL" -ne 0 ]
}
# query status of a dbus endpoint
isnt() {
    ! is $1
}

# execute status change of a dbus endpoint
exe() {
    $CMD.system ${N2P[$1]} $SetValue:$2 > /dev/null
}



# issue a given number of blips for the defined speaker/buzzer device
# unfortunately VenusOS bash has no loadables support, despite this being
# the default since 4.4
# see https://serverfault.com/questions/469247/how-do-i-sleep-for-a-millisecond-in-bash-or-ksh/469249
# but fortunately there is usleep
blip() {
    for (( i=$1; i>=1; i-- ))
    do
        exe SPK 1     # set buzzer/speaker
        usleep 10000  # 1/100s
    done
}

main "$@"; exit
