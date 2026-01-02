# CI/CD Deployment Approach and Workflow Description

**Assumption**: Essential infrastructure components like VPC (Internet Gateway, RouteTable, Subnets...), Application Load Balancer (ALB), SSL certificate, and IAM roles are existed.

## 1. Overview

This CI/CD pipeline automates the **build, test, security scan, containerization, and deployment** of the application to **AWS ECS** using **Terraform**.

It is triggered automatically on every push to the main branch and runs on a **GitHub runner**.

**Key goals of the pipeline:**

- Enforce code quality and test coverage
- Detect vulnerabilities early
- Build immutable Docker images
- Securely authenticate to AWS using OIDC
- Deploy infrastructure and application consistently via Terraform

## 2. High-Level Architecture

**Pipeline Flow:**

```
Code Push (main)
    ↓
Linting (pylint)
    ↓
Unit Tests (Docker + pytest)
    ↓
Build Docker Image
    ↓
Vulnerability Scan (Trivy)
    ↓
Push Docker Image (Amazon ECR)
    ↓
Deploy to AWS (Terraform → ECS)
```

**AWS Services Involved:**

- Amazon ECR (Docker image registry)
- Amazon ECS (Container orchestration)
- AWS IAM (OIDC-based role assumption)
- Terraform (Infrastructure as Code)

## 3. Triggering Mechanism

```yaml
on:
  push:
    branches:
      - main
```

- The pipeline runs automatically when changes are pushed to the main branch.

## 4. Pipeline Stages and Responsibilities

### 4.1 Linting Stage (Code Quality Check)

**Job:** `linter`

**Purpose:**

- Enforce Python coding standards
- Detect syntax errors and code smells early

**Steps:**

1. Checkout source code
2. Run pylint on all Python files
3. Generate a lint report (pylint-report.txt)
4. Upload report as a build artifact

### 4.2 Unit Testing Stage

**Job:** `test`  
**Depends on:** `linter`

**Purpose:**

- Validate application functionality
- Measure test coverage

**Steps:**

1. Build application using Docker Compose
2. Run unit tests inside the container
3. Generate coverage report in XML format
4. Upload coverage report as an artifact

### 4.3 Build Image

**Job:** `build`  
**Depends on:** `test`

**Purpose:**

- Build a versioned Docker image

**Versioning Strategy**

- Image tag is read from the VERSION file
- Ensures **explicit and traceable releases**

**Steps:**

1. Read application version
2. Build Docker image
3. Tag image with version


### 4.4 Vulnerability Scanning Stage

**Job:** `scan-image`  
**Depends on:** `build`

**Purpose:**

- Detect known vulnerabilities in Docker images
- Shift security checks left in the pipeline

**Steps:**

1. Scan the Docker image using **Trivy**
2. Generate a vulnerability report
3. Upload report as a build artifact

### 4.5 Push Image to Amazon ECR

**Job:** `push-ecr`  
**Depends on:** `scan-image`

**Purpose:**

- Push the image to Amazon ECR

**Secure AWS Authentication**

- Uses **OIDC (OpenID Connect)** instead of static credentials
- GitHub Actions assumes an IAM role via:
  - `aws-actions/configure-aws-credentials@v4`

**Steps:**

1. Authenticate to AWS using OIDC
2. Login to Amazon ECR
3. Push image to ECR

**Security Benefits:**

- No long-lived AWS access keys
- Least-privilege IAM role usage

### 4.6 Deployment to AWS Using Terraform

**Job:** `deploy`  
**Depends on:** `push-ecr`

**Purpose:**

- Deploy or update application on AWS ECS

**Deployment Strategy:**

- Infrastructure as Code (IaC) using Terraform
- Image version injected dynamically via Terraform variables
- Deploy the application to use the existing ALB and SSL certificate
- Deploy the application to the specified domain: https://sample-app.example.com

**Steps:**

1. Authenticate to AWS via OIDC
2. Initialize Terraform backend
3. Generate Terraform execution plan
4. Apply Terraform changes automatically

**Key Variable Passed:**

```
TF_VAR_container_image = <ECR_REGISTRY>/<REPOSITORY>:<VERSION>
```

This ensures:

- ECS service always deploys the **exact image built by the pipeline**
- No manual intervention is required

## 5. Security and Best Practices

| Area | Implementation |
|------|----------------|
| AWS Authentication | OIDC-based role assumption |
| Secrets Management | GitHub Secrets |
| Image Security | Trivy vulnerability scanning |
| IaC | Terraform |
| Artifact Retention | 7 days |
| Immutable Deployments | Versioned Docker images |

## 6. Failure Handling and Observability

- Each stage depends on the previous one
- Failures stop downstream deployment
- Reports (lint, test, security) are always uploaded for diagnostics
- AWS identity verification ensures correct role usage

## 7. Summary

This CI/CD pipeline provides:

- **Automated quality gates**
- **Secure, keyless AWS authentication**
- **Consistent, versioned deployments with existing base infrastructure**