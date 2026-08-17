#!/bin/bash
set -e

GRAFANA_PASSWORD=${GRAFANA_PASSWORD:-$(openssl rand -base64 16)}

echo "Добавление Helm репозиториев..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Создание namespace monitoring..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Создание секрета для Grafana..."
kubectl create secret generic grafana-admin-secret \
  --namespace monitoring \
  --from-literal=admin-user=admin \
  --from-literal=admin-password="${GRAFANA_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Установка ingress-nginx..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --wait --timeout 5m

echo "Установка kube-prometheus-stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values.yaml \
  --wait --timeout 10m

echo "Применение Ingress для Grafana..."
kubectl apply -f ingress.yaml

NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
echo ""
echo "Мониторинг установлен!"
echo "Grafana: http://${NODE_IP}:30080/grafana"
echo "Логин: admin"
echo "Пароль: ${GRAFANA_PASSWORD}"
echo ""
echo "Сохрани пароль! Он больше не будет показан."
