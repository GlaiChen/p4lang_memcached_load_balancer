echo "Starting memcached..."
memcached -p 11111 -U 11111 -u p4 -l 10.0.2.2 -d
sleep 1
echo "Adding data..."
{ echo "set key00 0 0 6"; echo "value0"; } | telnet 10.0.2.2 11111 >& /dev/null
{ echo "set key02 0 0 6"; echo "value2"; } | telnet 10.0.2.2 11111 >& /dev/null
{ echo "set key04 0 0 6"; echo "value4"; } | telnet 10.0.2.2 11111 >& /dev/null
{ echo "set key06 0 0 6"; echo "value6"; } | telnet 10.0.2.2 11111 >& /dev/null
{ echo "set key08 0 0 6"; echo "value8"; } | telnet 10.0.2.2 11111 >& /dev/null
{ echo "set other 0 0 6"; echo "hello!"; } | telnet 10.0.2.2 11111 >& /dev/null
echo "Done."
