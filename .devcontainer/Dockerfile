ARG VARIANT=bullseye
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}
RUN curl -fsSL https://aka.ms/install-azd.sh | bash \
    && apt-get update && rm -rf /var/lib/apt/lists/*