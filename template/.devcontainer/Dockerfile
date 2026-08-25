# This inherits from base - add project specific dependencies and tooling here
#
# The base's helper scripts are on PATH, so they can be used here as well:
#   RUN installBinaryFromGithub.sh <owner/repo> <asset-template> [binary-name]
#   RUN installTreeFromGithub.sh <owner/repo> <asset-template> <name> <relative-bin> [version]

FROM mydevbox:latest

# runs as the unprivileged "ubuntu" user, which has passwordless sudo
# RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
#         some-package \
#     && sudo rm -rf /var/lib/apt/lists/*
