#!/bin/sh
set -euC

dnf reposync --disableplugin subscription-manager --nodocs --delete --download-metadata -a x86_64,noarch -p /usr/share/nginx/html/repo/ --repo=ubi-8-baseos-rpms
dnf reposync --disableplugin subscription-manager --nodocs --delete --download-metadata -a x86_64,noarch -p /usr/share/nginx/html/repo/ --repo=ubi-8-appstream-rpms
dnf reposync --disableplugin subscription-manager --nodocs --delete --download-metadata -a x86_64,noarch -p /usr/share/nginx/html/repo/ --repo=ubi-8-codeready-builder-rpms
echo "reposync end"
nginx -g "daemon off;"
