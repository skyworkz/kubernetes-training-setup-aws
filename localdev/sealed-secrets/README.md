# PADS Bootstrap - Sealed Secrets

## What is this?
This directory holds the necessary bits for the Sealed Secrets part of PADS. This means:

- HelmChart resources for Sealed Secrets Controller and Sealed Secrets Web UI for [local](./local/) and [AWS](./aws/) environments
- Local [git-ignored directory](./encryption-key/) storage of Sealed Secrets encryption key (for local clusters)
- [Script](./backup-sealedsecrets-key) for backing up Sealed Secrets encryption keys to AWS Secrets Manager

## Deploying Sealed Secrets components on local and AWS environments
Generally, the components are deployed mostly in an identical way. We use HelmChart resources to define the deployment which are then handled by the Helm Controller running inside the cluster. There are some small differences between environments though:

- HelmChart namespace: for local clusters, the HelmChart resources are created in `kube-system`, for AWS they are created in `helm-controller`
- Sealed Secrets Controller key renewal:
  - disabled on local clusters
  - default (30days) on AWS clusters

## Backing up Sealed Secrets keys

### Manual Backup
We are backing up the Sealed Secrets keys to AWS Secrets Manager. To do this, we use the `backup-sealedsecrets-key` script. The script takes a single argument; the environment name. 

There are some things to keep in mind when performing a backup:
- AWS profile names are hard-coded, and your local setup needs to match those (similar for how bootstrap-localdev works)
- Kubernetes context names are hard-coded, and your local setup needs to match those
- You need to make sure you have the correct Kubernetes context active when performing a backup. The script will check this, and will stop if the desired context is not active

Example:

```bash
❯ sealed-secrets/backup-sealedsecrets-key local
===> Selecting config for environment local..
===> Verifying Kubernetes context. Expecting context k3d-pads-localdev
===> Kubernetes context set correctly. Moving on..
===> Getting Sealed Secrets encryption keys from Kubernetes..
===> Verifying AWS configuration for profile pads-staging
===> You may be prompted for an MFA code. If so, please enter the code..
===> AWS Config valid.
===> AWS Secret PADS/local/sealed-secrets-key exists. Will update it..
{
    "ARN": "arn:aws:secretsmanager:eu-west-1:355547979621:secret:PADS/local/sealed-secrets-key-4LZ0My",
    "Name": "PADS/local/sealed-secrets-key",
    "VersionId": "5200b32b-74f1-4284-b19c-df1906397698",
    "VersionStages": [
        "AWSCURRENT"
    ]
}
===> Sealed Secrets encryption key for environment local successfully backed up to AWS Secret PADS/local/sealed-secrets-key on AWS account 355547979621.
===> Cleaning up temporary files
===> Returning to /Users/benny/git/planon/pads/pads.bootstrap
```

### Automated Backup
We are also backing up the encryption keys automatically using a CronJob that runs inside each PADS cluster. For more information, see [backup-k8s/README.md](./backup-k8s/README.md).
