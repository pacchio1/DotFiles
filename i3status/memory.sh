#!/bin/bash

total_mem=$(free -h | awk '/^Mem:/ {print $2}')
used_mem=$(free -h | awk '/^Mem:/ {print $3}')
available_mem=$(free -h | awk '/^Mem:/ {print $7}')

echo "RAM: $used_mem / $total_mem"
