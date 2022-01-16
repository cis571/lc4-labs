#!/bin/bash

if [ -z "$2" ]
then
    echo "usage: $0 test_module_name verilog_files..."
    exit 1
fi

which iverilog || (echo "ERROR: can't find the 'iverilog' program" && exit 1)
iverilog -Wall -Iinclude -s $1 -o a.out $2 $3 $4 $5 $6 $7
./a.out
