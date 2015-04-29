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

This script does not save the rules, just in case you mess up ;)
