# Enterprise Kubernetes Architecture & Operations Master Reference

An enterprise-grade, all-in-one reference guide designed for high-frequency DevOps environments and rapid pre-interview technical revision. This document covers cluster architecture, API object specifications, state management, security boundaries, and advanced `kubectl` troubleshooting matrices.

---

## 1. Control Plane & Node Architecture

Kubernetes is a declarative, distributed state-management engine. It maintains a target state by continuously running reconciliation loops against a centralized datastore.

```
                  +-------------------------------------------------------+
                  |                     CONTROL PLANE                     |
                  |                                                       |
  kubectl ------> |   +------------+     +---------------+     +------+   |
                  |   | API Server | <-> |   Scheduler   |     | etcd |   |
                  |   +------------+     +---------------+     +------+   |
                  |         ^                                             |
                  |         |            +--------------------+           |
                  |         +----------> | Controller Manager |           |
                  |                      +--------------------+           |
                  +-------------------------------------------------------+
                                              |
                     +------------------------+------------------------+
                     |                                                 |
                     v                                                 v
        +-------------------------+                       +-------------------------+
        |        DATA NODE        |                       |        DATA NODE        |
        |                         |                       |                         |
        |  +-------------------+  |                       |  +-------------------+  |
        |  |      kubelet      |  |                       |  |      kubelet      |  |
        |  +-------------------+  |                       |  +-------------------+  |
        |            |            |                       |            |            |
        |            v            |                       |            v            |
        |  +-------------------+  |                       |  +-------------------+  |
        |  | Container Runtime |  |                       |  | Container Runtime |  |
        |  +-------------------+  |                       |  +-------------------+  |
        |            |            |                       |            |            |
        |            v            |                       |            v            |
        |  +-------------------+  |                       |  +-------------------+  |
        |  |    kube-proxy     |  |                       |  |    kube-proxy     |  |
        |  +-------------------+  |                       |  +-------------------+  |
        +-------------------------+                       +-------------------------+

```

### The Control Plane (Master Components)

* **kube-apiserver**: The gateway of the cluster. It exposes the Kubernetes API, intercepts structural requests, handles authentication/authorization (RBAC), and validates schema compliance. It is the *only* component that talks directly to `etcd`.
* **etcd**: A strongly consistent, distributed key-value store used as Kubernetes' backing store for all cluster data. It uses the Raft consensus algorithm. Quorum requires a majority: $Q = \lfloor N/2 \rfloor + 1$.
* **kube-scheduler**: The placement engine. It watches for unassigned Pods and binds them to specific nodes based on resource availability, constraints, taints/tolerations, affinity rules, and topology spread.
* **kube-controller-manager**: The orchestration engine. It bundles several distinct controller reconciliation processes into a single binary. Key loops include the Node Controller, Replication Controller, Endpoints Controller, and ServiceAccount Controller.

### The Data Plane (Node Components)

* **kubelet**: The primary node agent. It registers nodes with the API server, watches for assigned Pod specifications via the API server, interfaces with local container runtimes via the **Container Runtime Interface (CRI)** to run containers, and monitors health states.
* **kube-proxy**: The network orchestrator. It runs on each node to maintain network rules, translating logical Service IPs into backend Pod destination IPs using host transport mechanisms like **iptables** or **IPVS**.
* **Container Runtime**: The underlying software engine responsible for executing container images (e.g., `containerd`, `CRI-O`).

---

## 2. API Object Reference Matrix

Every object in Kubernetes represents an intent state that the system persistently reconciles.

### Workload Objects

#### 1. Pods

The smallest atomic deployable unit of computing. A Pod isolates a group of one or more containers that share network namespaces (loopback interface, IP), IPC namespaces, and storage volumes.

* *Key Lifecycle Phases:* `Pending`, `Running`, `Succeeded`, `Failed`, `Unknown`.
* *Probes:* * `startupProbe`: Determines if the application within the container has started. Disables other probes until it succeeds.
* `livenessProbe`: Tracks container health. If it fails, the `kubelet` terminates and restarts the container based on its `restartPolicy`.
* `readinessProbe`: Tracks if the container is ready to accept user traffic. If it fails, the Pod's endpoint is removed from all matching Services.



#### 2. Deployments

Provides declarative, stateless updates for Pods and ReplicaSets. It manages a `ReplicaSet` underneath to maintain the desired number of identical running Pods.

* *Update Strategies:*
* `RollingUpdate`: Replaces old Pods with new ones incrementally. Controlled via `maxSurge` (how many Pods can exist over the desired count) and `maxUnavailable` (how many Pods can be down during the rollout).
* `Recreate`: Kills all existing Pods simultaneously before launching the new target pool. Causes explicit downtime.



#### 3. StatefulSets

Manages the deployment of stateful applications requiring unique, persistent identities.

* *Guarantees:* Stable, unique network identifiers (e.g., `app-0`, `app-1`); stable, persistent storage linked directly via `volumeClaimTemplates`; ordered, graceful deployment and scaling.

#### 4. DaemonSets

Ensures that all (or specific) nodes run a single copy of a Pod.

* *Primary DevOps Use-Cases:* Log collection daemons (e.g., Fluentd, Logstash), infrastructure monitoring metrics agents (e.g., Prometheus Node Exporter), and cluster networking plugins (e.g., Calico, Cilium).

#### 5. Jobs & CronJobs

* **Job**: Creates one or more Pods and ensures that a specified number of them terminate successfully after executing a batch processing task.
* **CronJob**: Schedules Jobs to execute periodically based on a Linux cron format template mapping.

### Configuration Objects

#### 1. ConfigMaps

Stores non-confidential configuration key-value pairs. Can be injected into containers as environment variables, command-line arguments, or mounted as data files via volumes.

#### 2. Secrets

Stores sensitive, confidential data keys (e.g., API tokens, certificates, database credentials). Kept in memory (`tmpfs`) on data nodes and base64 encoded by default. For production security boundaries, enforce encryption-at-rest in `etcd` or integrate external key management vaults (KMS).

---

## 3. Storage Topology & Volume Lifecycle

Kubernetes decouples storage consumption from storage provisioning via an API framework.

```
  +------------------+
  |   StorageClass   | <-- Dynamic Provisioning Profile
  +------------------+
           |
           v
  +------------------+
  | PersistentVolume | <-- Cluster-scoped Physical Storage Resource
  +------------------+
           ^
           | (Bound)
           |
  +-----------------------+
  | PersistentVolumeClaim | <-- Namespace-scoped Storage Request
  +-----------------------+
           ^
           | (Mounted)
           |
  +-----------------------+
  |          Pod          |
  +-----------------------+

```

* **PersistentVolume (PV)**: A cluster-wide storage resource provisioned manually by an administrator or dynamically via a `StorageClass`. It has an explicit lifecycle independent of any individual Pod that consumes it.
* **PersistentVolumeClaim (PVC)**: A user's namespace-scoped request for storage. It specifies size constraints, performance requirements, and access modes. It automatically binds to a matching PV.
* **StorageClass**: Allows dynamic provisioning of storage resources. It defines which volume plugin (provisioner) to call and passes parameter configurations directly to backend cloud providers when a PVC is generated.

### Volume Access Modes

* `ReadWriteOnce (RWO)`: The volume can be mounted as read-write by a single node.
* `ReadOnlyMany (ROX)`: The volume can be mounted as read-only by many nodes simultaneously.
* `ReadWriteMany (RWX)`: The volume can be mounted as read-write by many nodes simultaneously (requires shared filesystems like NFS or AWS EFS).
* `ReadWriteOncePod (RWOP)`: The volume can be mounted as read-write by a single Pod across the entire cluster.

---

## 4. Cluster Networking & Service Topologies

The Kubernetes network model relies on a core constraint: **Every Pod gets its own unique, routable IP address, and Pods can communicate with all other Pods without NAT**, regardless of which node they reside on. This is handled by a **Container Network Interface (CNI)** plugin.

### Service Typs

Services provide stable, abstraction-layer network endpoints to front unstable, ephemeral Pod IP arrays.

* **ClusterIP (Default)**: Exposes the Service on an internal cluster-facing IP. Unreachable outside the cluster boundary.
* **NodePort**: Exposes the Service on each node's IP at a static port flag ranging between `30000-32767`. Automatically routes external traffic to the internal `ClusterIP`.
* **LoadBalancer**: Automates the provisioning of an external load balancer using your cloud provider's API. Automatically hooks into a downstream `NodePort` and `ClusterIP`.
* **ExternalName**: Maps a Kubernetes Service directly to an external DNS CNAME string record (e.g., mapping to an external database endpoint). No proxying occurs.

### Ingress & Network Policies

* **Ingress**: An API object that manages external HTTP/S access routes to internal cluster services. It acts as a reverse proxy and layer-7 load balancer, handled by an Ingress Controller (e.g., Nginx, Envoy).
* **NetworkPolicy**: Pod-scoped firewall rules that operate at layer 3 and 4. By default, Pod networking is non-isolated (accepts traffic from anywhere). Applying a `NetworkPolicy` isolates matching Pods, restricting traffic strictly to whitelisted ingress and egress selectors.

---

## 5. Security Architecture (RBAC & Contexts)

### Role-Based Access Control (RBAC)

RBAC regulates access to cluster resources based on the roles of individual users or system entities within a namespace or across the cluster.

| Scope | API Object | Description |
| --- | --- | --- |
| **Namespace** | `Role` | Defines a set of permissions restricted to a single namespace. |
| **Namespace** | `RoleBinding` | Grants the permissions defined in a `Role` to a user or service account within that namespace. |
| **Cluster** | `ClusterRole` | Defines permissions valid across all namespaces in the cluster, as well as non-namespaced resources (like Nodes). |
| **Cluster** | `ClusterRoleBinding` | Grants cluster-wide permissions to users or service accounts across every namespace. |

### SecurityContexts

Defines privilege and privilege escalation settings for a Pod or individual container.

```yaml
securityContext:
  runAsNonRoot: true             # Prevents containers from executing with UID 0 (root)
  runAsUser: 10001               # Forces container processes to run with an explicit unprivileged user UID
  allowPrivilegeEscalation: false # Disallows child processes from gaining more privileges than the parent
  readOnlyRootFilesystem: true   # Hardens the container runtime by making its root filesystem read-only

```

---

## 6. Advanced Scheduling Controls

* **NodeSelector**: The simplest node-assignment constraint; matches explicit key-value label strings assigned directly to nodes.
* **Affinity & Anti-Affinity**: Extends scheduling capabilities using expressive logical matching.
* *NodeAffinity:* Hard (`requiredDuringSchedulingIgnoredDuringExecution`) or soft (`preferredDuringSchedulingIgnoredDuringExecution`) rules forcing Pods onto specific nodes.
* *PodAffinity / Anti-Affinity:* Co-locate Pods on the same topology zone or prevent them from scheduling together (e.g., ensuring replicas of the same app run on different availability zones for high availability).


* **Taints & Tolerations**: Allows nodes to repel a set of Pods.
* A **Taint** is applied to a Node (`kubectl taint nodes node1 key=value:NoSchedule`).
* A Pod must have an explicit **Toleration** defined in its spec to be scheduled on that tainted node.


* **Topology Spread Constraints**: Controls how Pods are distributed across failure domains (zones, regions, nodes) to achieve high availability and even resource utilization.

---

## 7. The Ultimate `kubectl` Operations Command Matrix

### Context & Configuration Sifting

```bash
kubectl cluster-info                           # Output network validation mapping endpoints
kubectl config view                            # Print active aggregated kubeconfig parameters
kubectl config get-contexts                    # List all available infrastructure contexts
kubectl config current-context                 # Isolate the name of the active operating target context
kubectl config use-context <CONTEXT_NAME>      # Shift the current operational focus to an alternate cluster
kubectl config set-context --current --namespace=prod # Shift the default execution namespace target

```

### Imperative Creation & Generation

```bash
# Generate a deployment manifest file on-the-fly without creating the resource
kubectl create deployment api-gateway --image=nginx:alpine --dry-run=client -o yaml > deploy.yaml

# Create a cluster service manifest file targeting exposed ports
kubectl expose deployment api-gateway --port=80 --target-port=8080 --type=ClusterIP --dry-run=client -o yaml > svc.yaml

```

### Deep Resource Diagnostics & Triage

```bash
# Isolate specific namespace objects tracking active resource footprints
kubectl get pods -n production -o wide        # Detailed listing displaying backend hosting Node IPs
kubectl describe pod <POD_NAME> -n production # View internal lifecycle event streams and configuration parameters

# Resource Sorting Metrics
kubectl get pods --sort-by='.metadata.creationTimestamp' # Trace aging Pod execution entities
kubectl get pv --sort-by='.spec.capacity.storage'       # Sort persistent volumes by storage allocation size

```

### Advanced Data Extraction via JSONPath

```bash
# Extract the exact internal IP mappings for all running nodes in the cluster context
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'

# Extract the names of all non-running pods inside a target namespace context
kubectl get pods -n prod --field-selector=status.phase!=Running -o jsonpath='{.items[*].metadata.name}'

```

### Production Troubleshooting & Live Logging

```bash
# Interactively stream real-time logging records from multi-container pods
kubectl logs -f <POD_NAME> -c app-container -n prod --tail=100 --timestamps

# View logging statements from the previously terminated instance of a crashed container
kubectl logs <POD_NAME> -c app-container -p -n prod

# Inject an interactive troubleshooting container into an existing Pod network namespace for deep network debugging
kubectl debug -it <POD_NAME> --image=busybox --target=app-container -n prod

# Trigger a rolling update restart across an enterprise deployment strategy layout
kubectl rollout restart deployment/api-gateway -n prod
kubectl rollout status deployment/api-gateway -n prod

```

---

## 8. Critical Interview Revision Summary

| Triage Scenario | Primary Command / Object Strategy | Reason for Choice |
| --- | --- | --- |
| **Pod stuck in `CrashLoopBackOff**` | `kubectl logs <pod> --previous` / `kubectl describe pod` | Inspects application error codes or detects failed liveness probes. |
| **Pod stuck in `Pending**` | `kubectl describe pod <pod>` | Identifies scheduling blocks such as resource starvation, node selectors, or missing taints/tolerations. |
| **Service unreachable via DNS** | Check `endpoints` (`kubectl get ep`) / Verify `readinessProbe` | If readiness probes fail, the endpoint controller removes the Pod IP from the Service target layout. |
| **Stateful storage alignment** | `StatefulSet` + `volumeClaimTemplates` | Guarantees that as a stateful application scales, each Pod is dynamically mapped to its own persistent volume. |
| **Secure container configurations** | `securityContext` + `NetworkPolicy` | Enforces non-root runtime boundaries and blocks unauthorized lateral network traffic inside the cluster mesh. |