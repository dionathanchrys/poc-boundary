#!/bin/zsh
docker network create cluster-kind -d bridge --subnet 192.168.222.0/24

echo "#### SVC CLUSTER ####" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-svc.yaml
docker network disconnect kind svc-cluster-control-plane
docker network connect cluster-kind svc-cluster-control-plane --ip 192.168.222.10
docker restart svc-cluster-control-plane

echo "#### DEV CLUSTER ####" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-dev.yaml
docker network disconnect kind dev-cluster-control-plane
docker network connect cluster-kind dev-cluster-control-plane --ip 192.168.222.20
docker restart dev-cluster-control-plane

echo "#### PRD CLUSTER ####" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-prd.yaml
docker network disconnect kind prd-cluster-control-plane
docker network connect cluster-kind prd-cluster-control-plane --ip 192.168.222.30
docker restart prd-cluster-control-plane
