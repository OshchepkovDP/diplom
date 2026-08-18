#!/bin/bash
# Генерирует inventory для Kubespray из Terraform outputs
set -e

TERRAFORM_DIR="../terraform/infrastructure"
INVENTORY_FILE="inventory/hosts.yaml"

echo "Получаем Terraform outputs..."
cd "$TERRAFORM_DIR"

MASTER_EXT=$(terraform output -raw master_external_ip)
MASTER_INT=$(terraform output -raw master_internal_ip)
WORKER_EXT_IPS=($(terraform output -json worker_external_ips 2>/dev/null | python3 -c "import sys,json,re; d=sys.stdin.read(); m=re.search(r'\[.*?\]',d,re.DOTALL); [print(i) for i in json.loads(m.group())] if m else None"))
WORKER_INT_IPS=($(terraform output -json worker_internal_ips 2>/dev/null | python3 -c "import sys,json,re; d=sys.stdin.read(); m=re.search(r'\[.*?\]',d,re.DOTALL); [print(i) for i in json.loads(m.group())] if m else None"))

cd - > /dev/null
mkdir -p inventory

echo "Генерируем $INVENTORY_FILE..."

cat > "$INVENTORY_FILE" << EOF
all:
  hosts:
    k8s-master:
      ansible_host: ${MASTER_EXT}
      ip: ${MASTER_INT}
      ansible_user: ubuntu
EOF

for i in "${!WORKER_EXT_IPS[@]}"; do
  cat >> "$INVENTORY_FILE" << EOF
    k8s-worker-$((i+1)):
      ansible_host: ${WORKER_EXT_IPS[$i]}
      ip: ${WORKER_INT_IPS[$i]}
      ansible_user: ubuntu
EOF
done

cat >> "$INVENTORY_FILE" << 'EOF'
  children:
    kube_control_plane:
      hosts:
        k8s-master:
    kube_node:
      hosts:
EOF

for i in "${!WORKER_EXT_IPS[@]}"; do
  echo "        k8s-worker-$((i+1)):" >> "$INVENTORY_FILE"
done

cat >> "$INVENTORY_FILE" << 'EOF'
    etcd:
      hosts:
        k8s-master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
EOF

echo "Inventory сгенерирован: $INVENTORY_FILE"
echo ""
echo "Master:  $MASTER_EXT (внутренний: $MASTER_INT)"
for i in "${!WORKER_EXT_IPS[@]}"; do
  echo "Worker $((i+1)): ${WORKER_EXT_IPS[$i]} (внутренний: ${WORKER_INT_IPS[$i]})"
done
