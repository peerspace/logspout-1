#!/bin/bash

service=logspout

if [[ -z "${1}" ]] 
then
    docker build -t peerspace/${service} .
else
    docker build -t peerspace/${service}:${1} .
fi

