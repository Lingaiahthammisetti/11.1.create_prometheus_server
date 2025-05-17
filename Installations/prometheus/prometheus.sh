#!/bin/bash
set -e  # Exit on any error
exec > /var/log/user-data.log 2>&1  # Log output for debugging

# Go to /opt
cd /opt

# Clean up any old prometheus installations
rm -rf prometheus*

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.54.0-rc.0/prometheus-2.54.0-rc.0.linux-amd64.tar.gz

# Extract
tar -xf prometheus-2.54.0-rc.0.linux-amd64.tar.gz

# Rename
mv prometheus-2.54.0-rc.0.linux-amd64 prometheus

# Copy alert rules and config
cp -r /root/11.1.create_prometheus_server/Installations/alert-manager/alert-rules /opt/prometheus/
cp /root/11.1.create_prometheus_server/Installations/prometheus/prometheus.yml /opt/prometheus/prometheus.yml
cp /root/11.1.create_prometheus_server/Installations/prometheus/prometheus.service /etc/systemd/system/prometheus.service

# Start Prometheus
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus







# #!/bin/bash
# cd /opt
# rm -rf prometheus*
# wget https://github.com/prometheus/prometheus/releases/download/v2.54.0-rc.0/prometheus-2.54.0-rc.0.linux-amd64.tar.gz
# tar -xf prometheus-2.54.0-rc.0.linux-amd64.tar.gz
# mv prometheus-2.54.0-rc.0.linux-amd64 prometheus
# cp -r /root/11.1.create_prometheus_server/Installations/alert-manager/alert-rules /opt/prometheus/
# cp /root/11.1.create_prometheus_server/Installations/prometheus/prometheus.yml prometheus/prometheus.yml
# cp /root/11.1.create_prometheus_server/Installations/prometheus//prometheus.service /etc/systemd/system/prometheus.service

# systemctl daemon-reload
# systemctl enable prometheus
# systemctl start prometheus
# systemctl status prometheus
