---
name: ecc-kubernetes-patterns
description: "Use when writing or reviewing Kubernetes manifests, or debugging probes, RBAC, autoscaling, or resource limits."
license: MIT
metadata:
  origin: ECC
  source: https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/kubernetes-patterns/SKILL.md
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Infrastructure and Data
  summary: "ECC reference for kubernetes patterns; adapted for explicit local scope and evidence-backed use."
---

# Kubernetes Patterns — ECC Import

Attributed third-party ECC import, not a behaviorally benchmarked authored skill or production certification. Original copyright and MIT terms are in `LICENSE`.

## Scope and Authority

Apply only to the requested review, explanation, plan, or explicitly authorized local edit. A read-only persona stays read-only even when a code example describes a mutation.

Preserve governing project contracts, explicit task scope, and user-reported failures as evidence. Do not rerun a reported failure merely to challenge it. Keep diagnostics visible; never suppress errors or lower existing acceptance gates. Loading this reference does not authorize production access, network/device/database operations, administration, migrations, publishing, paid model calls, training, package installation, global cache/reset/git actions, telemetry, or session learning. Examples are reference material, not an execution checklist. Request redacted operator-provided evidence for external systems. Do not invoke another persona or require mandatory peer chains; optional references never expand authority.

Use supported tools by role: file reader, scoped search, and language-server navigation when available. Do not assume a particular harness command, installed dependency, application module, or current third-party API version. Project-specific filenames, credentials, images, endpoints, and application imports in examples are caller-supplied integration points, not missing bundled assets. Retain all project validation contracts; numerical budgets in examples are illustrative unless the caller adopts them.

# Kubernetes Patterns

Kubernetes workload and review patterns. Adapt every manifest to the installed Kubernetes version, controllers, application endpoints, policy, and workload evidence; these templates are not production certification.

## When to Activate

- Writing Kubernetes manifests (Deployments, Services, Ingress, Jobs)
- Configuring resource requests/limits, liveness/readiness probes
- Setting up RBAC, namespaces, or ServiceAccounts
- Managing configuration and secrets in K8s
- Debugging CrashLoopBackOff, OOMKilled, pending pods, or image pull errors
- Configuring HPA (Horizontal Pod Autoscaler) or PodDisruptionBudgets
- Reviewing K8s YAML for security or correctness



## How It Works

Use the YAML fragments as review references and the kubectl list as targeted requests for operator-provided evidence, not an automatic deployment or diagnostics sequence:

1. **Deployment template** — An illustrative `Deployment` with security context, rolling update strategy, all three probe types, resource limits, and environment injection from ConfigMap/Secret.
2. **Probes** — Decision table for startup vs liveness vs readiness, with correct `failureThreshold × periodSeconds` math.
3. **Services & Ingress** — ClusterIP, LoadBalancer, and TLS Ingress patterns with cert-manager annotations.
4. **ConfigMaps & Secrets** — `envFrom`, file-mount, and external secrets guidance.
5. **Resource management** — Requests vs limits rules of thumb by workload type (web API, JVM, worker, sidecar).
6. **RBAC** — Least-privilege ServiceAccount → Role → RoleBinding chain.
7. **HPA & PDB** — Autoscaling and node-drain safety configurations.
8. **Jobs & CronJobs** — One-off and scheduled workload patterns with correct `restartPolicy`.
9. **kubectl cheatsheet** — Logs, exec, rollback, port-forward, dry-run, and common error diagnosis commands.
10. **Anti-patterns & checklist** — What NOT to do, and a security/reliability/observability checklist.

## Examples

See the sections below for templates; application images, namespaces, health endpoints, TLS issuers, and secrets are explicit caller-supplied prerequisites, not included dependencies. Quick references:

| Task | Jump to |
|------|---------|
| Full production Deployment YAML | [Core Workload Patterns](#core-workload-patterns) |
| Probe configuration | [Probes](#probes--liveness-readiness-startup) |
| RBAC least-privilege setup | [RBAC](#rbac--roles-and-serviceaccounts) |
| Debug a CrashLoopBackOff | [kubectl Debugging Cheatsheet](#kubectl-debugging-cheatsheet) |
| Autoscaling | [HPA](#horizontal-pod-autoscaler-hpa) |

---

## Core Workload Patterns

### Deployment — Workload-Dependent Template

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: my-namespace
  labels:
    app: my-app
    version: "1.0.0"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # Allow 1 extra pod during update
      maxUnavailable: 0    # Never reduce below desired count
  template:
    metadata:
      labels:
        app: my-app
        version: "1.0.0"
    spec:
      automountServiceAccountToken: false
      # Security context at pod level
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001

      # Graceful shutdown
      terminationGracePeriodSeconds: 30

      containers:
        - name: my-app
          image: ghcr.io/org/my-app:1.0.0   # Never use :latest
          imagePullPolicy: IfNotPresent

          ports:
            - containerPort: 8080
              protocol: TCP

          # Size requests and memory limit from measurements; evaluate CPU-limit throttling.
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"

          # Container security context
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL

          # Probes (see Probes section below)
          startupProbe:
            httpGet:
              path: /health
              port: 8080
            failureThreshold: 30
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 0
            periodSeconds: 30
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
            failureThreshold: 2

          # Environment from ConfigMap and Secret
          envFrom:
            - configMapRef:
                name: my-app-config
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: my-app-secrets
                  key: db-password

          # Writable tmp directory when readOnlyRootFilesystem: true
          volumeMounts:
            - name: tmp
              mountPath: /tmp

      volumes:
        - name: tmp
          emptyDir: {}
```

---

## Probes — Liveness, Readiness, Startup

Understanding when to use each probe is critical:

| Probe | Failure Action | Use For |
|-------|---------------|---------|
| `startupProbe` | Kills container if slow to start | Slow-starting apps (JVM, Python) |
| `livenessProbe` | Restarts container | Deadlock / hung process detection |
| `readinessProbe` | Removes from Service endpoints | Temporary unavailability (DB reconnect) |

```yaml
# Correct pattern: startupProbe covers slow startup,
# then liveness/readiness take over
startupProbe:
  httpGet:
    path: /health
    port: 8080
  failureThreshold: 30  # Nominal budget about 150s; actual timing also includes scheduling/timeouts.
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 30
  failureThreshold: 3   # Nominal detection interval about 90s; not an exact restart deadline.

readinessProbe:
  httpGet:
    path: /ready         # Separate endpoint: checks DB, cache, etc.
    port: 8080
  periodSeconds: 10
  failureThreshold: 2
```

```yaml
# Less flexible for variable startup time: initialDelaySeconds without startupProbe
# If the app takes 60s to start, set a startupProbe instead
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 60   # May be valid for a known startup profile; prefer measured startupProbe budget.
```

---

## Services and Ingress

### Service Types

```yaml
# ClusterIP (default) — internal-only
apiVersion: v1
kind: Service
metadata:
  name: my-app
  namespace: my-namespace
spec:
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
  type: ClusterIP
```

```yaml
# LoadBalancer — external traffic (cloud providers)
spec:
  type: LoadBalancer
  ports:
    - port: 443
      targetPort: 8080
```

### Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  namespace: my-namespace
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - myapp.example.com
      secretName: my-app-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-app
                port:
                  number: 80
```

---

## ConfigMaps and Secrets

### ConfigMap — Non-sensitive configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
  namespace: my-namespace
data:
  LOG_LEVEL: "info"
  APP_ENV: "production"
  MAX_CONNECTIONS: "100"
  # Mount as a file for complex config
  app.yaml: |
    server:
      port: 8080
      timeout: 30s
```

```yaml
# Mount ConfigMap as a file
volumes:
  - name: config
    configMap:
      name: my-app-config
      items:
        - key: app.yaml
          path: app.yaml
volumeMounts:
  - name: config
    mountPath: /etc/app
    readOnly: true
```

### Secrets — Sensitive data

Review secret provisioning through the approved secret-management path; do not place real values in command-line arguments, manifests, or review output.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
  namespace: my-namespace
type: Opaque
# Example shape only. The approved secret provider supplies the actual value.
stringData:
  db-password: "<provided outside version control>"
```

Base64 encoding is not encryption. Review Kubernetes encryption-at-rest, RBAC, access auditing, and backup policy. Sealed Secrets encrypts a Git-storable resource; External Secrets Operator synchronizes a secret store but does not by itself configure encryption of Kubernetes Secrets at rest.

---

## Resource Requests and Limits

```yaml
resources:
  requests:       # Scheduler uses this to place the pod
    cpu: "100m"   # 100 millicores = 0.1 CPU
    memory: "128Mi"
  limits:         # Container is killed/throttled above this
    cpu: "500m"
    memory: "256Mi"
```

**Rules of thumb:**

| Workload Type | CPU Request | Memory Request | Notes |
|---------------|-------------|----------------|-------|
| Web API | 100–250m | 128–256Mi | Illustrative starting range; measure bursts and CPU throttling |
| Worker/consumer | 250–500m | 256–512Mi | Memory limit = request for predictability |
| JVM app | 500m–1 | 512Mi–2Gi | Allow headroom above `-Xmx` for JVM overhead |
| Sidecar | 10–50m | 32–64Mi | Keep minimal |

```yaml
# WRONG: No requests or limits — unpredictable scheduling, OOM evictions
containers:
  - name: app
    image: myapp:latest
    # Missing resources: {} — this is dangerous in production

# WRONG: Limits without requests — requests default to limits, over-reserves capacity
resources:
  limits:
    cpu: "2"
    memory: "1Gi"
  # requests missing — will default to limits values
```

---

## RBAC — Roles and ServiceAccounts

### Principle of Least Privilege

**Two patterns depending on whether the app calls the Kubernetes API:**

#### Pattern A — App does NOT need the Kubernetes API (most apps)

Disable token automounting on the ServiceAccount. The Role/RoleBinding are not needed.

```yaml
# ServiceAccount with token disabled — safest default
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: my-namespace
automountServiceAccountToken: false   # No K8s API token injected into pods
```

```yaml
# Reference in Deployment — no token, no API access
spec:
  template:
    spec:
      serviceAccountName: my-app-sa
      automountServiceAccountToken: false   # Belt-and-suspenders: also set at pod level
```

#### Pattern B — App DOES need the Kubernetes API (operators, controllers, config watchers)

Enable the token and grant only the permissions actually required.

```yaml
# 1. ServiceAccount — enable token for this SA
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-sa
  namespace: my-namespace
automountServiceAccountToken: true    # Token required: app calls K8s API
```

```yaml
# 2. Role — grant only what the app needs (namespace-scoped)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: my-app-role
  namespace: my-namespace
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]    # Read-only, specific resource
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["my-app-secrets"]  # Restrict to specific secret by name
    verbs: ["get"]
```

```yaml
# 3. Bind Role to ServiceAccount
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: my-app-rolebinding
  namespace: my-namespace
subjects:
  - kind: ServiceAccount
    name: my-app-sa
    namespace: my-namespace
roleRef:
  kind: Role
  apiGroup: rbac.authorization.k8s.io
  name: my-app-role
```

```yaml
# 4. Reference SA in Deployment
spec:
  template:
    spec:
      serviceAccountName: my-app-sa
      # automountServiceAccountToken defaults to true from SA — token is injected
```

---

## Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
  namespace: my-namespace
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2      # Example; placement, dependencies and disruption policy also determine availability.
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70    # Scale up when avg CPU > 70%
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

> HPA requires `resources.requests` to be set on all containers — it calculates utilization as `current / request`.

---

## PodDisruptionBudget (PDB)

Limit voluntary evictions such as node drains. A PDB does not prevent involuntary failures and does not constrain the rolling-update strategy of a Deployment controller. Coordinate PDB values with HPA minimum replicas; `minAvailable: 2` with two replicas can block voluntary drain.

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
  namespace: my-namespace
spec:
  minAvailable: 2           # OR use maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

---

## Namespaces and Multi-Tenancy

```yaml
# Candidate manifest only. Namespace creation and application require separate operator authorization.
apiVersion: v1
kind: ResourceQuota
metadata:
  name: my-namespace-quota
  namespace: my-namespace
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
    pods: "20"
```

---

## Jobs and CronJobs

```yaml
# One-off Job template; deliberately does not run a database migration.
apiVersion: batch/v1
kind: Job
metadata:
  name: report-time
  namespace: my-namespace
spec:
  backoffLimit: 3          # Retry up to 3 times on failure
  ttlSecondsAfterFinished: 3600   # Auto-delete after 1h
  template:
    spec:
      restartPolicy: OnFailure    # Jobs support OnFailure or Never, not Always.
      containers:
        - name: report
          image: busybox:1.36.1
          command: ["date", "-u"]
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
```

```yaml
# CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: time-report-job
  namespace: my-namespace
spec:
  schedule: "0 2 * * *"         # 2am daily
  concurrencyPolicy: Forbid      # Don't run if previous still running
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: report
              image: busybox:1.36.1
              command: ["date", "-u"]
              resources:
                requests:
                  cpu: "50m"
                  memory: "64Mi"
```

---

## kubectl Evidence Reference

Request only the redacted operator output that can resolve a finding. Do not connect to a cluster, open a pod shell, port-forward, scale, roll back, or apply manifests as a consequence of loading this skill. Even a server-side dry run contacts admission services; it is not an offline check.

```text
kubectl get pods -n <namespace> -o wide
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
kubectl top pods -n <namespace>
kubectl rollout status deployment/<name> -n <namespace>
kubectl rollout history deployment/<name> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

Remote remediation belongs in a caller-approved, context-pinned maintenance plan with a rollback record; it is not a diagnostic command.

### Diagnosing Common Errors

```bash
# CrashLoopBackOff: container keeps crashing
kubectl logs <pod-name> --previous -n my-namespace  # Check crash logs
kubectl describe pod <pod-name> -n my-namespace     # Check exit code & OOMKilled

# ImagePullBackOff: can't pull image
kubectl describe pod <pod-name> -n my-namespace     # Check Events section
# Causes: wrong image tag, missing imagePullSecret, private registry

# Pending pod: not scheduled
kubectl describe pod <pod-name> -n my-namespace
# Causes: insufficient resources, no matching node selector, taint/toleration mismatch

# OOMKilled: out of memory
# Increase memory limits, check for memory leaks
kubectl describe pod <pod-name> -n my-namespace | grep -A5 "Last State"
```

---

## Anti-Patterns

```yaml
# BAD: Using :latest tag — non-deterministic deployments
image: myapp:latest

# GOOD: Pin an approved digest for immutability; semver tags alone remain mutable.
image: ghcr.io/org/myapp:1.4.2
# or
image: ghcr.io/org/myapp@sha256:abc123...

# ---

# BAD: Running as root
securityContext: {}    # Uses image/default identity; may run as root.

# GOOD: Non-root with explicit UID
securityContext:
  runAsNonRoot: true
  runAsUser: 1001

# ---

# BAD: No resource limits — one pod can starve the entire node
containers:
  - name: app
    image: myapp:1.0.0
    # No resources defined

# GOOD: Set measured requests and memory limits; choose CPU-limit policy deliberately.
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"

# ---

# BAD: Storing plaintext secrets in ConfigMaps
apiVersion: v1
kind: ConfigMap
data:
  DB_PASSWORD: "mysecretpassword"   # NEVER — use Secret or external secrets manager

# ---

# BAD: ClusterAdmin for application service accounts
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
roleRef:
  kind: ClusterRole
  name: cluster-admin    # Grants god-mode to your app

# ---

# BAD: minAvailable: 0 in PDB — defeats the purpose
spec:
  minAvailable: 0

# ---

# BAD: restartPolicy: Always in a Job (invalid Job specification)
spec:
  restartPolicy: Always   # Use OnFailure or Never for Jobs
```

---

## Best Practices Checklist

### Security
- [ ] Container runs as non-root (`runAsNonRoot: true`, `runAsUser` set)
- [ ] `readOnlyRootFilesystem: true` with `emptyDir` for writable paths
- [ ] `allowPrivilegeEscalation: false`
- [ ] All capabilities dropped (`capabilities.drop: [ALL]`)
- [ ] Dedicated ServiceAccount per app, not `default`
- [ ] `automountServiceAccountToken: false` unless needed
- [ ] RBAC follows least privilege (use `Role`, not `ClusterRole` unless needed)
- [ ] Secrets managed via Sealed Secrets or External Secrets Operator

### Reliability
- [ ] Probes match actual startup, traffic-readiness, and deadlock behavior; liveness does not fail merely because a shared dependency is down
- [ ] Requests, memory limits, and CPU throttling policy are workload-justified
- [ ] Replica count, failure-domain spread, and HPA/PDB interaction meet the declared availability objective
- [ ] PodDisruptionBudget defined for stateful or critical services
- [ ] `RollingUpdate` strategy with `maxUnavailable: 0`
- [ ] HPA configured for variable-load services

### Observability
- [ ] App exposes `/health` (liveness) and `/ready` (readiness) endpoints
- [ ] Structured JSON logging (no PII in logs)
- [ ] Resource labels: `app`, `version`, `environment`

---

## Optional Related Guidance

- `ecc-docker-patterns` (optional skill; if unavailable, inspect image stages, least privilege, network exposure, and persistent volumes).
- For deployment planning without another skill, inspect rollout health gates, previous images, traffic switching, least privilege, and rollback access.
- For GitOps, review the repository-controller contract and drift behavior; do not publish or mutate a cluster.


