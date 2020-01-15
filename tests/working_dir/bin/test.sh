#!/bin/bash

echo "I'm in $(pwd | rev | cut -d/ -f 1-2 | rev)"
