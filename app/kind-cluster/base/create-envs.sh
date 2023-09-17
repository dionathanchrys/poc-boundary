#!/bin/zsh
echo "#### SVC CLUSTER ####" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-svc.yaml
docker network create svc-env -d bridge --subnet 192.168.222.0/30
docker network disconnect kind svc-cluster-control-plane
docker network connect svc-env svc-cluster-control-plane
docker restart svc-cluster-control-plane

echo "#### DEV CLUSTER ####" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-dev.yaml
docker network create dev-env -d bridge --subnet 192.168.222.4/30
docker network disconnect kind dev-cluster-control-plane
docker network connect dev-env dev-cluster-control-plane
docker restart dev-cluster-control-plane

echo "#### PRD CLUSTER ####" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-prd.yaml
docker network create prd-env -d bridge --subnet 192.168.222.8/30
docker network disconnect kind prd-cluster-control-plane
docker network connect prd-env prd-cluster-control-plane
docker restart prd-cluster-control-plane
