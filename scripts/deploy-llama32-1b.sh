#!/bin/bash
set -e

# Llama 3.2 1B Model NFS Server Deployment Script
# Uses the modular NFS server for dedicated Llama 3.2 1B model storage

# Configuration
MODEL_NAME="llama32-1b"
STORAGE_SIZE="15Gi"  # Llama 3.2 1B model typically needs ~2GB, 15Gi provides room for growth
NAMESPACE="default"
NFS_IMAGE="boyroywax/nfs-server:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGE_SCRIPT="${SCRIPT_DIR}/manage-model-nfs.sh"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if management script exists
check_dependencies() {
    if [[ ! -f "$MANAGE_SCRIPT" ]]; then
        print_error "Management script not found at: $MANAGE_SCRIPT"
        print_error "Please ensure you're running this script from the NFS directory"
        exit 1
    fi
    
    if [[ ! -x "$MANAGE_SCRIPT" ]]; then
        print_warning "Making management script executable..."
        chmod +x "$MANAGE_SCRIPT"
    fi
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if we can connect to Kubernetes
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Llama 3.2 1B Model NFS Server Management"
    echo "Usage: $0 <action> [options]"
    echo ""
    echo "Actions:"
    echo "  deploy          Deploy NFS server for Llama 3.2 1B model"
    echo "  delete          Delete NFS server and optionally data"
    echo "  status          Show status of the NFS server"
    echo "  logs            Show recent logs from the NFS server"
    echo "  mount-info      Show mount information for clients"
    echo "  restart         Restart the NFS server (rolling update)"
    echo "  scale-storage   Update storage size (requires restart)"
    echo ""
    echo "Options:"
    echo "  --storage-size SIZE   Override default storage size (default: ${STORAGE_SIZE})"
    echo "  --namespace NS        Override default namespace (default: ${NAMESPACE})"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 deploy --storage-size 25Gi"
    echo "  $0 status"
    echo "  $0 mount-info"
    echo "  $0 delete"
}

# Function to deploy the NFS server
deploy_nfs() {
    print_status "Deploying NFS server for Llama 3.2 1B model..."
    print_status "Model: ${MODEL_NAME}"
    print_status "Storage: ${STORAGE_SIZE}"
    print_status "Namespace: ${NAMESPACE}"
    print_status "Image: ${NFS_IMAGE}"
    echo ""
    
    # Check if already deployed
    if kubectl get deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}" &> /dev/null; then
        print_warning "NFS server for ${MODEL_NAME} already exists!"
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deployment cancelled"
            exit 0
        fi
    fi
    
    # Deploy using the management script
    if "$MANAGE_SCRIPT" deploy "$MODEL_NAME" "$STORAGE_SIZE"; then
        print_success "NFS server deployed successfully!"
        echo ""
        print_status "Waiting for deployment to be ready..."
        kubectl rollout status deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}" --timeout=300s
        
        show_mount_info
    else
        print_error "Deployment failed!"
        exit 1
    fi
}

# Function to delete the NFS server
delete_nfs() {
    print_warning "This will delete the NFS server for Llama 3.2 1B model"
    print_warning "Model: ${MODEL_NAME}"
    print_warning "Namespace: ${NAMESPACE}"
    echo ""
    
    if ! kubectl get deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}" &> /dev/null; then
        print_error "NFS server for ${MODEL_NAME} not found"
        exit 1
    fi
    
    # Use the management script to delete
    if "$MANAGE_SCRIPT" delete "$MODEL_NAME"; then
        print_success "NFS server deleted successfully!"
    else
        print_error "Deletion failed!"
        exit 1
    fi
}

# Function to show status
show_status() {
    print_status "Status for Llama 3.2 1B NFS server..."
    echo ""
    
    if ! kubectl get deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}" &> /dev/null; then
        print_error "NFS server for ${MODEL_NAME} not found"
        print_status "Use '$0 deploy' to create it"
        exit 1
    fi
    
    "$MANAGE_SCRIPT" status "$MODEL_NAME"
}

# Function to show logs
show_logs() {
    print_status "Recent logs for Llama 3.2 1B NFS server..."
    echo ""
    
    local pod_name
    pod_name=$(kubectl get pods -n "${NAMESPACE}" -l "app=nfs-server,model=${MODEL_NAME}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [[ -z "$pod_name" ]]; then
        print_error "No running pod found for ${MODEL_NAME}"
        exit 1
    fi
    
    kubectl logs "$pod_name" -n "${NAMESPACE}" --tail=50 --follow
}

# Function to show mount information
show_mount_info() {
    print_status "Mount information for Llama 3.2 1B model NFS server:"
    echo ""
    echo "📦 Model: ${MODEL_NAME}"
    echo "🌐 Service: nfs-server-${MODEL_NAME}.${NAMESPACE}.svc.cluster.local"
    echo "📁 Export Path: /nfsshare/data"
    echo ""
    echo "🔧 Mount Commands:"
    echo ""
    echo "  # For Kubernetes pods (add to your pod spec):"
    echo "  volumes:"
    echo "  - name: ${MODEL_NAME}-models"
    echo "    nfs:"
    echo "      server: nfs-server-${MODEL_NAME}.${NAMESPACE}.svc.cluster.local"
    echo "      path: /"
    echo ""
    echo "  # For manual mounting (from within cluster):"
    echo "  mount -t nfs4 nfs-server-${MODEL_NAME}.${NAMESPACE}.svc.cluster.local:/ /mnt/${MODEL_NAME}"
    echo ""
    echo "  # For testing access:"
    echo "  kubectl run -it --rm nfs-test --image=busybox --restart=Never -- sh"
    echo "  # Then inside the container:"
    echo "  # mount -t nfs4 nfs-server-${MODEL_NAME}.${NAMESPACE}.svc.cluster.local:/ /mnt"
    echo ""
}

# Function to restart the NFS server
restart_nfs() {
    print_status "Restarting NFS server for ${MODEL_NAME}..."
    
    if ! kubectl get deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}" &> /dev/null; then
        print_error "NFS server for ${MODEL_NAME} not found"
        exit 1
    fi
    
    kubectl rollout restart deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}"
    kubectl rollout status deployment "nfs-server-${MODEL_NAME}" -n "${NAMESPACE}" --timeout=300s
    
    print_success "NFS server restarted successfully!"
}

# Function to scale storage (requires recreation)
scale_storage() {
    local new_size="$1"
    
    if [[ -z "$new_size" ]]; then
        print_error "Storage size required for scaling"
        echo "Usage: $0 scale-storage <new-size>"
        echo "Example: $0 scale-storage 25Gi"
        exit 1
    fi
    
    print_warning "Scaling storage requires recreating the NFS server"
    print_warning "Current size: ${STORAGE_SIZE}"
    print_warning "New size: ${new_size}"
    print_warning "This will cause temporary downtime"
    echo ""
    
    read -p "Continue with storage scaling? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Storage scaling cancelled"
        exit 0
    fi
    
    # Delete current deployment
    print_status "Deleting current deployment..."
    delete_nfs
    
    # Deploy with new storage size
    STORAGE_SIZE="$new_size"
    deploy_nfs
    
    print_success "Storage scaled to ${new_size}!"
}

# Parse command line arguments
ACTION=""
while [[ $# -gt 0 ]]; do
    case $1 in
        deploy|delete|status|logs|mount-info|restart)
            ACTION="$1"
            shift
            ;;
        scale-storage)
            ACTION="scale-storage"
            shift
            if [[ $# -gt 0 && ! $1 =~ ^-- ]]; then
                SCALE_SIZE="$1"
                shift
            fi
            ;;
        --storage-size)
            STORAGE_SIZE="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "🦙 Llama 3.2 1B Model NFS Server Manager"
    echo "========================================"
    echo ""
    
    check_dependencies
    
    case "$ACTION" in
        deploy)
            deploy_nfs
            ;;
        delete)
            delete_nfs
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        mount-info)
            show_mount_info
            ;;
        restart)
            restart_nfs
            ;;
        scale-storage)
            scale_storage "$SCALE_SIZE"
            ;;
        "")
            print_error "No action specified"
            echo ""
            show_usage
            exit 1
            ;;
        *)
            print_error "Invalid action: $ACTION"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
