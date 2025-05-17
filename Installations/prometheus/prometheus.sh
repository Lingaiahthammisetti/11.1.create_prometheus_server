#!/bin/bash
cd /opt
rm -rf prometheus*
wget https://github.com/prometheus/prometheus/releases/download/v2.54.0-rc.0/prometheus-2.54.0-rc.0.linux-amd64.tar.gz
tar -xf prometheus-2.54.0-rc.0.linux-amd64.tar.gz
mv prometheus-2.54.0-rc.0.linux-amd64 prometheus
cp -r /root/11.1.create_prometheus_server/Installations/alert-manager/alert-rules /opt/prometheus/
cp /root/11.1.create_prometheus_server/Installations/prometheus/prometheus.yml prometheus/prometheus.yml
cp /root/11.1.create_prometheus_server/Installations/prometheus//prometheus.service /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl status prometheus
