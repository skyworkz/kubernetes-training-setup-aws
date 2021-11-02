# kubernetes-training-setup-aws
Setup used for Kubernetes trainings on AWS

## What is all this?
This repo contains the technical components for running a Kubernetes training on AWS. It includes: 

1. Docker images for relevant components (e.g. Theia IDE)
2. Terraform setup to run an EKS environment
3. Cluster K8s Manifests to install basic services on EKS (nginx ingress, cert-manager)
4. Kubetrain K8s setup

## Notes

### Turning the setup off
If you want to temporarily restrict all external access to running endpoints, run the following: 

```
kubectl scale deployment -n ingress-nginx ingress-nginx-controller --replicas=0
```

Increase the `replicas` back to `1` to turn Ingress back on.

### AWS SSO Roles and EKS
If you're signing into an AWS Account through AWS SSO and you spin up an EKS cluster, don't forget to add the SSO Role to the AWS Auth Configmap.

### Secrets are ignored!
A key part of this setup is the Kubernetes secret needed in `kubetrain-k8s` that is used for accessing the Git repo with training material. It contains the git repo URL (SSH) and the private key. An example secret is included in `secret-example.yaml`
