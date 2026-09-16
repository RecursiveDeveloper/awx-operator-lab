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
└── awx-demo.yml                 # AWX custom resource (nodeport service type)
```

## Tech Stack

- **Kubernetes:** MicroK8s
- **Operator:** AWX Operator v2.19.1
- **Manifest tooling:** Kustomize
- **Automation server:** AWX
- **Tools:** Bash, kubectl

## Prerequisites

Before deploying this project, ensure you have the following prerequisites in place:

1. **A MicroK8s cluster** running with the following addons enabled:

   - `microk8s enable dns`
   - `microk8s enable ingress`

2. **MicroK8s group membership** so `microk8s kubectl` runs without `sudo`:

   ```bash
   sudo usermod -aG microk8s $USER
   ```

3. **Git** installed. [Git Install](https://git-scm.com/downloads)

   The `deploy-awx-operator.sh` script clones the AWX Operator repository, so git must be available on the machine.

## Deployment

To deploy this project from the project root, follow these steps:

1. **Run the deploy script:**

   ```bash
   bash deploy-awx-operator.sh
   ```

   This script performs:

   - Cloning of the AWX Operator repository (tag `2.19.1`)
   - Copying of `awx-demo.yml` and `kustomization.yaml` into the operator directory
   - Application of the kustomization with `microk8s kubectl apply -k .`
   - Setting of the current context namespace to `awx`
   - Waiting for the `awx-demo-admin-password` secret to be created
   - Printing of the admin password

2. **Wait for the AWX instance to become ready:**

   ```bash
   microk8s kubectl get pods -n awx --watch
   ```

   Wait until the `awx-demo-*` pods reach the `Running` state.

3. **Access the AWX Web UI via port-forward:**

   ```bash
   microk8s kubectl port-forward svc/awx-demo-service 5000:80
   ```

   Then open `http://localhost:5000` in your browser and log in with the user `admin` and the password printed by the deploy script.

4. **To tear down the environment (AWX resources and cloned operator directory):**

   ```bash
   bash destroy-awx-operator.sh
   ```

If needed, you can customize the AWX deployment by modifying `awx-demo.yml` (for example, changing the `service_type` to `LoadBalancer` or `ClusterIP`).

For further information, check the official AWX Operator documentation: [Basic Install](https://docs.ansible.com/projects/awx-operator/en/latest/installation/basic-install.html)

## Authors

- [@RecursiveDeveloper](https://github.com/RecursiveDeveloper)

## License

[MIT](https://choosealicense.com/licenses/mit/)