#!/bin/sh

INITIAL_PERMGEN_SIZE="64m"
MAX_PERMGEN_SIZE="128m"

export ANT_OPTS="-XX:PermSize=${INITIAL_PERMGEN_SIZE} -XX:MaxPermSize=${MAX_PERMGEN_SIZE}"
ant