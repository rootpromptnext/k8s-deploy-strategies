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
    │   │   ├── v1.yaml
    │   │   ├── v2.yaml
    │   │   └── demo-ingress.yaml
    |   |   |__ canary-ingress.yaml
    └── README.md

## Install MicroK8s Manually

```bash
# Install MicroK8s
sudo snap install microk8s --classic

# Wait until MicroK8s is ready
microk8s status --wait-ready

# Refresh group membership
newgrp microk8s

# Verify status
microk8s status

# Create kubectl alias
sudo snap alias microk8s.kubectl kubectl

# Check cluster nodes
kubectl get nodes

# Enable DNS, storage, and ingress
microk8s enable dns storage
microk8s enable ingress
```

## Expose Ingress via NodePort

By default, MicroK8s ingress doesn’t create a Service. Add one manually:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress-microk8s-controller
  namespace: ingress
spec:
  type: NodePort
  selector:
    name: nginx-ingress-microk8s
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
```

Apply it:

```bash
kubectl apply -f ingress-service.yaml
kubectl -n ingress get all
```

Find your node IP:

```bash
hostname -I
ip a
```

For local testing, add an entry in `/etc/hosts`:

```bash
echo "10.10.0.2 demo.local" | sudo tee -a /etc/hosts
```


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
kubectl apply -f manifests/blue-green/green.yaml
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
kubectl get svc echo -o yaml | grep selector -a5
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

### Deploy Applications
Apply the manifests (`v1.yaml`, `v2.yaml`, `demo-ingress.yaml`, `canary-ingress.yaml`).  

```bash
kubectl apply -f manifests/
```

## Test Canary Deployment

```bash
curl http://demo.local:30080
```

You should see:
- **Hello from v1** most of the time (production).  
- **Hello from v2** about 20% of the time (canary).

## Output for reference
```
prayag@devops-vm:~/k8s-deploy-strategies/manifests/canary$ while true; do curl --max-time 1 demo.local ; sleep 1; done
Hello from v1
Hello from v1
Hello from v2
Hello from v2
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v2
Hello from v2
Hello from v1
Hello from v1
Hello from v1
Hello from v1
Hello from v1
^C
prayag@devops-vm:~/k8s-deploy-strategies/manifests/canary$

```

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
