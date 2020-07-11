FROM debian:buster-slim as base

FROM base as base-amd64
ARG GITHUB_RUNNER_ARCH=x64
ARG KUBECTL_ARCH=amd64

FROM base as base-arm
ARG GITHUB_RUNNER_ARCH=arm
ARG KUBECTL_ARCH=arm

# main image
FROM base-$TARGETARCH

ARG GITHUB_RUNNER_VERSION

RUN apt-get update \
    && apt-get install -y \
        curl \
        sudo \
        git \
        jq \
        wget \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m github \
    && usermod -aG sudo github \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV CURL_CA_BUNDLE /usr/local/share/ca-certificates/cacert.pem

USER github
WORKDIR /home/github

RUN wget -O- https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-${GITHUB_RUNNER_ARCH}-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz \
    && sudo ./bin/installdependencies.sh

COPY --chown=github:github entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
