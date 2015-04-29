## iptable-tools

A collection of scripts and tools to make dealing with iptables almost fun :)

### iptable-flow.txt
A handy diagram for those times when you just need a clue

### iptable-check.sh
Compares a cleaned-up output from iptables-save against the saved iptables.rules and lets you know if they are different

### iptable-update.sh
Flushes all rules, sets some sane defaults and then loops thru a rules config directory for any scripts.

Contains 2 helper functions:

    inbound(port, network, protocol)
    outbound(port, network, protocol)

The Network and Protocol parameters will default to the value of PUBLICNET (or eth0 if not found) and TCP, The Port parameter is required, but is not touched, so ranges are allowed.

This script does not save the rules, just in case you mess up ;)

#### Examples
- allow inbound SSH: ```inbound(22)```
- allow outbound DHCP: ```outbound("67:68", ${PUBLICNET}, "udp")```
