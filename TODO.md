# TODO

## Bugs
- Oauth2 Proxy needs proper node selectors (it should not run on spot instances) --> DONE
  - fixed for oauth2-proxy deployment, but not for redis dependency (necessary options are not exposed through the Helm chart?) --> Redis seems to use PodAffinity, not entirely sure yet
- Nginx Ingress Controller is running single-instanced and has no anti-affinity set so scaling up might cause all instances to run on the same node --> DONE
- Aggregated permissions for kubetrain-participant are cluster-level unless we find out how to make decoupled assignment of permissions easier


## v2

- replace Theia with OpenVSCode Server (gitpod/openvscode-server) --> DONE
- Helm Controller --> DONE
- SealedSecrets Controller (w/o automatic rotation) --> IN PROGRESS
- ArgoCD --> DONE
- Dex connectors --> Github + Bitbucket DONE
- SSO option for Ingresses --> DONE (does not work on localdev)
- SSL with wildcard so we don't overload Letsencrypt --> DONE
  - Create default wildcard cert on cert-manager deployment
  - Added default wildcard cert to Nginx config so ingresses without `tls.*.secretName` will use the default cert
  - Moved Kubetrain Kustomize setup to use the default wildcard cert
- Cert-manager support for DNS01 challenges (needed for wildcard certs) --> DONE
  - use `matchLabels` selector on `dns01` solver so we solve via `http01` by default, and only use DNS when we really need to
- Gitignore stuff
- Refactor Terraform --> MOSTLY DONE
- Improve modularity 
- Automation for Docker images
- Move to Helm charts:
  - Nginx Ingress Controller
  - Cert Manager
- Move to Terraform:
  - Nginx Ingress
  - Cert Manager
  - Helm Controller
  - Oauth2 Proxy


## Argo Workflows training setup
- Basic setup with namespaced quickstart (use upstream) --> DONE
- ClusterRole granting proper permissions (look at Aggregation for ClusterRoles to decouple the RoleBinding from the ClusterRole itself -- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles)
- Ingress --> DONE
- Webhook Router --> DONE
- SSO --> DONE
- Add Argo CLI to Kubetrain image (separate image?) --> 
  - Added to existing image
- RBAC for Kubetrain ServiceAccount --> DONE
  - added kubetrain-participant clusterrole in Terraform k8s-svc level with an AggregationRule so other ClusterRoles can add permissions to this ClusterRole
  - add ClusterRole with Argo Workflows/Events permissions to argo-workflows Kustomization - add label for aggregation to kubetrain-participant
  - add ClusterRoleBinding to kubetrain ServiceAccount which binds kubetrain-participant ClusterRole
  - Caveat: this grants all permissions on cluster level which is a lot wider than we actually want

## ArgoCD training setup
- RBAC examples
- projects examples
- figure out how to use CLI with SSO --> DONE
  - Will not work from kubetrain environments as VSCode cannot launch a browser. However, from my laptop I can run `argocd login --sso <endpoint>` which will launch a browser where I can perform my SSO login
- Add ArgoCD CLI to Kubetrain image
- RBAC for Kubetrain ServiceAccount





