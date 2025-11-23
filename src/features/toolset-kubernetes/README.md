# Kubernetes Tools Feature

Essential tools for Kubernetes development and operations.

## Tools Included

- **kubectl** - Kubernetes CLI
- **helm** - Kubernetes package manager
- **k9s** - Terminal UI for Kubernetes
- **kubectx/kubens** - Context and namespace switcher
- **kustomize** - Configuration customization (opt-in)
- **skaffold** - Local development tool (opt-in)

## Usage

### Default (kubectl, helm, k9s, kubectx)
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-kubernetes:1": {}
  }
}
```

### Full Stack
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-kubernetes:1": {
      "installKustomize": true,
      "installSkaffold": true
    }
  }
}
```

## Tool Usage

### kubectl
```bash
kubectl get pods
kubectl apply -f deployment.yaml
kubectl logs -f pod-name
```

### helm
```bash
helm install myapp ./chart
helm list
helm upgrade myapp ./chart
```

### k9s
```bash
k9s  # Opens interactive UI
```

### kubectx/kubens
```bash
kubectx                # List contexts
kubectx minikube       # Switch context
kubens default         # Switch namespace
```

### kustomize
```bash
kustomize build ./overlays/production
kubectl apply -k ./overlays/production
```

### skaffold
```bash
skaffold dev           # Continuous development
skaffold run           # One-off deployment
```
