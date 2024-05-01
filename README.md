# check_memory.sh
check_memory.sh is a bash script for Nagios/Icinga that monitors memory and swap usage on a linux system, providing configurable thresholds for warning and critical alerts. The check also outputs performance data in Nagios/Icinga plugin format, providing the actual memory and swap usage percentages.

## Usage
```bash
./check_memory.sh [-w|-c|-W|-C] -h

Options:
    -w: Set warning percentage for memory usage.
    -c: Set critical percentage for memory usage.
    -W: Set warning percentage for swap usage.
    -C: Set critical percentage for swap usage.
    -h: Print help message.
```

Example Usage:
```bash
[root@devbox ~]# ./check_memory.sh -w 70 -c 90 -W 20 -C 30
OK - Memory: 15/100%, Swap: 3/100%| memory=15%;70;90;0; swap=3%;20;30;0
```

## License

This script is licensed under the GPL-3.0 License. For more details, see LICENSE file.
