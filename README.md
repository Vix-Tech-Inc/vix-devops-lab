# 🚀 VIX Technologies — DevOps Lab

> **Enterprise DevOps infrastructure for VIX Platform**  
> CI/CD · Docker · Terraform · Monitoring · Security

![CI Status](https://github.com/Vix-Tech-Inc/devops-lab/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue)
![Terraform](https://img.shields.io/badge/terraform-1.6+-purple)
![Docker](https://img.shields.io/badge/docker-ready-blue)

---

## 📁 Project Structure
```
devops-lab/
├── 01-cicd-pipeline/     # GitHub Actions CI/CD workflows
├── 02-docker/            # Docker & NGINX containerization
├── 03-terraform/         # Azure infrastructure as code
└── 04-monitoring/        # Prometheus + Grafana monitoring
```

---

## 🔧 Projects

### Project 1 — CI/CD Pipeline
**Tools:** GitHub Actions · Docker · Vercel  
Automated pipeline that runs on every push:
- ✅ TypeScript type checking
- ✅ ESLint code quality
- ✅ Next.js production build
- ✅ Docker image build & push
- ✅ Security vulnerability scan (Trivy)
- ✅ Automated deployment to Vercel
- ✅ Post-deploy health check

### Project 2 — Docker Containerization
**Tools:** Docker · Docker Compose · NGINX · Redis  
Production-ready containerization:
- Multi-stage Dockerfile (deps → builder → runner)
- Non-root user security
- NGINX reverse proxy with SSL
- Redis caching layer
- Health checks on all services
- Gzip compression & rate limiting

### Project 3 — Infrastructure as Code
**Tools:** Terraform · Azure  
Complete Azure infrastructure:
- Resource Group & Virtual Network
- Azure App Service (containerized)
- Container Registry (ACR)
- PostgreSQL Flexible Server
- Redis Cache
- Blob Storage
- Application Insights

### Project 4 — Monitoring & Observability
**Tools:** Prometheus · Grafana · Loki · AlertManager  
Full observability stack:
- Real-time metrics collection
- Custom Grafana dashboards
- Log aggregation with Loki
- Alerting via AlertManager
- System metrics via Node Exporter

---

## 🚀 Quick Start

### CI/CD Pipeline
```bash
# Workflows trigger automatically on push
# Add these GitHub secrets:
# VERCEL_TOKEN, DOCKER_USERNAME, DOCKER_PASSWORD
# PRODUCTION_URL, NEXT_PUBLIC_SITE_URL
```

### Docker
```bash
cd 02-docker
cp .env.example .env.production
docker compose up -d
```

### Terraform
```bash
cd 03-terraform
cp terraform.tfvars.example terraform.tfvars
# Fill in your values
terraform init
terraform plan
terraform apply
```

### Monitoring
```bash
cd 04-monitoring
docker compose -f docker-compose.monitoring.yml up -d
# Grafana: http://localhost:3001
# Prometheus: http://localhost:9090
```

---

## 🛡️ Security

- All secrets stored in GitHub Secrets / Azure Key Vault
- Non-root Docker containers
- TLS 1.2+ enforced everywhere
- Rate limiting on all endpoints
- Vulnerability scanning on every build
- Infrastructure state encrypted in Azure Blob

---

## 📊 Impact

| Metric | Before | After |
|--------|--------|-------|
| Deployment time | 45 minutes (manual) | 8 minutes (automated) |
| Deployment failures | ~30% | <2% |
| Infrastructure provisioning | 2 days | 15 minutes |
| Mean time to detect issues | Hours | Minutes |
| Environment consistency | ❌ | ✅ |

---

## 🏢 About VIX Technologies

VIX Technologies Incorporation is a next-generation technology company  
building the digital infrastructure of tomorrow from Nairobi, Kenya.

**[vixtech.co.ke](https://vixtech.co.ke)** · 
**[GitHub](https://github.com/Vix-Tech-Inc)**