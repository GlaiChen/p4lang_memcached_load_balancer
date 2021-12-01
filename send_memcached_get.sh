if [ $# -ne 2 ]; then
	echo "Usage: $0 <host> <key>"
	exit
fi
echo -e "\x00\x00\x00\x00\x00\x01\x00\x00get $2" | nc -W 1 -D -u "$1" 11111
