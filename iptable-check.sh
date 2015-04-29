#!/bin/bash

iptables-save | sed -e '/^[#:]/d' > /tmp/iptables.check

if [ -e /etc/iptables.rules ]; then
  cat /etc/iptables.rules | sed -e '/^[#:]/d' > /tmp/iptables.rules

  diff -q /tmp/iptables.rules /tmp/iptables.check

else
  echo "unable to check, /etc/iptables.rules does not exist"
fi
