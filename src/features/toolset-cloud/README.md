# Cloud CLI Tools Feature

Command-line tools for AWS, Google Cloud, Azure, and other cloud providers.

## Tools Included

- **AWS CLI v2** - Amazon Web Services CLI
- **gcloud** - Google Cloud SDK (opt-in)
- **az** - Azure CLI (opt-in)
- **doctl** - DigitalOcean CLI (opt-in)

## Usage

### Default (AWS only)
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-cloud:1": {}
  }
}
```

### Multi-Cloud
```json
{
  "features": {
    "ghcr.io/xrf9268-hue/features/toolset-cloud:1": {
      "installAwsCli": true,
      "installGcloud": true,
      "installAzureCli": true
    }
  }
}
```

## Tool Usage

### AWS CLI
```bash
aws configure
aws s3 ls
aws ec2 describe-instances
```

### gcloud
```bash
gcloud init
gcloud projects list
gcloud compute instances list
```

### Azure CLI
```bash
az login
az account list
az vm list
```

### doctl
```bash
doctl auth init
doctl compute droplet list
```
