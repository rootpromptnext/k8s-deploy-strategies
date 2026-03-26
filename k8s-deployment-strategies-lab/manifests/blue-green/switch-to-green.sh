#!/bin/bash
kubectl patch svc echo -p '{"spec":{"selector":{"app":"echo","version":"green"}}}'
