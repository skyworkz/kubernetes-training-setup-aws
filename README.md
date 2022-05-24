# kubernetes-training-setup-aws
Setup used for Kubernetes trainings on AWS

## What is all this?
This repo contains the technical components for running a Kubernetes training on AWS. It includes: 

1. Docker images for relevant components (e.g. Theia IDE)
2. Terraform setup to run an EKS environment
3. Cluster K8s Manifests to install basic services on EKS (nginx ingress, cert-manager)
4. Kubetrain K8s setup

## Notes

### Building the setup

Step 1: make sure you have the required access

Step 2: generate the secrets you need

Step 3: create the AWS environment with the following steps:

1. Apply the `terraform/base-eks` plan. It will create the VPC and EKS cluster, and will write a `terraform.tfvars` file for the `k8s-svc` plan you will apply later.
2. Set your `KUBECONFIG` to the generated KubeConfig, or create a new one with AWSCLI (there are some issues around K8s 1.24.0 that cause the generated config to break)
3. Apply the `cert-manager.yaml` and `nginx-ingress.yaml` files from `cluster-k8s-manifests` directly. You may need to do this twice due to CRD ordering (this still needs fixing)
4. Apply the `terraform/k8s-svc` plan

### Localdev setup
If you're not ready for AWS yet, you can use K3D on Docker Desktop. Make sure you have both installed (Homebrew is your friend). Then navigate to the `localdev` directory and execute the `./bootstrap-localdev` script. It makes assumptions on availability of tools, so it may not work for you. 



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
