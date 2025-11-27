#!/bin/bash

# Small script for quick building and running

echo "Make and test"
make

if [ $? = 0 ]; then
    echo "Build OK, running ..."
    emulicious ./tmp_build.gb
fi

