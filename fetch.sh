#!/bin/sh
# File:        fetch.sh
# Author:      Christo Deale 
# Date:        2025-07-07
# Version:     1.0.0
# Description: Retrieves and displays basic system information such as OS details.

os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release || echo "Error: Cannot source /etc/os-release"
    echo "${NAME:-N/A}"
  elif [ -d /system/app ] && [ -d /system/priv-app ]; then
    echo "Android $(getprop ro.build.version.release 2>/dev/null || echo 'N/A')"
  else
    echo "N/A (No /etc/os-release or Android detected)"
  fi
}

kernel() {
  uname -rm 2>/dev/null || echo "N/A (uname failed)"
}

machine() {
  NAME=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "")
  VERSION=$(cat /sys/devices/virtual/dmi/id/product_version 2>/dev/null || echo "")
  MODEL=$(cat /sys/firmware/devicetree/base/model 2>/dev/null || echo "")
  if [ -n "$NAME" ] || [ -n "$VERSION" ] || [ -n "$MODEL" ]; then
    echo "$NAME $VERSION $MODEL" | awk '{$1=$1};1' | tr -s ' ' || echo "N/A (awk/tr failed)"
  else
    echo "N/A (No machine info found)"
  fi
}

up() {
  OUT=$(cut -d ' ' -f 1 /proc/uptime 2>/dev/null)
  if [ -n "$OUT" ]; then
    SECONDS=${OUT%.*}
    DAYS=$((SECONDS / 86400))
    HOURS=$(( (SECONDS % 86400) / 3600 ))
    MINUTES=$(( (SECONDS % 3600) / 60 ))
    echo "${DAYS}d ${HOURS}h ${MINUTES}m"
  else
    echo "N/A (/proc/uptime failed)"
  fi
}

desktop() {
  for var in "XDG_CURRENT_DESKTOP" "DESKTOP_SESSION" "XDG_SESSION_DESKTOP" "CURRENT_DESKTOP" "SESSION_DESKTOP"; do
    DE=$(eval "echo \$$var" 2>/dev/null)
    if [ -n "$DE" ]; then
      echo "$DE"
      return 0
    fi
  done
  echo "N/A (No desktop environment detected)"
}

shell() {
  echo "${SHELL:-N/A (SHELL not set)}"
}

resolution() {
  if command -v xrandr >/dev/null 2>&1; then
    RES=$(xrandr 2>/dev/null | awk '/\*/ {print $1}' | head -n1)
    echo "${RES:-N/A (xrandr no output)}"
  else
    echo "N/A (xrandr not installed)"
  fi
}

pkgs() {
  OUTPUT=""
  if command -v dpkg >/dev/null 2>&1; then
    DPKG=$(dpkg --get-selections 2>/dev/null | wc -l)
    OUTPUT="${OUTPUT}dpkg(${DPKG:-0}) "
  fi
  if command -v flatpak >/dev/null 2>&1; then
    FLATPAK=$(flatpak list 2>/dev/null | wc -l)
    OUTPUT="${OUTPUT}flatpak(${FLATPAK:-0}) "
  fi
  if command -v snap >/dev/null 2>&1; then
    SNAP=$(snap list 2>/dev/null | wc -l)
    OUTPUT="${OUTPUT}snap(${SNAP:-0}) "
  fi
  echo "${OUTPUT:-N/A (No package managers found)}"
}

cpu() {
  CPU=$(awk -F ': ' '/model name/ {print $2}' /proc/cpuinfo 2>/dev/null | head -n1)
  if [ -n "$CPU" ]; then
    echo "$CPU ($(nproc 2>/dev/null || echo 'N/A')/$(nproc --all 2>/dev/null || echo 'N/A'))"
  else
    echo "N/A (/proc/cpuinfo or awk failed)"
  fi
}

gpu() {
  GPU=$(lspci 2>/dev/null | grep -E 'VGA|3D' | cut -d ':' -f3 | head -n1)
  echo "${GPU:-N/A (lspci failed or no GPU found)}"
}

mem() {
  TOTAL=$(grep "MemTotal:" /proc/meminfo 2>/dev/null | awk '{print $2}')
  FREE=$(grep "MemFree:" /proc/meminfo 2>/dev/null | awk '{print $2}')
  if [ -n "$TOTAL" ] && [ -n "$FREE" ]; then
    USED_GIB=$(awk "BEGIN {printf \"%.2f\", ($TOTAL - $FREE) / 1048576}")
    TOTAL_GIB=$(awk "BEGIN {printf \"%.2f\", $TOTAL / 1048576}")
    PERCENT=$(( ((TOTAL - FREE) * 100) / TOTAL ))
    echo "${USED_GIB}GiB of ${TOTAL_GIB}GiB ($PERCENT%)"
  else
    echo "N/A (/proc/meminfo failed)"
  fi
}

disk() {
  df -h / 2>/dev/null | awk 'NR==2 {printf "%.2fGiB of %.2fGiB (%s, /)", $3, $2, $5}' || echo "N/A (df failed)"
}

network() {
  HOSTNAME=${HOSTNAME:-$(hostname 2>/dev/null || echo "host")}
  INTERNAL_IFACE=$(ip -4 addr show 2>/dev/null | grep '192.168.' | awk '{print $NF}' | head -n1)
  INTERNAL_IP=$(ip -4 addr show "$INTERNAL_IFACE" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
  TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
  TAILSCALE_IFACE="tailscale0"
  EXTERNAL_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "N/A")
  
  OUTPUT=""
  if [ -n "$INTERNAL_IP" ]; then
    OUTPUT=$(printf "%s\t%s\t%s\t%s" "$HOSTNAME" "$INTERNAL_IFACE" "$INTERNAL_IP" "$EXTERNAL_IP")
  fi
  if [ -n "$TAILSCALE_IP" ]; then
    OUTPUT="$OUTPUT\n$(printf "%-12s%s\t%s\t%s\t%s" "" "$HOSTNAME" "$TAILSCALE_IFACE" "$TAILSCALE_IP" "$EXTERNAL_IP")"
  fi
  echo "${OUTPUT:-N/A (No network info found)}"
}

log() {
  VAL=$(eval "$2")
  if [ $? -ne 0 ]; then
    VAL="N/A (Error in $2)"
  fi
  if [ "$1" = "Network" ]; then
    # Spesiale formatering vir Network
    if [ "$VAL" != "N/A (No network info found)" ]; then
      printf "\033[94m%-10s\033[0m : \033[97m%s\033[0m\n" "$1" "$VAL"
    else
      printf "\033[94m%-10s\033[0m : \033[97m%s\033[0m\n" "$1" "$VAL"
    fi
  else
    # Normale formatering
    printf "\033[94m%-10s\033[0m : \033[97m%s\033[0m\n" "$1" "${VAL:-N/A}"
  fi
  return 0
}

main() {
  HOSTNAME=${HOSTNAME:-$(hostname 2>/dev/null || echo "host")}
  USERNAME=${USER:-$(id -un 2>/dev/null || echo "user")}
  printf "%-12s %s@%s\n" "" "$USERNAME" "$HOSTNAME"
  
  log "Distro" "os"
  log "Kernel" "kernel"
  log "Machine" "machine"
  log "Uptime" "up"
  echo
  
  log "Desktop" "desktop"
  log "Shell" "shell"
  log "Resolution" "resolution"
  log "Packages" "pkgs"
  echo
  
  log "CPU" "cpu"
  log "GPU" "gpu"
  log "Memory" "mem"
  log "Disk" "disk"
  log "Network" "network"
}

main "$@"
