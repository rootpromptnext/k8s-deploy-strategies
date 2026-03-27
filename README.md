# **Kubernetes Deployment Strategies Lab (MicroK8s)**

### *Recreate • Rolling Update • Blue‑Green • Canary*

### *Using echo-server + internal curl testing pod*

This repository contains a **complete hands‑on Kubernetes lab** demonstrating **four deployment strategies** using **MicroK8s**, the lightweight CNCF-certified Kubernetes distribution from Canonical.

Designed for **local clusters (MicroK8s)**  
Uses **ClusterIP services** 
Testing done via an **internal curl test pod**  
Includes **health probes**  
Covers **Recreate, Rolling, Blue‑Green, Canary**  

# Repository Structure

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

# Deploy Common Components

## ClusterIP Service

Used by all strategies.

    manifests/service.yaml

## curl Test Pod

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
# Deployment Strategies

## A) Recreate Deployment

### Initial v1

`kubectl apply -f manifests/recreate/recreate-v1.yaml`  

### Test

```sh
kubectl exec -it curl-tester -- sh
curl -s http://echo
```

Strategy:

*   Deletes **all old pods first**
*   Then starts **new version**
*   Causes **downtime**

### Update to v2:

`kubectl apply -f manifests/recreate/recreate-v2.yaml`  

### Test (from inside curl pod)

```sh
kubectl exec -it curl-tester -- sh
curl -s http://echo
while true; do curl --max-time 1 http://echo ; sleep 1; done
```

Expect timeouts → downtime is part of Recreate.

### Sample timeout output

```sh
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
curl: (7) Failed to connect to echo port 80 after 3 ms: Could not connect to server
curl: (28) Connection timed out after 1002 milliseconds
curl: (7) Failed to connect to echo port 80 after 2 ms: Could not connect to server
curl: (7) Failed to connect to echo port 80 after 1 ms: Could not connect to server
Hello from v2
Hello from v2
Hello from v2
Hello from v2
Hello from v2
Hello from v2
```

## B) Rolling Update Deployment

### Initial v1

`kubectl apply -f manifests/recreate/recreate-v1.yaml`  

### Test

```sh
kubectl exec -it curl-tester -- sh
curl -s http://echo
```

Strategy:

*   Zero downtime
*   Gradual pod replacement
*   Controlled surge/unavailable pods

### Update to v2:

`kubectl apply -f manifests/recreate/recreate-v2.yaml`  

### Test (from inside curl pod)

```sh
kubectl exec -it curl-tester -- sh
curl -s http://echo
while true; do curl --max-time 1 http://echo ; sleep 1; done
```

Expect interleaved pods during rollout.

We see no downtime

```sh
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v2
Hello from v2
Hello from v2
Hello from v2
Hello from v2
Hello from v2
Hello from v2
```

## C) Blue‑Green Deployment

### Initial apply blue

```sh
kubectl apply -f manifests/blue-green/blue.yaml
kubectl apply -f service.yaml
```

### Test

```sh
kubectl exec -it curl-tester -- sh
curl -s http://echo
```
Strategy:

*   Run **Blue** and **Green** simultaneously
*   Service switches between them instantly
*   Zero downtime + easy rollback

### apply green

```sh
kubectl apply -f manifests/recreate/green.yaml
```

Switch traffic:

```sh
./manifests/blue-green/switch-to-green.sh
```

### Test (from inside curl pod)

Before switch → Blue  
After switch → Green

```sh
kubectl exec -it curl-tester -- sh
curl -s http://echo
while true; do curl --max-time 1 http://echo ; sleep 1; done
```

Traffic transition is instantaneous.

### Check pods
```sh
kubectl get pods -l version=blue -o wide
```
### Check service
```sh
kubectl get svc echo -o yaml | grep selector -A
```
### Sample output

```sh
Hello from BLUE
Hello from BLUE
Hello from BLUE
Hello from BLUE
Hello from BLUE
Hello from GREEN
Hello from GREEN
Hello from GREEN
Hello from GREEN
Hello from GREEN
Hello from GREEN
```

***

## D) Canary Deployment

`manifests/canary/stable.yaml`  
`manifests/canary/canary.yaml`

Strategy:

*   Send small % of traffic to canary
*   Observe behavior before full rollout

Traffic ratio:

*   3 stable pods → 75%
*   1 canary pod → 25%

### Test

```sh
while true; do curl -s http://echo | jq '.hostname'; sleep 1; done
```

You will see occasional canary responses.

# Health Probes

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

Ensures robust rollouts  
Prevents routing traffic to unready pods

# Cleanup

```sh
kubectl delete -f manifests/
```
