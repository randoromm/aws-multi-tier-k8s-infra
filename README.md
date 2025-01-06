# aws-multi-tier-k8s-infra
Infrastructure as Code (IaC) setup for a scalable, multi-tier application on AWS using Terraform and Kubernetes (EKS). Includes VPC, RDS PostgreSQL, and Kubernetes manifests for frontend and backend services.

## Modules used:
* https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest

## Diagram
![devops-task-diagram](https://github.com/user-attachments/assets/da45dfcc-c281-4824-8e9f-3425d9943a02)

Unfortunately i was a little too optimistic with deadline offering and had very little time to learn and implement it fully how i intended.

## Tier 1 - Public subnets, gateways, load-balancing

## Tier 2 - Private subnets - EKS Cluster

## Tier 3 - Database instance (RDS PostgreSQL)

## Improvements:
* Add ALB Application Load Management - Researched the ways to add it.
* Bastion or similar to securely offer access to users for tier 2 and tier 3.
* Horizontal Auto-scaling could be fully implemented and improved.
* Automatic database updates
* Automatic etcd backup and external volume management
* Add metrics
  * Container/Node CPU/MEM limits, loads
  * HTTP Request error counts
  * Worker node disk free percentage
  * Thread count per service
  * Availability checks for cluster/worker nodes/services
  * Libraries for microservices to provide more relevant metrics (development)
  * etc..

## CI/CD Implementation suggestions
There are many ways to design a CI/CD process, but here are my preferances:
Release branching strategy should be follow something similar to GitFlow principles. This should be similar for both infra and micro services:
![image](https://github.com/user-attachments/assets/c2aec0b5-34ab-4acd-aad9-a4f3a895ce79)
Jenkins/GitHub actions can be connected to Terraform Enterprise to and update images in ECR (container registry) and deploy.

Also i've heard great feedback on ArgoCD. ArgoCD could be seperately used to upgrade the micro services if the helm charts/manifests have been updated.

