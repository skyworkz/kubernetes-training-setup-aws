# Github SSO
## Github Application

Homepage URL: https://argocd.k8s.aws-tests.skyworkz.nl/
Callback URL: https://argocd.k8s.aws-tests.skyworkz.nl/api/dex/callback
Whitelist the AWS VPC (172.20.0.0/16)

Permissions:
- Repository Permissions:
    - Contents: Read-Only
    - Metadata: Read-Only (Mandatory)
- Organization Permissions:
    - Members: Read-Only
- Account Permissions:
    - Email Adresses: Read-Only
