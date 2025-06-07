#Prometheus installation process
cd /opt
rm -rf prometheus*
wget https://github.com/prometheus/prometheus/releases/download/v3.4.0/prometheus-3.4.0.linux-amd64.tar.gz
tar -xf prometheus-3.4.0.linux-amd64.tar.gz
mv prometheus-3.4.0.linux-amd64 prometheus



echo "
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - "alert-rules/*.yaml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
        labels:
          name: prometheus
  ##Static discovery of nodes in prometheus        
  # - job_name: "nodes"
  #   static_configs:
  #     - targets: ["node-1.lingaiah.online:9100"]
  #       labels:
  #         name: node-1
  #     - targets: ["node-2.lingaiah.online:9100"]
  #       labels:
  #         name: node-2

  ##Dynamic discovery of nodes in prometheus 
  # - job_name: 'ec2-nodes'
  #   ec2_sd_configs:
  #     - region: us-east-1
  #       port: 9100
  #   relabel_configs:
  #     - source_labels: [__meta_ec2_instance_id]
  #       target_label: instance_id
  #     - source_labels: [__meta_ec2_private_ip]
  #       target_label: private_ip
  #     - source_labels: [__meta_ec2_tag_Name]
  #       target_label: instance_name
  #       regex: node-.*
  #       action: keep

  ##Dynamic discovery of nodes in prometheus 
  - job_name: 'ec2-nodes'
    ec2_sd_configs:
      - region: us-east-1
        port: 9100
        filters:                 # optional EC2 filters
          - name: "tag:Environment"
            values: ["dev"]
    
    relabel_configs:
      # Keep only instances whose Name tag matches "node-*"
      - source_labels: [__meta_ec2_tag_Name]
        regex: node-.*
        action: keep

      # Set label "name" from EC2 tag Name
      - source_labels: [__meta_ec2_tag_Name]
        target_label: name

      # Set the target label for instance ID
      - source_labels: [__meta_ec2_instance_id]
        target_label: instance_id

      # Set the target label for private IP
      - source_labels: [__meta_ec2_private_ip]
        target_label: private_ip
         
  - job_name: "ec2_sd"
    ec2_sd_configs:
    - region: us-east-1
      port: 9100
      filters:
        - name: tag:Monitoring
          values:
            - true
    relabel_configs:
      - source_labels: [__meta_ec2_instance_id]
        target_label: instance_id
      - source_labels: [__meta_ec2_private_ip]
        target_label: private_ip
      - source_labels: [__meta_ec2_tag_Name]
        target_label: name
    
"> prometheus/prometheus.yml

echo "
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target
 "> /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl status prometheus



#Grafana installation process
cd /opt
curl -o gpg.key https://rpm.grafana.com/gpg.key

echo "
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
" > /etc/yum.repos.d/grafana.repo

dnf install grafana -y
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server
systemctl status grafana-server



#Alertmanager installation process
cd /opt
rm -rf alertmanager*
wget https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz
tar -xf alertmanager-0.28.1.linux-amd64.tar.gz
mv alertmanager-0.28.1.linux-amd64 alertmanager

echo "
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/alertmanager/
ExecStart=/opt/alertmanager/alertmanager --config.file=/opt/alertmanager/alertmanager.yml

[Install]
WantedBy=multi-user.target
 " > /etc/systemd/system/alertmanager.service

echo "
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: 'ses'
receivers:
  - name: 'ses'
    email_configs:
      - smarthost: email-smtp.us-east-1.amazonaws.com:587
        auth_username: AKIAXBZV5YIIZ352UCOE
        auth_password: BJvAK4LdIomMY+7sxuGqmEnn4Zz4bRArQKxdGVBgAvCs
        from: rao.lingaiah@gmail.com
        to: lingayya.tamichetti786@gmail.com
        headers:
          subject: Prometheus Mail Alert
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
 " > /opt/alertmanager/alertmanager.yml

echo "
groups:
- name: InstanceDown
  rules:
  - alert: InstanceDownAlert
    expr: up < 1
    for: 1m
    labels:
      severity: 'critical'
    annotations:
      summary: Instance is Down
" >/opt/prometheus/alert-rules/instance-down.yaml


systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager
systemctl status alertmanager


