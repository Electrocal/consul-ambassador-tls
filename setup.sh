#!/bin/bash

# Defining our functions:
usage(){
    #Helper to use this scripts
    echo "To launch this script: Launch this script./setup.sh"
    echo "The script will ask you for your differents informations and manage it itself"
    echo "the informations asked are required and the crt files need to be put into ./crt_files"
}

create_namespace(){
    echo "Verifying if the namespace is existing if not, creating it"
    namespace_target=$1
    namespace_list=$(kubectl get namespaces | tail -n +2 | awk '{print$1}')
    if [[ "${namespace_target}" =~ $namespace_list ]];
    then
        echo "Namespace ${namespace_target} is already created"
    else
        kubectl create namespace ${namespace_target}
    fi
}

values_replacement(){
    echo "Replacing basics values with you own info into the config files"
    namespace_target=$1 
    datacenter_name=$2
      find config_files -type f -exec sed -i "s,{namespace},${namespace_target},g" {} +
      find config_files -type f -exec sed -i "s,{datacenter},${datacenter_name},g" {} +
}

launch_deployment(){
    echo "Deploy Consul and Ambassador, to be sure of the consistency, we use --wait so it take time"
    echo "Bring you a coffee :)"
    namespace_target=$1
    crt_name=$2
    crt_key=$3
    crt_files="crt_files"
    cfg_files="config_files"    
    # Installing Consul:
    helm repo add hashicorp https://helm.releases.hashicorp.com
    kubectl create secret generic consul-gossip-encryption-key --from-literal=key=$(consul keygen) -n ${namespace_target}
    helm install consul -f ${cfg_files}/consul-values.yaml hashicorp/consul -n ${namespace_target} --wait

    # Deploying Ambassador and connect it to Consul
    kubectl apply -f ${cfg_files}/ambassador-rbac-tls.yaml -n ${namespace_target} --wait
    kubectl apply -f https://www.getambassador.io/yaml/aes-crds.yaml -n ${namespace_target} --wait
    kubectl apply -f ${cfg_files}/consul-resolver.yaml -n ${namespace_target} --wait
    kubectl apply -f ${cfg_files}/ambassador-consul-connector-tls.yaml -n ${namespace_target} --wait
    kubectl create secret tls ambassador-certs --cert=${crt_files}/${crt_name} --key=${crt_files}/${crt_key} -n ${namespace_target} 
    kubectl apply -f ${cfg_files}/ambassador-service-tls.yaml -n ${namespace_target}
}


# Getting variables from user
printf "\nPlease reply to theses questions to automate the deployment \n"
read -p "Enter your namespace target's name: " varnamespace

printf "\n[?] datacenter name for Consul: \n"
read -p "Enter your datacenter target's name: " vardatacenter

printf "\n[?] Value for certificate and key names, don't forget the extension: \n"
printf "[?] example: myfullcert.crt "
read -p "Enter your cert name: " certificate_name
read -p "Enter your cert key: " certificate_key

# Trigger functions 
printf '\n[+] Modifying setup files with new values'
create_namespace ${varnamespace}
values_replacement ${varnamespace} ${vardatacenter}
launch_deployment ${varnamespace} ${certificate_name} ${certificate_key}

echo "################################"
echo "[+] Congratulations, all\'s Done"
echo "################################"