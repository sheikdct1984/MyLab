
kubectl create namespace logging


helm repo add elastic https://helm.elastic.co

helm install elasticsearch \
  --set replicas=1 \
  --set volumeClaimTemplate.storageClassName=managed \
  --set persistence.labels.enabled=true \
  elastic/elasticsearch -n logging --atomic

kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.username}' | base64 -d


kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d

helm install kibana --set service.type=LoadBalancer elastic/kibana -n logging --atomic


helm repo add fluent https://fluent.github.io/helm-charts

helm upgrade --install fluent-bit fluent/fluent-bit -f fluentbit-values.yaml -n logging --atomic
