#!/bin/sh
docker build -t redhat-ubi8-repository .
exec docker run --rm --net=host -v ./rpms:/usr/share/nginx/html/repo redhat-ubi8-repository
