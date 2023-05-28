#!/bin/bash


# catch signals for graceful container exit
trap 'true' SIGTERM
trap 'true' SIGINT

tail -f /dev/null &
wait $!


