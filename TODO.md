# TODO

## Bugs
- Oauth2 Proxy needs proper node selectors (it should not run on spot instances) --> IN PROGRESS
  - fixed for oauth2-proxy deployment, but not for redis dependency (necessary options are not exposed through the Helm chart?)


## v2

- replace Theia with OpenVSCode Server (gitpod/openvscode-server) --> DONE
- Helm Controller --> DONE
- SealedSecrets Controller (w/o automatic rotation) --> IN PROGRESS
- ArgoCD --> DONE
- Dex connectors --> Github + Bitbucket DONE
- SSO option for Ingresses --> DONE (does not work on localdev)
- SSL with wildcard so we don't overload Letsencrypt
- Cert-manager support for DNS01 challenges (needed for wildcard certs)
- Gitignore stuff
- Refactor Terraform --> MOSTLY DONE
- Improve modularity 
- Automation for Docker images

## Argo Workflows training setup
- Basic setup with namespaced quickstart (use upstream) --> DONE
- ClusterRole granting proper permissions (look at Aggregation for ClusterRoles to decouple the RoleBinding from the ClusterRole itself -- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles)
- Ingress
- Webhook Router --> IN PROGRESS
- SSO
- Add Argo CLI to Kubetrain image (separate image?)

## ArgoCD training setup
- RBAC examples
- projects examples
- figure out how to use CLI with SSO --> DONE
  - Will not work from kubetrain environments as VSCode cannot launch a browser. However, from my laptop I can run `argocd login --sso <endpoint>` which will launch a browser where I can perform my SSO login
- Add ArgoCD CLI to Kubetrain image





