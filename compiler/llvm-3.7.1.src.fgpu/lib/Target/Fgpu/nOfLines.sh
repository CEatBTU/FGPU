#!/bin/sh
find . -type f -exec cat {} + | wc -l
