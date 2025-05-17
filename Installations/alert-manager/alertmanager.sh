 #!/bin/bash

cd /opt
rm -rf alertmanager*
wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
tar -xf alertmanager-0.27.0.linux-amd64.tar.gz
mv alertmanager-0.27.0.linux-amd64 alertmanager
cp /home/ec2-user/11.1.create_prometheus_server/Installations/alert-manager/alertmanager.service /etc/systemd/system/alertmanager.service
cp /home/ec2-user/11.1.create_prometheus_server/Installations/alert-manager/alertmanager.yml /opt/alertmanager/alertmanager.yml
systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager
systemctl status alertmanager
