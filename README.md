System Health Dashboard Script
This is a lightweight Bash script that provides a comprehensive snapshot of a Linux system's resource usage and health. It is ideal for administrators and developers who want quick, readable summaries of system metrics.

Features
This script reports:

CPU Usage — Percentage of CPU currently in use.

Memory Usage — Total, used, and available memory with percentage statistics.

Disk Usage — Reports on root (/) partition usage, including size and available space.

Top 5 Processes by CPU and Memory — Lists the most resource-intensive processes.

Network Usage — Displays sent/received data over the default network interface.

Failed System Services — Detects and displays any systemd services that have failed.

System Uptime and Load Average — Shows how long the system has been running and the load average.

Last Login — Displays information about the last user login.

Requirements
Linux-based system with Bash

Commands: top, awk, sed, df, ps, ip, bc, tput, systemctl, last

Root access may be required for full process visibility and service status

Usage
Save the script:
nano system_health.sh
Paste the script contents and save the file.

Make it executable:
chmod +x system_health.sh

Run the script:
./system_health.sh
Example Output

The script produces color-coded terminal output with sectioned headers for easy readability. Each metric is grouped and clearly labeled.

Automation with Cron
You can run this script periodically using cron and log the results for later review.

Open crontab:
crontab -e
Add an entry (example: run every hour):
0 * * * * /path/to/system_health.sh >> /var/log/system_health.log 2>&1

You can configure log rotation using logrotate if needed.

Integration with Jenkins
To use the script in Jenkins:

Add it to your project repository or server.
Create a Jenkins job (freestyle or pipeline).
In a shell build step, run:
bash /path/to/system_health.sh > system_health_report.txt

Post-build, use the Jenkins Email Extension plugin to send the report.

Notifications via Email or Slack
Email (via cron or Jenkins):
Append this to the script or cron entry (requires mailutils or similar):

/path/to/system_health.sh | mail -s "System Health Report - $(hostname)" you@example.com

Slack:
Create a Slack Webhook URL.

Use curl to send output (example using jq):

output=$(bash /path/to/system_health.sh)
payload=$(jq -n --arg text "$output" '{text: $text}')
curl -X POST -H 'Content-type: application/json' --data "$payload" https://hooks.slack.com/services/your/webhook/url


Future Enhancements
Support for multiple disk partitions

Option to export output as JSON or CSV

Slack formatting with blocks

Auto-threshold alerts (e.g., if CPU > 90%)

License
This script is open-source and provided under the MIT License.
