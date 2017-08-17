#!/bin/bash

service=logspout

if [[ -z "${1}" ]] 
then
    docker push peerspace/${service}
else
    docker push peerspace/${service}:${1}
fi
