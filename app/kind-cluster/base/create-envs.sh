#!/bin/zsh
echo " " && echo "➡➡➡➡ CREATE DOCKER NETWORK ⬅⬅⬅⬅" && echo " "
docker network create cluster-kind -d bridge --subnet 192.168.222.0/24

echo " " && echo "➡➡➡➡ CREATING SVC CLUSTER ⬅⬅⬅⬅" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-svc.yaml
docker network disconnect kind svc-cluster-control-plane
docker network connect cluster-kind svc-cluster-control-plane --ip 192.168.222.10
echo " " && echo "➡➡➡➡ RESTARTING SVC CLUSTER ⬅⬅⬅⬅" && echo " "
docker restart svc-cluster-control-plane

echo " " && echo "➡➡➡➡ CREATING DEV CLUSTER ⬅⬅⬅⬅" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-dev.yaml
docker network disconnect kind dev-cluster-control-plane
docker network connect cluster-kind dev-cluster-control-plane --ip 192.168.222.20
echo " " && echo "➡➡➡➡ RESTARTING DEV CLUSTER ⬅⬅⬅⬅" && echo " "
docker restart dev-cluster-control-plane

echo " " && echo "➡➡➡➡ CREATING PRD CLUSTER ⬅⬅⬅⬅" && echo " "
kind create cluster --config app/kind-cluster/base/cluster-prd.yaml
docker network disconnect kind prd-cluster-control-plane
docker network connect cluster-kind prd-cluster-control-plane --ip 192.168.222.30
echo " " && echo "➡➡➡➡ RESTARTING PRD CLUSTER ⬅⬅⬅⬅" && echo " "
docker restart prd-cluster-control-plane

############################################################################

echo " " && echo "➡➡➡➡ CREATING SVC NAMESPACES ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/kind-cluster/overlay/service --context kind-svc-cluster

echo " " && echo "➡➡➡➡ CREATING DEV NAMESPACES ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/kind-cluster/overlay/dev --context kind-dev-cluster

echo " " && echo "➡➡➡➡ CREATING PRD NAMESPACES ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/kind-cluster/overlay/prd --context kind-prd-cluster

############################################################################

echo " " && echo "➡➡➡➡ DEPLOYING BOUNDARY DATABASE ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/boundary-postgres/overlay/service --context kind-svc-cluster
echo " " && echo "➡➡➡➡ WAITING BOUNDARY DATABASE ⬅⬅⬅⬅" && echo " "
kubectl wait -f app/boundary-postgres/base/deployment.yaml --for condition=Available --timeout 60s --context kind-svc-cluster

echo " " && echo "➡➡➡➡ DEPLOYING DATABASE MIGRATOR ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/boundary-migrator/overlay/service --context kind-svc-cluster
echo " " && echo "➡➡➡➡ WAITING DATABASE MIGRATOR ⬅⬅⬅⬅" && echo " "
kubectl wait -f app/boundary-migrator/base/job.yaml --for condition=Complete --timeout 60s --context kind-svc-cluster

echo " " && echo "➡➡➡➡ DEPLOYING BOUNDARY CONTROLLER ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/boundary-controller/overlay/service --context kind-svc-cluster
echo " " && echo "➡➡➡➡ WAITING BOUNDARY CONTROLLER ⬅⬅⬅⬅" && echo " "
kubectl wait -f app/boundary-controller/base/deployment.yaml --for condition=Available --timeout 60s --context kind-svc-cluster

echo " " && echo "➡➡➡➡ DEPLOYING BOUNDARY WORKER - DEV ENV ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/boundary-worker/overlay/dev --context kind-dev-cluster
echo " " && echo "➡➡➡➡ DEPLOYING DEV DATABASE ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/foo-postgres/overlay/dev --context kind-dev-cluster

echo " " && echo "➡➡➡➡ DEPLOYING BOUNDARY WORKER - DEV PRD ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/boundary-worker/overlay/prd --context kind-prd-cluster
echo " " && echo "➡➡➡➡ DEPLOYING PRD DATABASE ⬅⬅⬅⬅" && echo " "
kubectl apply -k app/foo-postgres/overlay/prd --context kind-prd-cluster

#docker rm -f svc-cluster-control-plane dev-cluster-control-plane prd-cluster-control-plane && docker network rm cluster-kind