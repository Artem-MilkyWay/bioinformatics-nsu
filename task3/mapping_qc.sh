#!/bin/bash

FLAGSTAT=$1

PERCENT=$(python3 parse_flagstat.py "$FLAGSTAT")

echo "Mapped: $PERCENT %"

RESULT=$(echo "$PERCENT > 90" | bc)

if [ "$RESULT" -eq 1 ]
then
    echo "OK"
else
    echo "not OK"
fi
