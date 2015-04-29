#!/bin/bash

# inbound(port, network, protocol)
function inbound {
  if [ -z "$1" ]; then
    echo "inbound rules require a port value"
    exit 2
  fi
  if [ -z "$2" ]; then
    INBOUNDNET=${PUBLICNET}
  else
    INBOUNDNET=$2
  fi
  if [ -z "$3" ]; then
    INBOUNDPROTO="tcp"
  else
    INBOUNDPROTO=$3
  fi

  iptables -A INPUT  -i ${INBOUNDNET} -p ${INBOUNDPROTO} --dport $1 -m state --state NEW,ESTABLISHED -j ACCEPT
  iptables -A OUTPUT -o ${INBOUNDNET} -p ${INBOUNDPROTO} --sport $1 -m state --state ESTABLISHED     -j ACCEPT
}

# outbound(port, network, protocol)
function outbound {
  if [ -z "$1" ]; then
    echo "outbound rules require a port value"
    exit 2
  fi
  if [ -z "$2" ]; then
    INBOUNDNET=${PUBLICNET}
  else
    INBOUNDNET=$2
  fi
  if [ -z "$3" ]; then
    INBOUNDPROTO="tcp"
  else
    INBOUNDPROTO=$3
  fi

  iptables -A OUTPUT -o ${INBOUNDNET} -p ${INBOUNDPROTO} --dport $1 --state NEW,ESTABLISHED -j ACCEPT
  iptables -A INPUT  -i ${INBOUNDNET} -p ${INBOUNDPROTO} --sport $1 --state ESTABLISHED     -j ACCEPT
}

# rules(path-to-rules-dir)
function rules {
  if [ -z "$1" ]; then
    echo "rules path required"
    exit 2
  fi
  if [ -d "$1" ]; then
    for s in ${RULESDIR}/*.sh ; do
      if [ -e "${s}" ]; then
        source ${s}
      fi
    done
  fi
}

#
# Clear everything from iptables, establish default drop
# and then set rules for common ports
#
# RULESDIR will default to /etc/iptables.d
# PUBLICNET will default to eth0 unless you override it
#

if [ -z "${PUBLICNET}" ]; then
  PUBLICNET="eth0"
fi

if hash ip6tables 2>/dev/null; 
  IP6="found"
else
  IP6=""
fi

iptables  -F
if [ "$IP6"="found" ]; then
  ip6tables -F
  ip6tables -X
  ip6tables -t mangle -F
  ip6tables -t mangle -X
fi

# Default policy is drop
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

if [ "$IP6"="found" ]; then
  ip6tables -P INPUT DROP
  ip6tables -P OUTPUT DROP
  ip6tables -P FORWARD DROP
fi

# Allow localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

if [ "$IP6"="found" ]; then
  ip6tables -A INPUT  -i lo -j ACCEPT
  ip6tables -A OUTPUT -o lo -j ACCEPT
fi

# Allow inbound ipv6 icmp
if [ "$IP6"="found" ]; then
  ip6tables -A INPUT  -i ${PUBLICNET} -p ipv6-icmp -j ACCEPT
  ip6tables -A OUTPUT -o ${PUBLICNET} -p ipv6-icmp -j ACCEPT
fi 

# Allow incoming SSH
inbound(22)
# iptables -A INPUT  -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Allow outgoing SSH
outbound(22)
# iptables -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A INPUT  -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Allow outbound DHCP
outbound("67:68", ${PUBLICNET}, "udp")
# iptables -A OUTPUT -p udp --dport 67:68 -j ACCEPT
# iptables -A INPUT  -p udp --sport 67:68 -j ACCEPT

# Allow outbound DNS
outbound("53", ${PUBLICNET}, "udp")
# iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
# iptables -A INPUT  -p udp --sport 53 -j ACCEPT

# Allow only NTP if it's our request
iptables -A INPUT  -s 0/0 -d 0/0 -p udp --source-port      123:123 -m state --state ESTABLISHED     -j ACCEPT
iptables -A OUTPUT -s 0/0 -d 0/0 -p udp --destination-port 123:123 -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow incoming HTTP/S
# inbound(80)
# inbound(443)
# # iptables -A INPUT  -p tcp --dport 80  -m state --state NEW,ESTABLISHED -j ACCEPT
# # iptables -A OUTPUT -p tcp --sport 80  -m state --state ESTABLISHED -j ACCEPT
# # iptables -A INPUT  -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
# # iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# Allow outgoing HTTP(s)
# outbound(80)
# outbound(443)
# # iptables -A INPUT  -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
# # iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
# # iptables -A INPUT  -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
# # iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

rules(${RULEDIR})
