#!/bin/bash
if [[ -z "$1" ]]; then LUA_CMD="lua"; else LUA_CMD="$1"; fi
MAX_DAY=$(ls | grep 'day_[0-9]\+.lua' | grep -o '[0-9]\+' | sort -nr | head -1)
MAX_DAY=$(($MAX_DAY))
OUTPUT=$(for i in $(seq 1 $MAX_DAY); do
    echo "########## Day $i ##########"
    $LUA_CMD day_$i.lua < input_$i.txt
    echo
done | tee /dev/fd/2)
TIME=$(echo "$OUTPUT" | grep "Time taken:" | awk '{sum+=$3}END{print sum}')
echo "Total time: $TIME"
