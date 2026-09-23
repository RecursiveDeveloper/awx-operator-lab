# AWX Operator Lab

Deploy **AWX** on top of a Kubernetes cluster using the official **AWX Operator**.

This lab provisions a full AWX instance (the web-based UI to run, manage and schedule Ansible playbooks) through a single bash script. The operator is installed with Kustomize, an `AWX` custom resource is created, and once the cluster has reconciled the resource you can reach the AWX web UI through a port-forward.

The whole lifecycle is handled by two bash scripts: `deploy-awx-operator.sh` for deployment and `destroy-awx-operator.sh` for teardown.

## Project Structure

```
awx-operator-lab/
├── README.md
├── deploy-awx-operator.sh       # Clones the operator, applies kustomization and prints AWX access info
├── destroy-awx-operator.sh      # Removes operator resources and the cloned directory
├── kustomization.yaml           # Declares the AWX Operator resources and the AWX CR
├── awx-demo.yml                 # AWX custom resource (nodeport service type)
├── workers/                     # Docker Compose stack with target containers for AWX
│   ├── docker-compose.yml       # Defines fedora, ubuntu and debian worker services
│   ├── deploy_services.sh       # Generates SSH key pair and starts the containers
│   ├── destroy_services.sh      # Stops and removes the containers and generated keys
│   ├── fedora/Dockerfile
│   ├── ubuntu/Dockerfile
│   └── debian/Dockerfile
└── playbooks/                   # Sample Ansible playbooks to run against the worker containers
    └── install_nginx.yml        # Prints container hostname and installs nginx on each target
```

## Tech Stack

- **Kubernetes:** MicroK8s
- **Operator:** AWX Operator v2.19.1
- **Manifest tooling:** Kustomize
- **Automation server:** AWX
- **Target containers:** Fedora, Ubuntu, Debian (via Docker Compose)
- **Tools:** Bash, kubectl, Docker

## Prerequisites

Before deploying this project, ensure you have the following prerequisites in place:

1. **A [MicroK8s](https://microk8s.io/docs/getting-started) cluster** running with the following addons enabled:

   - `microk8s enable dns`
   - `microk8s enable ingress`

2. **MicroK8s group membership** so `microk8s kubectl` runs without `sudo`:

   ```bash
   sudo usermod -aG microk8s $USER
   ```

3. **Git** installed. [Git Install](https://git-scm.com/downloads)

   The `deploy-awx-operator.sh` script clones the AWX Operator repository, so git must be available on the machine.

## Workers

The `workers/` folder contains a Docker Compose stack that spins up three containers — **Fedora**, **Ubuntu**, and **Debian** — each running an SSH server. These containers act as the target hosts that AWX will manage and run playbooks against.

Each container has its own OS user (`fedora`, `ubuntu`, `debian`) with passwordless sudo, and SSH access is granted via a key pair generated at deploy time.

**Start the worker containers:**

```bash
cd workers
bash deploy_services.sh
```

This script generates an RSA key pair (`rsa_lab` / `rsa_lab.pub`), then starts the containers via Docker Compose. The public key is bind-mounted into each container's `authorized_keys`, and the private key (`rsa_lab`) is the one you register in AWX as a Machine credential.

**Stop and remove the containers:**

```bash
bash destroy_services.sh
```

## Playbooks

The `playbooks/` folder contains sample playbooks meant to be imported into AWX and executed against the worker containers.

| Playbook | Description |
|---|---|
| `install_nginx.yml` | Prints `Hello from container <hostname>` on each target, then installs and starts nginx. Handles both `apt` (Ubuntu/Debian) and `dnf` (Fedora) package managers automatically. |

## Deployment

Follow these steps in order to have a fully working lab:

**1. Deploy AWX**

```bash
bash deploy-awx-operator.sh
```

This script clones the AWX Operator repository (tag `2.19.1`), copies `awx-demo.yml` and `kustomization.yaml` into the operator directory, applies the kustomization, sets the namespace to `awx`, and prints the admin password once the stack is ready.

Wait for the pods to reach `Running` state:

```bash
microk8s kubectl get pods -n awx --watch
```

Then access the AWX Web UI via port-forward:

```bash
microk8s kubectl port-forward svc/awx-demo-service 5000:80
```

Open `http://localhost:5000` and log in with user `admin` and the password printed by the deploy script.

> **Note:** The AWX Web UI may take **up to 10 minutes** to be fully ready after pods are running, depending on cluster resources.

**2. Start the worker containers**

```bash
cd workers
bash deploy_services.sh
```

This generates an RSA key pair and starts the Fedora, Ubuntu and Debian containers via Docker Compose. The private key (`rsa_lab`) is the one to register in AWX as a Machine credential.

**3. Configure AWX**

- Add `workers/rsa_lab` as a **Machine credential** in AWX.
- Create an **Inventory** and add each container as a host with the following variables:

```yaml
---
ansible_host: <YOUR_HOST_IP>
ansible_port: <CONTAINER_PORT>
ansible_user: <CONTAINER_USER>
ansible_connection: ssh
```

| Container | Port | User |
|---|---|---|
| fedora-server | 2201 | fedora |
| ubuntu-server | 2202 | ubuntu |
| debian-server | 2203 | debian |

- Create a **Project** pointing to this repository and a **Job Template** using any playbook from the `playbooks/` folder.

**4. Tear down**

```bash
# Remove AWX resources and cloned operator directory
bash destroy-awx-operator.sh

# Stop and remove worker containers
cd workers && bash destroy_services.sh
```

If needed, you can customize the AWX deployment by modifying `awx-demo.yml` (for example, changing the `service_type` to `LoadBalancer` or `ClusterIP`).

For further information, check the official AWX Operator documentation: [Basic Install](https://docs.ansible.com/projects/awx-operator/en/latest/installation/basic-install.html)

## Authors

- [@RecursiveDeveloper](https://github.com/RecursiveDeveloper)

## License

[MIT](https://choosealicense.com/licenses/mit/)