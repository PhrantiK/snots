#!/usr/bin/env bash
# ┌────────────────────────────────────────┐
# │┏┓┓┏┏┓┳ ┓┓ ┃  ┳━┓┳━┓┏┏┓  ┓━┓┏┓┓┳━┓┏┓┓┓━┓│
# │ ┃ ┃┃┃┃ ┃┏╋┛  ┃┳┛┃━┫┃┃┃  ┗━┓ ┃ ┃━┫ ┃ ┗━┓│
# │ ┇ ┛ ┇┇━┛┇ ┗  ┇┗┛┛ ┇┛ ┇  ━━┛ ┇ ┛ ┇ ┇ ━━┛│
# └────────────────────────────────────────┘

get_percent()
{
  case $(uname -s) in
    Linux)
      # percent=$(free -m | awk 'NR==2{printf "%.1f%%\n", $3*100/$2}')
      total_mem_gb=$(free -g | awk '/^Mem/ {print $2}')
      used_mem=$(free -g | awk '/^Mem/ {print $3}')
      total_mem=$(free -h | awk '/^Mem/ {print $2}')
      if (( $total_mem_gb == 0)); then
        memory_usage=$(free -m | awk '/^Mem/ {print $3}')
        total_mem_mb=$(free -m | awk '/^Mem/ {print $2}')
        echo $memory_usage\M\B/$total_mem_mb\M\B
      elif (( $used_mem == 0 )); then
        memory_usage=$(free -m | awk '/^Mem/ {print $3}')
        echo $memory_usage\M\B/$total_mem_gb\G\B
      else
        memory_usage=$(free -g | awk '/^Mem/ {print $3}')
        echo $memory_usage\G\B/$total_mem_gb\G\B
      fi
      ;;

    Darwin)
      # percent=$(ps -A -o %mem | awk '{mem += $1} END {print mem}')
      # Get used memory blocks with vm_stat, multiply by 4096 to get size in bytes, then convert to MiB
      used_mem=$(vm_stat | grep ' active\|wired ' | sed 's/[^0-9]//g' | paste -sd ' ' - | awk '{printf "%d\n", ($1+$2) * 4096 / 1048576}')
      total_mem=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2 $3}')
      if (( $used_mem < 1024 )); then
        echo $used_mem\M\B/$total_mem
      else
        memory=$(($used_mem/1024))
        echo $memory\G\B/$total_mem
      fi
      ;;
  esac
}

main()
{
  ram_percent=$(get_percent)
  echo "$ram_percent"
  sleep 5
}

main
