# AWS Multi-Tier Kubernetes Infrastructure

This project demonstrates the deployment of a scalable, multi-tier application on AWS using Terraform and Kubernetes (EKS). It sets up a Virtual Private Cloud (VPC), an Elastic Kubernetes Service (EKS) cluster, an RDS PostgreSQL database, and includes Kubernetes manifests (using Kustomize) for frontend and backend services.

## Modules used:
* https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
* https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest

## Diagram
![devops-task-zendesk drawio (3)](https://github.com/user-attachments/assets/34870ae0-3481-46c7-9890-e85f7bbce897)


## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.20
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- *[Kustomize](https://kustomize.io/) >= 3.8.0 For templated kustomize kubernetes manifests that are not fully implemented yet.

## Setup Instructions

0. **Change the ipv4 address at the end of variables.tf to match your ipv4 address:**
   ```bash
   This is neccessary to be able to use kubectl. In ideal world this access would be managed with Bastion!
   ```
1. **Clone the Repository:**
   ```bash
   git clone https://github.com/randoromm/aws-multi-tier-k8s-infra.git
   cd aws-multi-tier-k8s-infra/terraform
   ```
2. **Deploy terraform**
   ```bash
   terraform init
   terraform apply
   ```
3. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --name devops-eks --region eu-west-1
   ```
4. **Deploy kubernetes manifest(s) (to verify ALB controller setup)**
   ```bash
   e.g.
   kubectl apply -f ../kubernetes/ngnix-test-deployment.yaml
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
  - Revise RDS ingress and egress rules. Limit network access further.
  - Extend Bastion authorization management in general to private subnets  (besides RDS)
      - Instead of specifically defining your own public IP for public cluster access.
  - Implement IAM roles with least privilege.
  - Configure network security groups further for proper restricted access.
  - Setup TLS (HTTPS) for ALB.
     - Route53 and a custom domain with HTTP to HTTPS redirecting and necessary listeners.

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
  - Organizing of terraform resource/data/variable/module blocks and files.
  - Go over the variables, versions, definitions
  - Ensure common handwriting
  - Add relevant comments and explanations

## CI/CD Implementation Suggestions
When designing a CI/CD process, there are several strategies to consider. Below is a recommended approach:

## Release Branching Strategy
Adopt a release branching strategy based on GitFlow principles. This ensures a structured workflow for both infrastructure and microservices, promoting stability and continuous delivery.

Key Branches:

- Main: Always reflects production-ready code.
- Develop: A collaborative branch for ongoing development.
- Feature Branches: For new features or enhancements. Merged into develop after completion.
- Release Branches: Prepared for final testing before being merged into main.
- Hotfix Branches: For critical fixes directly applied to main.

## CI/CD Tools and Workflow
### CI/CD Pipeline Tools:
Use Jenkins or GitHub Actions for managing CI/CD workflows.
Integrate pipelines with Terraform Enterprise to manage infrastructure as code (IaC) changes.
Automate container image builds using Docker and push them to Amazon Elastic Container Registry (ECR).
CD for Microservices:

Consider ArgoCD for declarative continuous delivery in Kubernetes. ArgoCD works well with GitOps principles, enabling automated deployment when Kubernetes manifests or Helm charts are updated.
Separate microservice upgrades from core infrastructure changes to streamline deployments.
Security Considerations:

Use automated security checks in CI pipelines with tools like Trivy or Snyk.
Implement IAM roles and policies for least privilege access during pipeline execution.
Monitoring
Monitoring is essential for ensuring the reliability and performance of your application. Below are some recommendations:

## Tools and Options
### Grafana and Prometheus:
Use Prometheus for scraping metrics from Kubernetes and application components.
Combine Thanos with Prometheus for long-term metric storage and query performance.
Visualize metrics with Grafana.

###Cloud-Native Monitoring:
Integrate with Amazon CloudWatch for AWS-native monitoring, including logs, metrics, and application insights.
Use Datadog for a comprehensive SaaS-based observability platform.

###Logging:
Deploy the ELK Stack (Elasticsearch, Logstash, Kibana) or EKS Managed OpenSearch for log aggregation and analysis.
Enable Kubernetes logging for detailed insights into pods, nodes, and services.

## Application Performance Monitoring (APM)
### APM Tools:
Attach an APM agent to containers for deeper observability, such as Datadog APM, New Relic, or AWS X-Ray.
These tools can track distributed traces, identify bottlenecks, and profile application performance.

### Microservice Instrumentation:
Use libraries like Micrometer for Java/Spring applications to expose application-level metrics to Prometheus.
For .NET applications, integrate Application Insights SDK or OpenTelemetry for detailed telemetry data.
Include request tracing, database query performance, and error rates in your dashboards.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact
For questions or contributions, please contact [Rando Rommot](https://github.com/randoromm).
