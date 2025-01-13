# AWS Multi-Tier Kubernetes Infrastructure

This project demonstrates the deployment of a scalable, multi-tier application on AWS using Terraform and Kubernetes (EKS). It sets up a Virtual Private Cloud (VPC), an Elastic Kubernetes Service (EKS) cluster, an RDS PostgreSQL database, and includes Kubernetes manifests (using Kustomize) for frontend and backend services.

## Modules used:
* https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest

## Diagram
![devops-task-zendesk drawio (2)](https://github.com/user-attachments/assets/0d9faf79-5775-44a2-b51d-9d7d4f5b2c8e)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.20
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials

## Setup Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/randoromm/aws-multi-tier-k8s-infra.git
   cd aws-multi-tier-k8s-infra
   ```
2. 

## Tier 1 - Public subnets, gateways, load-balancing
First tier contains of 2 public subnets in separate availability zones for high availability.
Public subnets host the gateways and load balancers to provide a secure way of handling the traffic.
Public subnets are exposed to the internet, meaning the rest of the tiers (EKS cluster, database) are secured from the external access.

## Tier 2 - Private subnets - EKS Cluster
EKS cluster includes the application instances and cluster worker nodes. They are hosted in two private subnets.
To further improve this access to this layer should be better managed with for example Bastion to deny public access to this layer and better monitor the access.
Currently the access is limited via IAM Roles.

## Tier 3 - Database instance (RDS PostgreSQL)
This layer includes RDS instance for PostgreSQL. Seperate subnet is created for database for additional security and independence.
Automatic backups could be created and secrets management defenitely needs to be implemented.

## Improvements:
* Add ALB Application Load Management
  * TLS via certificate manager
  * Karpenter or similar solutions to deploy ALB
  * Necessary IAM setups
* Improve kubernetes manifests (Kustomize, Ingress setup for ALB, Services)
* Bastion or similar to securely offer access to users for tier 2 and tier 3.
* Horizontal Auto-scaling could be fully implemented and improved.
* Automatic database updates
* Automatic etcd backup and external volume management
* Secrets management (AWS Secrets Manager or Hashicorp Vault) should be implemented.
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

## Monitoring
Some options for monitoring are Grafana, Datadog, CloudWatch.
APM Agent can be attached to container and gather various metrics for the chosen observability tool.
Previously we have used Prometheus/Thanos to gather metrics and also ELK stack to gather all the logs.
For Spring/.NET there are libraries which can be included in development of microservices to provide better and more relevant metrics.
