#!/usr/bin/env bash

docker stop $(docker ps --filter label=project=besu -q)
