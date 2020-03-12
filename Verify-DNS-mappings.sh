#!/bin/bash
#
# Verify-DNS-mappings
# More info at:
#	https://www.madboa.com/geek/dig/#verifying-dns-mappings
#
# test DNS forward- and reverse-mapping
#

# edit this variable to reflect local class C subnet(s)
NETS="192.168.1 192.168.2"

# Test name to address to name validity
echo
echo -e "\tname -> address -> name"
echo '----------------------------------'
while read H; do
	ADDR=$(dig $H +short)
	if test -n "$ADDR"; then
		HOST=$(dig -x $ADDR +short)
		if test "$H" = "$HOST"; then
			echo -e "ok\t$H -> $ADDR -> $HOST"
		elif test -n "$HOST"; then
			echo -e "fail\t$H -> $ADDR -> $HOST"
		else
			echo -e "fail\t$H -> $ADDR -> [unassigned]"
		fi
	else
		echo -e "fail\t$H -> [unassigned]"
	fi
done < named-hosts

# Test address to name to address validity
echo
echo -e "\taddress -> name -> address"
echo '-------------------------------------'
for NET in $NETS; do
	for n in $(seq 1 254); do
		A=${NET}.${n}
		HOST=$(dig -x $A +short)
		if test -n "$HOST"; then
			ADDR=$(dig $HOST +short)
			if test "$A" = "$ADDR"; then
				echo -e "ok\t$A -> $HOST -> $ADDR"
				elif test -n "$ADDR"; then
				echo -e "fail\t$A -> $HOST -> $ADDR"
			else
				echo -e "fail\t$A -> $HOST -> [unassigned]"
			fi
		fi
	done
done
