// TODO uncomment once correct configuration are in place
# resource "kubernetes_manifest" "argo_cd_crds" {
#   manifest = yamldecode(file("../../kubernetes/init/customresourcedefinition-applications.argoproj.io.yaml"))
# }

# resource "helm_release" "argo_cd" {
#   name       = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   version    = "5.51.0"

#   values = [
#     "${file("../../kubernetes/argocd/values.yaml")}"
#   ]

#   depends_on = [kubernetes_manifest.argo_cd_crds]
# }