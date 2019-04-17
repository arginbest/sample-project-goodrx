#!/bin/bash

mkdir -p /run/systemd/generator &> /dev/null
cat > /run/systemd/generator/goodrx-dev.service<<EOF
[Unit]
Description=GoodRX Sample App
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=no
ExecStart=/usr/bin/docker run -d -p 8080:8080 ${image_name}
[Install]
WantedBy=multi-user.target
EOF

systemctl start goodrx-dev.service
