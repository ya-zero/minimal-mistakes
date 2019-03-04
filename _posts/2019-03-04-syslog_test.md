udp syslog send

echo -n "test message" | nc -u -w1 <host> <udp port>

tcp syslog send

echo -n "test message" | nc  -w1 <host> <udp port>

