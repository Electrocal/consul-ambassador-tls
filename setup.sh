#!/bin/bash

echo "[?] Value for namespace: "
read varnamespace

kubectl create ns $varnamespace

echo "[?] Value for datacenter: "
read vardatacenter

echo '[+] Modifying setup files with new values'

mod_files="ambassador-consul-connector-tls.yaml
           ambassador-rbac-tls.yaml
           consul-resolver.yaml
           consul-values.yaml
           README.md"

for file in $mod_files
    do
        sed -i '' -e 's/{namespace}/'$varnamespace'/g' $file
        sed -i '' -e 's/{datacenter}/'$vardatacenter'/g' $file
    done

echo '[+] Done'
