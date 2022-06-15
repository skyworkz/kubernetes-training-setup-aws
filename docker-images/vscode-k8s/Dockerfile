FROM gitpod/openvscode-server:1.67.2

USER root

RUN apt-get update && \
    apt-get install -fy \
      coreutils \
      gettext \
      dnsutils \
      curl \
      jq \
      openssh-client \
    && rm -rf /var/lib/apt/lists/*

ARG YQ_VERSION=v4.11.2
ARG KUBECTL_VERSION=1.21.2
ARG KUSTOMIZE_VERSION=v4.1.3
ARG HELM_VERSION=v3.9.0
ARG K9S_VERSION=v0.24.15

# Install YQ
RUN curl -sL -o /usr/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 &&\
    chmod +x /usr/bin/yq

# Install Kubectl
RUN curl -sL -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl

# Install Kustomize
RUN curl -sL -o kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    mkdir -p kustomize && \
    tar xvzf kustomize.tar.gz -C kustomize && \
    mv kustomize/kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize && \
    rm -rf kustomize && \
    rm -f kustomize.tar.gz

# Install Helm
RUN curl -SL -o helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar xvzf helm.tar.gz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    rm -f helm.tar.gz

# Install KubeCTX
RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install K9s
RUN curl -sL -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz && \
    mkdir -p k9s && \
    tar xvzf k9s.tar.gz -C k9s && \
    mv k9s/k9s /usr/bin/k9s && \
    chmod +x /usr/bin/k9s && \
    rm -rf k9s && \
    rm -f k9s.tar.gz

ARG ARGO_CLI_VERSION=v3.3.6

# Install Argo CLI
RUN curl -sL -o argocli.gz https://github.com/argoproj/argo-workflows/releases/download/${ARGO_CLI_VERSION}/argo-linux-amd64.gz && \
    gunzip argocli.gz && \
    mv argocli /usr/bin/argo && \
    chmod +x /usr/bin/argo


# Fixes issue where HOME is set to /home/workspace in the parent image. This is
# probably done to make the VSCode file explorer open there by default but it
# breaks proper shell configuration in the process. They should've used VSCode's
# --default-folder parameter instead (which is what we do in the K8s manifest)
ENV HOME=/home/openvscode-server

COPY bash_aliases /home/openvscode-server/.bash_aliases
RUN chown openvscode-server:openvscode-server /home/openvscode-server/.bash_aliases

USER openvscode-server
