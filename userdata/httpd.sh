#!/bin/bash
# Update the package repository and install Apache HTTPD
yum update -y
yum install -y httpd

# Start and enable Apache HTTPD
systemctl start httpd
systemctl enable httpd

# Install AWS CLI
yum install -y aws-cli

# Create a CloudWatch agent configuration file
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "apache-logs",
                        "log_stream_name": "{instance_id}/access_log",
                        "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "apache-logs",
                        "log_stream_name": "{instance_id}/error_log",
                        "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
                    }
                ]
            }
        }
    }
}
EOF

# Download and install the CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Start the CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s