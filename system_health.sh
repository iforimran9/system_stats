#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

separator="================================================================================"

print_header() {
    echo -e "\n${CYAN}${BOLD}$1${RESET}"
    echo "$separator"
}

# ------------------------ CPU Usage ------------------------
top_output=$(top -bn1)
cpu_idle=$(echo "$top_output" | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/')
cpu_usage=$(awk -v idle="$cpu_idle" 'BEGIN { printf("%.1f", 100 - idle) }')

print_header "🖥️  CPU Usage"
echo -e "Usage         : ${GREEN}${cpu_usage}%${RESET}"

# ------------------------ Memory Usage ------------------------
read total_memory available_memory <<< $(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {print t, a}' /proc/meminfo)
used_memory=$((total_memory - available_memory))

used_memory_percent=$(awk -v u=$used_memory -v t=$total_memory 'BEGIN { printf("%.1f", (u / t) * 100) }')
free_memory_percent=$(awk -v a=$available_memory -v t=$total_memory 'BEGIN { printf("%.1f", (a / t) * 100) }')

total_memory_mb=$(awk -v t=$total_memory 'BEGIN { printf("%.1f", t/1024) }')
used_memory_mb=$(awk -v u=$used_memory 'BEGIN { printf("%.1f", u/1024) }')
available_memory_mb=$(awk -v a=$available_memory 'BEGIN { printf("%.1f", a/1024) }')

print_header "🧠 Memory Usage"
printf "Total Memory    : ${YELLOW}%-10s MB${RESET}\n" "$total_memory_mb"
printf "Used Memory     : ${YELLOW}%-10s MB${RESET} (%s%%)\n" "$used_memory_mb" "$used_memory_percent"
printf "Free/Available  : ${YELLOW}%-10s MB${RESET} (%s%%)\n" "$available_memory_mb" "$free_memory_percent"

# ------------------------ Disk Usage ------------------------
df_output=$(df -h /)
read size_disk used_disk available_disk <<< $(echo "$df_output" | awk 'NR==2 {print $2, $3, $4}')

df_output_raw=$(df /)
read size_disk_kb used_disk_kb available_disk_kb <<< $(echo "$df_output_raw" | awk 'NR==2 {print $2, $3, $4}')

used_disk_percent=$(echo "scale=2; $used_disk_kb * 100 / $size_disk_kb" | bc)
available_disk_percent=$(echo "scale=2; $available_disk_kb * 100 / $size_disk_kb" | bc)

print_header "💾 Disk Usage"
printf "Disk Size       : ${YELLOW}%-10s${RESET}\n" "$size_disk"
printf "Used Space      : ${YELLOW}%-10s${RESET} (%s%%)\n" "$used_disk" "$used_disk_percent"
printf "Available Space : ${YELLOW}%-10s${RESET} (%s%%)\n" "$available_disk" "$available_disk_percent"

# ------------------------ Top Processes ------------------------
print_header "🔥 Top 5 Processes by CPU"
ps aux --sort=-%cpu | awk 'NR==1 || NR<=6 { printf "%-10s %-6s %-5s %-5s %s\n", $1, $2, $3, $4, $11 }'

print_header "🧠 Top 5 Processes by Memory"
ps aux --sort=-%mem | awk 'NR==1 || NR<=6 { printf "%-10s %-6s %-5s %-5s %s\n", $1, $2, $3, $4, $11 }'

# ------------------------ Network Usage ------------------------
iface=$(ip route | awk '/default/ {print $5}' | head -n1)
print_header "🌐 Network Usage ($iface)"
if [[ -d "/sys/class/net/$iface" ]]; then
    rx=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$iface/statistics/tx_bytes)
    printf "Received : ${YELLOW}%.2f MB${RESET}\n" "$(echo "$rx / 1024 / 1024" | bc -l)"
    printf "Sent     : ${YELLOW}%.2f MB${RESET}\n" "$(echo "$tx / 1024 / 1024" | bc -l)"
else
    echo "Interface $iface not found."
fi

# ------------------------ Failed Systemd Services ------------------------
print_header "❌ Failed System Services"
failed_services=$(systemctl --failed --no-pager --no-legend)
if [[ -z "$failed_services" ]]; then
    echo "None"
else
    echo "$failed_services" | awk '{print $1}'
fi

# ------------------------ Uptime and Load ------------------------
print_header "⏱️ System Uptime & Load"
uptime -p
uptime | awk -F'load average:' '{ print "Load Average   :", $2 }'

# ------------------------ Last Login ------------------------
print_header "👤 Last Login"
last -n 1 | head -n 1
