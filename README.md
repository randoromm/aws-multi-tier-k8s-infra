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
   cd aws-multi-tier-k8s-infra/terraform
   ```
2. ** Deploy terraform **
   ```bash
   terraform init
   terraform apply
   ```
3. ** Configure kubectl **
   ```bash
   aws eks update-kubeconfig --name devops-eks --region eu-west-1
   ```
4. ** Deploy kubernetes manifest(s)
   ```bash
   e.g.
   kubectl apply -f ../kubernetes/ngnix **
   ```

## Tier 1 - Public Subnets, Gateways, Load Balancing
The first tier consists of two public subnets deployed in separate availability zones to ensure high availability. These subnets are responsible for hosting the gateways and load balancers, which handle incoming traffic to the environment. The public subnets are exposed to the internet, ensuring that the traffic is appropriately managed. The other tiers, such as the EKS cluster and the database, are isolated from direct internet access, providing an added layer of security. This design ensures that only the components that need external exposure, such as the load balancers, are publicly accessible, while the rest of the infrastructure remains protected.

## Tier 2 - Private Subnets - EKS Cluster
The second tier hosts the Amazon EKS cluster, which includes the application instances and the worker nodes running in two private subnets. These private subnets are not directly accessible from the internet, providing a secure environment for the application workloads. To enhance security, access to this layer should be further controlled, for instance, by using a Bastion host (Jump Box) to provide secure SSH access to the private subnets, and by implementing proper monitoring for access attempts. While access to this layer is currently limited via IAM roles, additional measures such as VPC Flow Logs, security group monitoring, and a centralized logging solution are recommended for better auditing and visibility.

## Tier 3 - Database Instance (RDS PostgreSQL)
The third tier contains the RDS PostgreSQL instance, hosted in a dedicated subnet for enhanced security and separation of concerns. This database tier is placed in a private subnet to prevent direct internet access and to ensure that it can only be accessed by authorized services within the VPC. To further improve the security posture, automatic backups are enabled, and encryption at rest is utilized. It is critical to implement a secrets management solution for handling database credentials and other sensitive data. Solutions such as AWS Secrets Manager or Parameter Store can be used to securely store and rotate credentials.

## Improvements and Future Work

- **Features/Configuration:**
  - Improve the configuration of RDS, EKS and ALB module
  - Check the official documentation and setup more production ready configuratiton
  - Finalize the Kustomize template kubernetes manifests and auto-deploy them with ALB enabled.
   
- **Security Enhancements:**
  - Implement IAM roles with least privilege.
  - Configure network security groups for restricted access.
  - Implement Bastion to provide controlled access to users to RDS (and in general private subnets)
  - Setup TLS (HTTPS) for ALB. Route53 and a custom Domain.

- **Scalability:**
  - Set up auto-scaling for the EKS cluster and application deployments.
       - Cluster autoscaler requires similar setup to ALB and allows nodes to scale according to EKS resources.

- **Monitoring and Logging:**
  - Integrate AWS CloudWatch for centralized logging and monitoring.
  - Deploy Prometheus and Grafana for Kubernetes metrics visualization.

- **CI/CD Pipeline:**
  - Establish a continuous integration and deployment pipeline using Jenkins, AWS CodePipeline or GitHub Actions.

- **Cost Optimization:**
  - Analyze resource utilization to identify cost-saving opportunities.
  - Implement spot instances for non-critical workloads.

- **Documentation:**
  - Provide detailed application setup and usage instructions.
  - Include troubleshooting guides for common issues.

- **Clean Code:**
  - Go over the variables, versions, definitions
  - Ensure common handwriting
  - Add relevant comments and explanations

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

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact
For questions or contributions, please contact [Rando Rommot](https://github.com/randoromm).
