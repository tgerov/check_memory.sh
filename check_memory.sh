#!/bin/bash
# check_memory.sh v1.0 - Bash script for Nagios/Icinga that monitors memory and swap usage.
# Author: Tsvetan Gerov <tsvetan@gerov.eu>
# License: GPL-3.0
#
# ChangeLog
# Sun Mar 17 13:46:18 EET 2024 - Tsvetam Gerov <tsvetan@gerov.eu> 1.0
# - Initial version
# +--------------------------+

#### Set default values
MEMCRITICAL="90"
MEMWARNING="80"
SWAPCRITICAL="90"
SWAPWARNING="80"

### Functions
Help() {
   echo "check_memory.sh"
   echo
   echo "Syntax: check_memory.sh [-w|-c|-W|-C]-h"
   echo
   echo "Options:"
   echo "w     Warning percentage for memory usage"
   echo "c     Critical percentage for memory usage"
   echo "W     Warning percentage for swap usage"
   echo "C     Critical percentage for swap usage"
   echo "h     Print this help"
   echo
   exit 3
}

check_memory() {
    usedMemory=$(awk '/^MemTotal:/ {total = $2;}
                /^MemFree:/ {free = $2;}
                /^MemAvailable:/ {avail = $2;}
                /^Buffers:/ {buffers = $2;}
                /^Cached:/ {cached = $2;
                    if (avail == "") avail = free + buffers + cached;
                        printf "%d\n", (total - avail) / total * 100;}' /proc/meminfo)
    if [ $usedMemory -gt $MEMCRITICAL ]; then
        CRITICAL=true
        ERROR_MESSAGE+="Memory usage $usedMemory/100%, "
    elif [ $usedMemory -gt $MEMWARNING ]; then
        WARNING=true
        ERROR_MESSAGE+="Memory usage $usedMemory/100%, "
    fi
}

check_swap() {
    TOTALSWAP=$(grep SwapTotal /proc/meminfo  | awk '{print$2}')
    usedSwap="0"
    if [ $TOTALSWAP -ne "0" ]; then
        usedSwap=$(awk '/^SwapCached:/ {cached = $2;}
                    /^SwapTotal:/ {total = $2;}
                    /^SwapFree:/ {free = $2;
                    printf "%d\n", (total - free - cache) / total * 100}' /proc/meminfo)
        if [ $usedSwap -gt $SWAPCRITICAL ]; then
            CRITICAL=true
            ERROR_MESSAGE+="Swap usage $usedSwap/100%, "
        elif [ $usedSwap -gt $SWAPWARNING ]; then
            WARNING=true
            ERROR_MESSAGE+="Swap usage $usedSwap/100%, "
        fi
    fi
}

### Get Opts
while getopts w:c:W:C:h flag
do
    case "${flag}" in
        w) MEMWARNING=${OPTARG};;
        c) MEMCRITICAL=${OPTARG};;
        W) SWAPWARNING=${OPTARG};;
        C) SWAPCRITICAL=${OPTARG};;
        h) Help;;

    esac
done

### Perform checks
check_memory
check_swap

### Return final state
if [ "$CRITICAL" = true ]; then
    echo "CRITICAL - ${ERROR_MESSAGE%, }"
    exit 2
elif [ "$WARNING" = true ]; then
    echo "WARNING - ${ERROR_MESSAGE%, }"
    exit 1
else
    echo "OK - Memory: $usedMemory/100%, Swap: $usedSwap/100%| memory=$usedMemory%;$MEMWARNING;$MEMCRITICAL;0; swap=$usedSwap%;$SWAPWARNING;$SWAPCRITICAL;0;"
    exit 0
fi
