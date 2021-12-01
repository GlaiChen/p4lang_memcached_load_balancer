echo "Starting memcached..."
memcached -p 11111 -U 11111 -u p4 -l 10.0.3.3 -d
sleep 1
echo "Adding data..."
{ echo "set key01 0 0 6"; echo "value1"; } | telnet 10.0.3.3 11111 >& /dev/null
{ echo "set key03 0 0 6"; echo "value3"; } | telnet 10.0.3.3 11111 >& /dev/null
{ echo "set key05 0 0 6"; echo "value5"; } | telnet 10.0.3.3 11111 >& /dev/null
{ echo "set key07 0 0 6"; echo "value7"; } | telnet 10.0.3.3 11111 >& /dev/null
{ echo "set key09 0 0 6"; echo "value9"; } | telnet 10.0.3.3 11111 >& /dev/null
echo "Done."
