docker build -t elpachanga1/multi-client:latest -t elpachanga1/multi-client:$SHA -f ./app/client/Dockerfile ./app/client
docker build -t elpachanga1/multi-server:latest -t elpachanga1/multi-server:$SHA -f ./app/server/Dockerfile ./app/server
docker build -t elpachanga1/multi-worker:latest -t elpachanga1/multi-worker:$SHA -f ./app/worker/Dockerfile ./app/worker
docker push elpachanga1/multi-client:latest
docker push elpachanga1/multi-server:latest
docker push elpachanga1/multi-worker:latest

docker push elpachanga1/multi-client:$SHA
docker push elpachanga1/multi-server:$SHA
docker push elpachanga1/multi-worker:$SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=elpachanga1/multi-server:$SHA
kubectl set image deployments/client-deployment client=elpachanga1/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=elpachanga1/multi-worker:$SHA