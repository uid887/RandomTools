#!/bin/bash
# File:        vodacom_speedtest.sh
# Author:      Christo Deale 
# Date:        2025-07-08
# Version:     1.1.0
# Description: Vodacom Speedcheck Script with live output and auto-install check

# Output file
OUTFILE="$HOME/speedtest_logs/vodacom_speedtest_$(date +%Y-%m-%d_%H-%M-%S).txt"
mkdir -p "$(dirname "$OUTFILE")"

echo "Vodacom Speedtest Log - $(date)" | tee "$OUTFILE"
echo "===================================" | tee -a "$OUTFILE"

# Check for speedtest
if ! command -v speedtest &> /dev/null; then
    echo -e "\n📦 speedtest is not installed. Installing now..." | tee -a "$OUTFILE"
    sudo dnf install -y speedtest-cli | tee -a "$OUTFILE"
else
    echo -e "\n✅ speedtest is installed." | tee -a "$OUTFILE"
fi

# Get public IP
echo -e "\n🔍 Public IP (via Cloudflare 1.1.1.1):" | tee -a "$OUTFILE"
dig +short txt ch whoami.cloudflare @1.0.0.1 | tee -a "$OUTFILE"

# Speedtest result
echo -e "\n🚀 Running Speedtest...\n" | tee -a "$OUTFILE"

# Live output and color while logging
speedtest --accept-license --accept-gdpr | tee >(while IFS= read -r line; do
    if [[ "$line" == *Download:* ]]; then
        echo -e "\e[31m$line\e[0m"
    elif [[ "$line" == *Upload:* ]]; then
        echo -e "\e[31m$line\e[0m"
    else
        echo "$line"
    fi
done) >> "$OUTFILE"

# Traceroute check and fallback
echo -e "\n📡 Traceroute to Vodacom DNS (196.6.103.8) for latency insight:" | tee -a "$OUTFILE"
if command -v traceroute &> /dev/null; then
    traceroute 196.6.103.8 | tee -a "$OUTFILE"
else
    echo "❌ traceroute is not installed. Install with: sudo dnf install -y traceroute" | tee -a "$OUTFILE"
fi

echo -e "\n✅ Done. Output saved to: $OUTFILE"
