## iptable-tools

```iptable-tools.sh``` is a helper script that can perform the following functions:

    ./iptable-tools.sh [--reset] [--load] [--check] [--flow]

### --reset
Flushes all rules, sets some sane defaults and then loops thru a rules config directory for any scripts.

### --load
Scans the RULESDIR (default is /etc/iptable.d) for any scripts and loads them. Two helper functions are defined to make defining inbound and outbound rules easier:

    inbound  port network protocol
    outbound port network protocol

The Network and Protocol parameters will default to the value of PUBLICNET (or eth0 if not found) and TCP, The Port parameter is required, but is not touched, so ranges are allowed.

This script does not save the rules, just in case you mess up ;)

### --check
Runs ```iptables-save``` and stores the output in /tmp/iptables.chec and then compares it to the saves rules in /etc/iptables.rules

The saved output is cleaned up using ```sed``` to make the comparison using ```diff``` easier.

### --flow
Generates a handy ascii box diagram that shows the iptable flow.

### Examples

    ./iptable-tools.sh --reset --load
    ./iptable-tools.sh --check

## Information

    Author:  bear (Mike Taylor)
    Contact: bear@bear.im
    License: MIT

    Copyright (c) 2015 by Mike Taylor'
