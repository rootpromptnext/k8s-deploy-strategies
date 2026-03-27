#!/bin/bash

echo "Switching traffic to GREEN..."
kubectl patch service echo -p '{"spec": {"selector": {"app": "echo", "version": "green"}}}'

echo "Traffic switched to GREEN"
kubectl get svc echo -o wide
