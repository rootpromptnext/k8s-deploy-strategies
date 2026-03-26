Here you go — a **clean repo name recommendation** + a **full production‑quality `README.md`** for your MicroK8s deployment‑strategies lab.

***

# ✅ Recommended Repository Name

Here are strong, clear, GitHub‑friendly repo names (pick one):

### ✅ **k8s-deployment-strategies-microk8s-lab** ← **BEST**

Clear + specific + searchable.

Other valid options:

*   **microk8s-deployment-strategies**
*   **k8s-deployments-hands-on-lab**
*   **kubernetes-strategies-echo-server**
*   **k8s-blue-green-canary-rolling-recreate**

If you want simplicity:

✅ `k8s-deploy-strategies-lab`  
✅ `microk8s-deploy-lab`

**Tell me which one to finalize**, or I can embed it directly into the README.

For now, I'll generate the README using:

✅ **k8s-deployment-strategies-microk8s-lab**

***

# ✅ README.md (Full Production‑Grade)

Below is your `README.md` — ready to commit to GitHub:

***

# **Kubernetes Deployment Strategies Lab (MicroK8s)**

### *Recreate • Rolling Update • Blue‑Green • Canary*

### *Using echo-server + internal curl testing pod*

This repository contains a **complete hands‑on Kubernetes lab** demonstrating **four deployment strategies** using **MicroK8s**, the lightweight CNCF-certified Kubernetes distribution from Canonical.

✅ Designed for **local clusters (MicroK8s)**  
✅ Uses **ClusterIP services** (no NodePort / no port-forward)  
✅ Testing done via an **internal curl test pod**  
✅ Includes **health probes**  
✅ Covers **Recreate, Rolling, Blue‑Green, Canary**  
✅ All manifests generated using `mkdir -p` + `cat <<EOF`  
✅ Perfect for learning, demos, workshops, interviews

***

# ��� Repository Structure

    k8s-deployment-strategies-microk8s-lab/
    ├── manifests/
    │   ├── service.yaml
    │   ├── test-pod.yaml
    │   ├── recreate/
    │   │   └── recreate.yaml
    │   ├── rolling/
    │   │   └── rolling.yaml
    │   ├── blue-green/
    │   │   ├── blue.yaml
    │   │   ├── green.yaml
    │   │   └── switch-to-green.sh
    │   ├── canary/
    │   │   ├── stable.yaml
    │   │   ├── canary.yaml
    │   │   └── scale-canary.sh
    ├── scripts/
    │   ├── deploy-all.sh
    │   ├── test-recreate.sh
    │   ├── test-rolling.sh
    │   ├── test-blue-green.sh
    │   └── test-canary.sh
    └── README.md

***

# ✅ 1. MicroK8s Setup

Enable essential addons:

```sh
sudo microk8s enable dns storage ingress
```

(Optional)

```sh
sudo microk8s enable dashboard
```

Alias for convenience:

```sh
alias kubectl="microk8s kubectl"
```

***

# ✅ 2. Deploy Common Components

## ✅ ClusterIP Service

Used by all strategies.

    manifests/service.yaml

## ✅ curl Test Pod

This pod is used to test all deployments from **inside the cluster**.

    manifests/test-pod.yaml

Create test pod:

```sh
kubectl apply -f manifests/test-pod.yaml
kubectl wait pod curl-tester --for=condition=Ready
```

Enter the pod:

```sh
kubectl exec -it curl-tester -- sh
```

***

# ✅ 3. Deployment Strategies

***

## ✅ A) Recreate Deployment

��� `manifests/recreate/recreate.yaml`  
Strategy:

*   Deletes **all old pods first**
*   Then starts **new version**
*   Causes **downtime**

Update image:

```sh
kubectl set image deployment/echo-recreate echo=ealen/echo-server:0.2
```

### ��� Test (from inside curl pod)

```sh
while true; do curl -s http://echo | jq '.hostname'; sleep 1; done
```

✅ Expect timeouts → downtime is part of Recreate.

***

## ✅ B) Rolling Update Deployment

��� `manifests/rolling/rolling.yaml`  
Strategy:

*   Zero downtime
*   Gradual pod replacement
*   Controlled surge/unavailable pods

Update:

```sh
kubectl set image deployment/echo-rolling echo=ealen/echo-server:0.2
kubectl rollout status deployment/echo-rolling
```

### ��� Test

```sh
while true; do curl -s http://echo | jq '.hostname'; sleep 1; done
```

✅ Expect interleaved pods during rollout.

***

## ✅ C) Blue‑Green Deployment

��� `manifests/blue-green/blue.yaml`  
��� `manifests/blue-green/green.yaml`  
��� `manifests/blue-green/switch-to-green.sh`

Strategy:

*   Run **Blue** and **Green** simultaneously
*   Service switches between them instantly
*   Zero downtime + easy rollback

Switch traffic:

```sh
./manifests/blue-green/switch-to-green.sh
```

### ��� Test

Before switch → Blue  
After switch → Green

```sh
curl -s http://echo | jq '.hostname'
```

✅ Traffic transition is instantaneous.

***

## ✅ D) Canary Deployment

��� `manifests/canary/stable.yaml`  
��� `manifests/canary/canary.yaml`

Strategy:

*   Send small % of traffic to canary
*   Observe behavior before full rollout

Traffic ratio:

*   3 stable pods → 75%
*   1 canary pod → 25%

### ��� Test

```sh
while true; do curl -s http://echo | jq '.hostname'; sleep 1; done
```

✅ You will see occasional canary responses.

***

# ✅ 4. Health Probes

Each deployment uses:

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 2

livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
```

✅ Ensures robust rollouts  
✅ Prevents routing traffic to unready pods

***

# ✅ 5. Cleanup

```sh
kubectl delete -f manifests/
```

***

# ✅ 6. Summary

This lab demonstrates **production-grade Kubernetes rollout patterns** using a lightweight MicroK8s cluster with internal service testing.

✅ Recreate → Simple but downtime  
✅ Rolling → Standard zero-downtime deployment  
✅ Blue‑Green → Safest and easiest rollback  
✅ Canary → Safest incremental rollout for real traffic

***

# ✅ Want diagrams?

I can generate:

✅ PNG  
✅ SVG  
✅ ASCII  
✅ Mermaid diagrams (GitHub renders this!)

Example formats:

*   Architecture diagrams
*   Traffic flow diagrams
*   Rollout lifecycle diagrams

Just tell me: **“Add diagrams”**.

***

If you want, I can also generate:

✅ GitHub Actions CI  
✅ Helm charts  
✅ Kustomize overlays  
✅ A single `make all` workflow

Just say the word!
