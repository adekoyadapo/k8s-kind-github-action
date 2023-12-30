#!/bin/bash

KIND_CLUSTER_NAME="${1:-hello-world}"
hostport="${2:-30950}"
appname="${3:-hello-world}"
imagetag="${4:-v1}"
cluster_file=".created_cluster"

check_package() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "\033[31mERROR:\033[0m $1 is not installed. Please install it before continuing."
        exit 1
    fi
}

cleanup_cluster() {
    if [[ -f "$cluster_file" ]]; then
        cluster_name=$(cat "$cluster_file")
        echo -e "\033[32mDeleting Cluster $cluster_name... \033[0m\n"
        if kind delete cluster --name "$cluster_name"; then
            echo -e "\033[32mCluster $cluster_name deleted successfully.\033[0m\n"
            rm "$cluster_file"
            exit 0
        else
            echo -e "\033[31mError deleting cluster $cluster_name.\033[0m\n"
            exit 1
        fi
    else
        echo -e "\033[31mNo cluster found for cleanup.\033[0m\n"
        exit 1
    fi
}

if [[ $1 == "cleanup" ]]; then
  cleanup_cluster "$1"
else 
   printf "\033c"
   echo "$KIND_CLUSTER_NAME" > "$cluster_file"
   echo -e "\033[32mUsage: ./deploy.sh <clustername> <hostport> <app-name> <image-tag>\n"
   echo -e "Current values clustername=$KIND_CLUSTER_NAME; hostport=$hostport; app=$appname; imagetag=$imagetag\n"
   
   echo -e "\033[32mTo Clean-up run ./deploy.sh cleanup\n"
   
   echo -e "\033[32mChecking Prereqs...\033[0m\n"
   
   check_package "docker"
   check_package "kind"
   check_package "envsubst"
   check_package "kubectl"
   
   echo -e "\033[32mAll required packages are installed.\033[0m\n"
   
   if [[ $(kind get clusters) != *$KIND_CLUSTER_NAME* ]] ;
   then
       echo
       echo -e "\033[32mCreating Cluster with the name $KIND_CLUSTER_NAME... \033[0m\n"
       for i in KIND_CLUSTER_NAME hostport appname imagetag; do export "$i=${!i}"; done
       set -e 
       tempfile=$(mktemp)
       cat cluster-config.yaml | envsubst > "$tempfile"
       kind create cluster --config  "$tempfile"
       sleep 10
       kubectl wait --for=condition=Ready pods --all -A > /dev/null
       echo -e "\033[32m$KIND_CLUSTER_NAME cluster is ready... \033[0m\n"
       rm "$tempfile"
   
   else
       echo
       echo -e "\033[31mCluster already exists, delete it with kind delete clusters $1 and try recreating again...\n"
   fi
   echo
   echo -e "\033[32mBuilding Docker image \033[0m\n"
   
   docker build -t $appname:$imagetag .
   echo
   echo -e "\033[32mUploading $appname:$imagetag image to cluster \033[0m\n"
   echo
   kind load docker-image $appname:$imagetag --name $KIND_CLUSTER_NAME
   echo
   echo -e "\033[32mDeploying $appname to $KIND_CLUSTER_NAME \033[0m\n"
   
   for i in KIND_CLUSTER_NAME hostport appname imagetag; do export "$i=${!i}"; done
   envsubst < app-config.yml | kubectl apply -f -
   echo
   echo -e "Deployment Completed... Access the application at http://localhost:$hostport\n"
fi