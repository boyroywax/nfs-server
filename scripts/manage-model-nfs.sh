#!/bin/bash

# Modular NFS Server Management Script
# Usage: ./manage-model-nfs.sh <action> <model-name> [storage-size]

set -e

ACTION=$1
MODEL_NAME=$2
STORAGE_SIZE=${3:-"10Gi"}

if [ -z "$ACTION" ] || [ -z "$MODEL_NAME" ]; then
    echo "Usage: $0 <action> <model-name> [storage-size]"
    echo ""
    echo "Actions:"
    echo "  deploy   - Deploy NFS server for the specified model"
    echo "  delete   - Delete NFS server for the specified model"
    echo "  status   - Show status of NFS server for the specified model"
    echo "  list     - List all deployed model NFS servers"
    echo ""
    echo "Examples:"
    echo "  $0 deploy llama32-1b 15Gi"
    echo "  $0 status llama32-1b"
    echo "  $0 delete gemma2-2b"
    echo "  $0 list"
    exit 1
fi

NAMESPACE=${NAMESPACE:-"default"}
IMAGE_NAME=${IMAGE_NAME:-"boyroywax/nfs-server:latest"}

# Function to create manifests for a model
create_manifests() {
    local model=$1
    local size=$2
    
    echo "Creating manifests for model: $model"
    
    # Create PVC
    cat > "pvc-${model}.yaml" << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${model}-pvc
  namespace: ${NAMESPACE}
  labels:
    app: nfs-server
    model: ${model}
    component: storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${size}
  storageClassName: "do-block-storage"
EOF

    # Create Deployment
    cat > "deployment-${model}.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-server-${model}
  namespace: ${NAMESPACE}
  labels:
    app: nfs-server
    model: ${model}
    version: v1.0
    component: storage
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-server
      model: ${model}
  template:
    metadata:
      labels:
        app: nfs-server
        model: ${model}
        version: v1.0
        component: storage
    spec:
      serviceAccountName: nfs-server-sa
      securityContext:
        runAsUser: 0
        runAsGroup: 0
        fsGroup: 0
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: nfs-server
        image: ${IMAGE_NAME}
        imagePullPolicy: Always
        ports:
        - name: nfs
          containerPort: 2049
          protocol: TCP
        - name: mountd
          containerPort: 20048
          protocol: TCP
        - name: rpcbind
          containerPort: 111
          protocol: TCP
        - name: rpcbind-udp
          containerPort: 111
          protocol: UDP
        - name: statd
          containerPort: 32765
          protocol: TCP
        - name: statd-out
          containerPort: 32766
          protocol: TCP
        securityContext:
          privileged: true
          runAsUser: 0
          runAsGroup: 0
          capabilities:
            add:
            - SYS_ADMIN
            - DAC_READ_SEARCH
            - NET_BIND_SERVICE
        env:
        - name: SHARE_NAME
          value: "${model}"
        - name: EXPORT_PATH
          value: "/nfsshare/data"
        - name: CLIENT_CIDR
          value: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
        - name: NFS_OPTIONS
          value: "rw,sync,no_subtree_check,no_root_squash,insecure"
        - name: TZ
          value: "UTC"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: model-storage
          mountPath: /nfsshare/data
        - name: nfs-state
          mountPath: /var/lib/nfs
        readinessProbe:
          exec:
            command:
            - showmount
            - -e
            - localhost
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        livenessProbe:
          exec:
            command:
            - showmount
            - -e
            - localhost
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
        startupProbe:
          exec:
            command:
            - showmount
            - -e
            - localhost
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 20
      volumes:
      - name: model-storage
        persistentVolumeClaim:
          claimName: ${model}-pvc
      - name: nfs-state
        emptyDir: {}
      nodeSelector:
        kubernetes.io/os: linux
EOF

    # Create Service
    cat > "service-${model}.yaml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: nfs-server-${model}
  namespace: ${NAMESPACE}
  labels:
    app: nfs-server
    model: ${model}
    component: storage
spec:
  type: ClusterIP
  selector:
    app: nfs-server
    model: ${model}
  ports:
  - name: nfs
    port: 2049
    targetPort: 2049
    protocol: TCP
  - name: mountd
    port: 20048
    targetPort: 20048
    protocol: TCP
  - name: rpcbind
    port: 111
    targetPort: 111
    protocol: TCP
  - name: rpcbind-udp
    port: 111
    targetPort: 111
    protocol: UDP
  - name: statd
    port: 32765
    targetPort: 32765
    protocol: TCP
  - name: statd-out
    port: 32766
    targetPort: 32766
    protocol: TCP
EOF
}

case $ACTION in
    "deploy")
        echo "Deploying NFS server for model: $MODEL_NAME"
        echo "Storage size: $STORAGE_SIZE"
        
        # Create temporary manifests
        create_manifests "$MODEL_NAME" "$STORAGE_SIZE"
        
        # Apply manifests
        kubectl apply -f "pvc-${MODEL_NAME}.yaml"
        kubectl apply -f "deployment-${MODEL_NAME}.yaml"
        kubectl apply -f "service-${MODEL_NAME}.yaml"
        
        # Clean up temporary files
        rm -f "pvc-${MODEL_NAME}.yaml" "deployment-${MODEL_NAME}.yaml" "service-${MODEL_NAME}.yaml"
        
        echo "NFS server for model '$MODEL_NAME' deployed successfully!"
        echo "Service: nfs-server-${MODEL_NAME}.${NAMESPACE}.svc.cluster.local"
        echo "Mount command: mount -t nfs4 nfs-server-${MODEL_NAME}.${NAMESPACE}.svc.cluster.local:/ /mount/point"
        ;;
        
    "delete")
        echo "Deleting NFS server for model: $MODEL_NAME"
        
        kubectl delete deployment "nfs-server-${MODEL_NAME}" -n "$NAMESPACE" --ignore-not-found=true
        kubectl delete service "nfs-server-${MODEL_NAME}" -n "$NAMESPACE" --ignore-not-found=true
        
        read -p "Delete PVC and data for ${MODEL_NAME}? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete pvc "${MODEL_NAME}-pvc" -n "$NAMESPACE" --ignore-not-found=true
            echo "PVC deleted - data will be lost!"
        else
            echo "PVC preserved - data retained"
        fi
        
        echo "NFS server for model '$MODEL_NAME' deleted!"
        ;;
        
    "status")
        echo "Status for NFS server model: $MODEL_NAME"
        echo ""
        
        echo "=== Deployment ==="
        kubectl get deployment "nfs-server-${MODEL_NAME}" -n "$NAMESPACE" 2>/dev/null || echo "Deployment not found"
        
        echo ""
        echo "=== Pod ==="
        kubectl get pods -l "app=nfs-server,model=${MODEL_NAME}" -n "$NAMESPACE" 2>/dev/null || echo "Pod not found"
        
        echo ""
        echo "=== Service ==="
        kubectl get service "nfs-server-${MODEL_NAME}" -n "$NAMESPACE" 2>/dev/null || echo "Service not found"
        
        echo ""
        echo "=== PVC ==="
        kubectl get pvc "${MODEL_NAME}-pvc" -n "$NAMESPACE" 2>/dev/null || echo "PVC not found"
        
        echo ""
        echo "=== Logs (last 10 lines) ==="
        kubectl logs -l "app=nfs-server,model=${MODEL_NAME}" -n "$NAMESPACE" --tail=10 2>/dev/null || echo "No logs available"
        ;;
        
    "list")
        echo "Deployed NFS servers:"
        echo ""
        kubectl get deployments -l "app=nfs-server" -n "$NAMESPACE" -o custom-columns="MODEL:.metadata.labels.model,NAME:.metadata.name,READY:.status.readyReplicas,AVAILABLE:.status.availableReplicas,AGE:.metadata.creationTimestamp" 2>/dev/null || echo "No NFS servers found"
        ;;
        
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac
