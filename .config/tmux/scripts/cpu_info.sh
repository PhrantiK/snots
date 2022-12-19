#!/usr/bin/env bash
# ┌────────────────────────────────────────┐
# │┏┓┓┏┏┓┳ ┓┓ ┃  ┏━┓┳━┓┳ ┓  ┓━┓┏┓┓┳━┓┏┓┓┓━┓│
# │ ┃ ┃┃┃┃ ┃┏╋┛  ┃  ┃━┛┃ ┃  ┗━┓ ┃ ┃━┫ ┃ ┗━┓│
# │ ┇ ┛ ┇┇━┛┇ ┗  ┗━┛┇  ┇━┛  ━━┛ ┇ ┛ ┇ ┇ ━━┛│
# └────────────────────────────────────────┘

# normalize the percentage string to always have a length of 5
normalize_percent_len() {
  # the max length that the percent can reach, which happens for a two digit number with a decimal house: "99.9%"
  max_len=5
  percent_len=${#1}
  let diff_len=$max_len-$percent_len
  # if the diff_len is even, left will have 1 more space than right
  let left_spaces=($diff_len+1)/2
  let right_spaces=($diff_len)/2
  printf "%${left_spaces}s%s%${right_spaces}s\n" "" $1 ""
}

get_percent()
{
  case $(uname -s) in
    Linux)
      percent=$(LC_NUMERIC=en_US.UTF-8 top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
      normalize_percent_len $percent
      ;;

    Darwin)
      cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
      cpucores=$(sysctl -n hw.logicalcpu)
      cpuusage=$(( cpuvalue / cpucores ))
      percent="$cpuusage%"
      normalize_percent_len $percent
      ;;
  esac
}

main()
{
  # storing the refresh rate in the variable RATE, default is 5
  cpu_percent=$(get_percent)
  echo "$cpu_percent"
  sleep 2
}

# run main driver
main
