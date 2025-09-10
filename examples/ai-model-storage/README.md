# AI/ML Model Storage Examples

This directory contains examples for using the Alpine NFS Server with AI/ML workloads.

## Examples

- [`ollama-llama32-1b.yaml`](ollama-llama32-1b.yaml) - Ollama deployment with shared LLaMA 3.2 1B model storage
- [`pytorch-training.yaml`](pytorch-training.yaml) - PyTorch training jobs with shared dataset storage
- [`jupyter-notebooks.yaml`](jupyter-notebooks.yaml) - JupyterHub with shared notebook and data storage

## Use Cases

### Large Language Models (LLMs)
- **Model Sharing**: One NFS server per model, shared across multiple inference pods
- **Version Management**: Separate NFS servers for different model versions
- **Hot Swapping**: Update models without restarting inference services

### Training Workloads
- **Dataset Storage**: Large datasets accessible by multiple training jobs
- **Checkpoint Sharing**: Share training checkpoints across distributed training
- **Result Storage**: Centralized storage for training outputs and logs

### Development Environments
- **Notebook Sharing**: Shared Jupyter notebooks across team members
- **Experiment Tracking**: Centralized experiment data and results
- **Model Registry**: Simple model storage and versioning

## Quick Start

```bash
# Deploy NFS server for LLaMA 3.2 1B model
kubectl apply -f ollama-llama32-1b.yaml

# Check deployment status
kubectl get pods -l app=nfs-server-llama32-1b

# View service information
kubectl get svc nfs-server-llama32-1b
```

## Performance Considerations

### For High-Throughput Inference
- Use `async` NFS options for better performance
- Consider multiple NFS servers for load distribution
- Use local storage for frequently accessed models

### For Training Workloads
- Use `sync` options for data consistency
- Consider dedicated high-performance storage
- Use ReadWriteMany volumes for distributed training

## Security Notes

- Restrict client access using `CLIENT_CIDR`
- Consider using `root_squash` for production environments
- Implement network policies for additional security
- Monitor access logs for unusual activity
