FROM gitpod/openvscode-server:1.67.2

USER root

RUN apt-get update && \
    apt-get install -fy \
      coreutils \
      gettext \
      dnsutils \
      curl \
      jq \
    && rm -rf /var/lib/apt/lists/*

ARG YQ_VERSION=v4.11.2
ARG KUBECTL_VERSION=1.21.2
ARG KUSTOMIZE_VERSION=v4.1.3
ARG K9S_VERSION=v0.24.15

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

RUN curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    mv kustomize /usr/bin/kustomize && \
    chmod +x /usr/bin/kustomize

RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens

RUN curl -sLO https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz && \
  tar xvzf k9s_Linux_x86_64.tar.gz && \
  mv k9s /usr/bin/k9s && \
  chmod +x /usr/bin/k9s


USER openvscode-server
