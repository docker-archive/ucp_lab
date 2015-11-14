export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=$(pwd)
export DOCKER_HOST=tcp://52.33.21.106:443
# Run this command from within this directory to configure your shell:
# eval $(<env.sh)

# This admin cert will also work directly against Swarm and the individual
# engine proxies for troubleshooting.  After sourcing this env file, use
# "docker info" to discover the location of Swarm managers and engines.
# and use the --host option to override $DOCKER_HOST
