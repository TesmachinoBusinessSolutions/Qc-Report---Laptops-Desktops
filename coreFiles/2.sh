#!/bin/bash

# Check if the script is executed as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Configuration
CRITICAL_PORTS=(80 443 3306 5432 25 110 143 995 993 21 22 23 5900)
SECTIONS="system_info,process_info,network_info,critical_ports_info,software_info"
OUTPUT_FILE=""
COMPRESS=0
SHOW_HELP=0

# Functions

# Function to display help
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -s, --sections SECTION1,SECTION2,...  Specify sections to include"
  echo "                                         Available options:"
  echo "                                         system_info, process_info, network_info,"
  echo "                                         critical_ports_info, software_info"
  echo "  -o, --output FILE                     Specify output file"
  echo "  -c, --compress                        Compress the output file"
  echo "  -h, --help                            Display this help message"
  exit 0
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to print a section header
print_section() {
  echo "======== $1 ========" | tee -a "$OUTPUT_FILE"
}

# Function to print a separator
print_separator() {
  echo "----------------------------------------------" | tee -a "$OUTPUT_FILE"
}

# Function to get the version of an executable
get_executable_version() {
  local exe_path="$1"
  local exe_name
  local version_output

  exe_name=$(basename "$exe_path")

  # Specific cases for known services
  case "$exe_name" in
    sshd)
      if command_exists sshd; then
        version_output=$(sshd -V 2>&1 | head -n1)
      fi
      ;;
    nginx)
      if command_exists nginx; then
        version_output=$(nginx -v 2>&1)
      fi
      ;;
    httpd|apache2)
      if command_exists httpd; then
        version_output=$(httpd -v 2>&1)
      elif command_exists apache2; then
        version_output=$(apache2 -v 2>&1)
      fi
      ;;
    mysqld)
      if command_exists mysqld; then
        version_output=$(mysqld --version 2>&1)
      fi
      ;;
    postgres|postgresql|psql)
      if command_exists psql; then
        version_output=$(psql --version 2>&1)
      fi
      ;;
    *)
      # Try common version options
      version_output=$("$exe_path" --version 2>&1)
      if [ -z "$version_output" ]; then
        version_output=$("$exe_path" -v 2>&1)
      fi
      if [ -z "$version_output" ]; then
        version_output=$("$exe_path" -V 2>&1)
      fi
      ;;
  esac

  if [ -n "$version_output" ]; then
    echo "Process Version:" | tee -a "$OUTPUT_FILE"
    echo "$version_output" | tee -a "$OUTPUT_FILE"
  else
    # Attempt to retrieve via package manager
    if command_exists dpkg; then
      package_name=$(dpkg -S "$exe_path" 2>/dev/null | awk -F: '{print $1}' | head -n1)
      if [ -n "$package_name" ]; then
        version_output=$(dpkg -l | grep "^ii" | grep "$package_name" | awk '{print $2, $3}')
      fi
    elif command_exists rpm; then
      package_name=$(rpm -qf "$exe_path" 2>/dev/null)
      if [ -n "$package_name" ]; then
        version_output=$package_name
      fi
    fi

    if [ -n "$version_output" ]; then
      echo "Package Version:" | tee -a "$OUTPUT_FILE"
      echo "$version_output" | tee -a "$OUTPUT_FILE"
    else
      echo "Unable to determine process version." | tee -a "$OUTPUT_FILE"
    fi
  fi
}

# Function to analyze services on critical ports
analyze_critical_ports() {
  local port_output="$1"

  echo "$port_output" | tee -a "$OUTPUT_FILE"

  echo "Analyzing services on critical ports:" | tee -a "$OUTPUT_FILE"

  for port in "${CRITICAL_PORTS[@]}"; do
    if echo "$port_output" | grep -w ":$port" > /dev/null; then
      echo "Port $port is open." | tee -a "$OUTPUT_FILE"
      process_info=$(lsof -i :"$port" | grep LISTEN | head -n1)
      if [ -n "$process_info" ]; then
        echo "Process using port $port:" | tee -a "$OUTPUT_FILE"
        echo "$process_info" | tee -a "$OUTPUT_FILE"
        pid=$(echo "$process_info" | awk '{print $2}')
        if [ -n "$pid" ]; then
          echo "Detailed information on PID $pid:" | tee -a "$OUTPUT_FILE"
          ps -p "$pid" -o pid,ppid,cmd,%mem,%cpu --forest | tee -a "$OUTPUT_FILE"
          exe_path=$(readlink -f /proc/"$pid"/exe)
          echo "Executable path: $exe_path" | tee -a "$OUTPUT_FILE"
          get_executable_version "$exe_path"
        fi
      else
        echo "Unable to determine the process using port $port." | tee -a "$OUTPUT_FILE"
      fi
    fi
  done
}

# Definition of functions for each section
system_info() {
  print_section "SYSTEM INFORMATION"

  echo "Operating System and Kernel Version:" | tee -a "$OUTPUT_FILE"
  if [ -f /etc/os-release ]; then
    cat /etc/os-release | tee -a "$OUTPUT_FILE"
  else
    echo "/etc/os-release file not found." | tee -a "$OUTPUT_FILE"
  fi
  uname -a | tee -a "$OUTPUT_FILE"
  print_separator

  echo "System Uptime and Load Average:" | tee -a "$OUTPUT_FILE"
  uptime | tee -a "$OUTPUT_FILE"
  print_separator

  echo "CPU Information:" | tee -a "$OUTPUT_FILE"
  if command_exists lscpu; then
    lscpu | tee -a "$OUTPUT_FILE"
  else
    echo "lscpu not available, attempting with /proc/cpuinfo" | tee -a "$OUTPUT_FILE"
    grep -E 'model name|cpu cores|siblings|processor|MHz' /proc/cpuinfo | tee -a "$OUTPUT_FILE"
  fi
  if command_exists sensors; then
    echo "CPU Temperature:" | tee -a "$OUTPUT_FILE"
    sensors | grep -i 'core' | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Memory Information (RAM and Swap):" | tee -a "$OUTPUT_FILE"
  if command_exists free; then
    free -h | tee -a "$OUTPUT_FILE"
  else
    echo "free not available. Attempting with /proc/meminfo:" | tee -a "$OUTPUT_FILE"
    cat /proc/meminfo | grep -E 'MemTotal|MemFree|SwapTotal|SwapFree' | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Disk Usage and Partitions:" | tee -a "$OUTPUT_FILE"
  if command_exists df; then
    df -hT | tee -a "$OUTPUT_FILE"
  else
    echo "df not available." | tee -a "$OUTPUT_FILE"
  fi
  if command_exists lsblk; then
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | tee -a "$OUTPUT_FILE"
  else
    echo "lsblk not available." | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Large Files (>100MB):" | tee -a "$OUTPUT_FILE"
  find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null | tee -a "$OUTPUT_FILE"
  print_separator

  echo "Disk Usage by User:" | tee -a "$OUTPUT_FILE"
  du -sh /home/* 2>/dev/null | tee -a "$OUTPUT_FILE"
  print_separator

  echo "Driver Versions:" | tee -a "$OUTPUT_FILE"
  if command_exists lspci; then
    lspci -k | tee -a "$OUTPUT_FILE"
  else
    echo "lspci not available." | tee -a "$OUTPUT_FILE"
  fi
  if command_exists lsusb; then
    lsusb -v | tee -a "$OUTPUT_FILE"
  else
    echo "lsusb not available." | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "List of Installed Packages:" | tee -a "$OUTPUT_FILE"
  if command_exists dpkg; then
    echo "Using dpkg to list installed packages..." | tee -a "$OUTPUT_FILE"
    dpkg -l | tee -a "$OUTPUT_FILE"
  elif command_exists rpm; then
    if command_exists dnf; then
      echo "Using dnf to list installed packages..." | tee -a "$OUTPUT_FILE"
      dnf list installed | tee -a "$OUTPUT_FILE"
    elif command_exists yum; then
      echo "Using yum to list installed packages..." | tee -a "$OUTPUT_FILE"
      yum list installed | tee -a "$OUTPUT_FILE"
    else
      echo "Using rpm to list installed packages..." | tee -a "$OUTPUT_FILE"
      rpm -qa | tee -a "$OUTPUT_FILE"
    fi
  elif command_exists pacman; then
    echo "Using pacman to list installed packages..." | tee -a "$OUTPUT_FILE"
    pacman -Qe | tee -a "$OUTPUT_FILE"
  elif command_exists apk; then
    echo "Using apk to list installed packages..." | tee -a "$OUTPUT_FILE"
    apk info | tee -a "$OUTPUT_FILE"
  else
    echo "No known package manager found to list installed packages." | tee -a "$OUTPUT_FILE"
  fi
  print_separator
}

process_info() {
  print_section "PROCESSES AND SERVICES"

  echo "Running Processes (Top 10 by CPU and Memory):" | tee -a "$OUTPUT_FILE"
  ps aux --sort=-%cpu,-%mem | head -n 11 | tee -a "$OUTPUT_FILE"
  print_separator

  echo "Running Services:" | tee -a "$OUTPUT_FILE"
  if command_exists systemctl; then
    systemctl list-units --type=service --state=running | tee -a "$OUTPUT_FILE"
  else
    echo "systemctl not available. Services list not provided." | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Loaded Kernel Modules:" | tee -a "$OUTPUT_FILE"
  lsmod | tee -a "$OUTPUT_FILE"
  print_separator
}

network_info() {
  print_section "NETWORK INFORMATION"

  echo "Network Interfaces and IP Addresses:" | tee -a "$OUTPUT_FILE"
  if command_exists ip; then
    ip addr | tee -a "$OUTPUT_FILE"
  else
    echo "'ip' command not available, attempting with ifconfig:" | tee -a "$OUTPUT_FILE"
    ifconfig | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Routing Table:" | tee -a "$OUTPUT_FILE"
  if command_exists ip; then
    ip route | tee -a "$OUTPUT_FILE"
  else
    echo "'ip route' command not available, attempting with route:" | tee -a "$OUTPUT_FILE"
    route -n | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "DNS Configuration (resolv.conf):" | tee -a "$OUTPUT_FILE"
  cat /etc/resolv.conf | tee -a "$OUTPUT_FILE"
  print_separator

  echo "Hosts File (/etc/hosts):" | tee -a "$OUTPUT_FILE"
  cat /etc/hosts | tee -a "$OUTPUT_FILE"
  print_separator

  # Include firewall information here
  echo "Firewall Information:" | tee -a "$OUTPUT_FILE"
  print_separator
  firewall_info
}

firewall_info() {
  # Check if ufw is installed and active
  if command_exists ufw; then
    echo "UFW Firewall detected." | tee -a "$OUTPUT_FILE"
    echo "UFW Status:" | tee -a "$OUTPUT_FILE"
    ufw status verbose | tee -a "$OUTPUT_FILE"
    print_separator
  fi

  # Check if firewalld is installed and active
  if command_exists firewall-cmd; then
    echo "Firewalld Firewall detected." | tee -a "$OUTPUT_FILE"
    echo "Active Zones:" | tee -a "$OUTPUT_FILE"
    firewall-cmd --get-active-zones | tee -a "$OUTPUT_FILE"
    echo "Active Rules:" | tee -a "$OUTPUT_FILE"
    firewall-cmd --list-all --zone=public | tee -a "$OUTPUT_FILE"
    print_separator
  fi

  # Check if iptables is installed
  if command_exists iptables; then
    echo "iptables Firewall detected." | tee -a "$OUTPUT_FILE"
    echo "iptables Rules:" | tee -a "$OUTPUT_FILE"
    iptables -L -n -v | tee -a "$OUTPUT_FILE"
    print_separator
  fi

  # Check if nftables is installed
  if command_exists nft; then
    echo "nftables Firewall detected." | tee -a "$OUTPUT_FILE"
    echo "nftables Rules:" | tee -a "$OUTPUT_FILE"
    nft list ruleset | tee -a "$OUTPUT_FILE"
    print_separator
  fi

  # If no firewall is detected
  if ! command_exists ufw && ! command_exists firewall-cmd && ! command_exists iptables && ! command_exists nft; then
    echo "No firewall detected on the system." | tee -a "$OUTPUT_FILE"
    print_separator
  fi
}

critical_ports_info() {
  print_section "CRITICAL PORTS AND SERVICES"

  echo "Listening Ports and Associated Services:" | tee -a "$OUTPUT_FILE"

  if command_exists ss; then
    port_output=$(ss -tulnp)
  elif command_exists netstat; then
    port_output=$(netstat -tulnp)
  else
    echo "Neither 'ss' nor 'netstat' are available. Unable to analyze ports." | tee -a "$OUTPUT_FILE"
    return
  fi

  analyze_critical_ports "$port_output"
  print_separator
}

software_info() {
  print_section "SOFTWARE"

  echo "Web Services (Apache/Nginx):" | tee -a "$OUTPUT_FILE"
  if command_exists apache2 || command_exists httpd; then
    if command_exists apache2; then
      apache2 -v | tee -a "$OUTPUT_FILE"
    fi
    if command_exists httpd; then
      httpd -v | tee -a "$OUTPUT_FILE"
    fi
  else
    echo "Apache not installed." | tee -a "$OUTPUT_FILE"
  fi
  if command_exists nginx; then
    nginx -v 2>&1 | tee -a "$OUTPUT_FILE"
  else
    echo "Nginx not installed." | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Database Services (MySQL/MariaDB/PostgreSQL):" | tee -a "$OUTPUT_FILE"
  if command_exists mysql; then
    mysql --version | tee -a "$OUTPUT_FILE"
  elif command_exists mariadb; then
    mariadb --version | tee -a "$OUTPUT_FILE"
  else
    echo "MySQL/MariaDB not installed." | tee -a "$OUTPUT_FILE"
  fi
  if command_exists psql; then
    psql --version | tee -a "$OUTPUT_FILE"
  else
    echo "PostgreSQL not installed." | tee -a "$OUTPUT_FILE"
  fi
  print_separator

  echo "Other Software (Docker, Kubernetes, etc.):" | tee -a "$OUTPUT_FILE"
  if command_exists docker; then
    docker --version | tee -a "$OUTPUT_FILE"
  else
    echo "Docker not installed." | tee -a "$OUTPUT_FILE"
  fi
  if command_exists kubectl; then
    kubectl version --short | tee -a "$OUTPUT_FILE"
  else
    echo "Kubernetes not installed." | tee -a "$OUTPUT_FILE"
  fi
  print_separator
}

# Main Execution

# Parse command-line options
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -s|--sections)
      SECTIONS="$2"
      shift; shift
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift; shift
      ;;
    -c|--compress)
      COMPRESS=1
      shift
      ;;
    -h|--help)
      SHOW_HELP=1
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

if [ $SHOW_HELP -eq 1 ]; then
  show_help
fi

# If no output file is specified, use a default name
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="$(pwd)/migration_info_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"
fi

echo "Collecting system information for migration..."
echo "==============================================" | tee "$OUTPUT_FILE"

# Execute specified sections
IFS=',' read -ra SELECTED_SECTIONS <<< "$SECTIONS"

for section in "${SELECTED_SECTIONS[@]}"; do
  case $section in
    system_info)
      system_info
      ;;
    process_info)
      process_info
      ;;
    network_info)
      network_info
      ;;
    critical_ports_info)
      critical_ports_info
      ;;
    software_info)
      software_info
      ;;
    *)
      echo "Unknown section: $section"
      ;;
  esac
done

### Finalization ###
echo "Collection completed." | tee -a "$OUTPUT_FILE"
echo "The information has been saved to: $OUTPUT_FILE" | tee -a "$OUTPUT_FILE"
echo "Please email this file to your contact at SmallCloud. Thank you for your cooperation." | tee -a "$OUTPUT_FILE"
echo "=============================================="
echo "Press any key to exit."
read -n 1 -s

# Compress the output file if requested
if [ $COMPRESS -eq 1 ]; then
  if command_exists gzip; then
    gzip "$OUTPUT_FILE"
    OUTPUT_FILE="$OUTPUT_FILE.gz"
  elif command_exists bzip2; then
    bzip2 "$OUTPUT_FILE"
    OUTPUT_FILE="$OUTPUT_FILE.bz2"
  elif command_exists xz; then
    xz "$OUTPUT_FILE"
    OUTPUT_FILE="$OUTPUT_FILE.xz"
  else
    echo "No compression tools available. Skipping compression."
  fi
fi

exit 0

