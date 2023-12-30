# Kind Hello-world

- Deploy a `dockerized` web page on `kind` cluster.
- Create `github-action` to validate deployments.

---

## Requirements

- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [envsubst](https://manpages.ubuntu.com/manpages/focal/man1/envsubst.1.html), and
- [Docker](https://www.docker.com/)

## Prerequisites

Before running the deployment script, ensure you have the following tools installed on your system:

1. **kind**: A tool for running local Kubernetes clusters using Docker container "nodes". Installation guide: [kind installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).

2. **kubectl**: The Kubernetes command-line tool. Installation guide: [kubectl installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

3. **envsubst**: A utility for substituting environment variables. Usually available on Unix-based systems. If it's not available, you can install it via [gettext](https://www.gnu.org/software/gettext/).

4. **Docker**: The Docker engine to build and run container images. Installation guide: [Docker installation](https://docs.docker.com/get-docker/).

## Deployment

To deploy the "Hello World" website on your local Kubernetes cluster, run the following command:

```bash
./deploy.sh
```

The script will automatically create a local Kubernetes cluster using `kind`, build the Docker image, load the image into the cluster, deploy the pod and a nodeport service, and provide the URL to access the application.

## Cleanup

To remove the Kubernetes cluster and clean up resources, you can use the following command:

```bash
./deploy.sh cleanup
```

This will delete the previously created Kubernetes cluster.