# End-to-End DevOps CI/CD Pipeline with Monitoring and Alerting

An end-to-end DevOps project demonstrating automated testing, Docker image publishing, continuous deployment to an Ubuntu server, infrastructure and application monitoring, and email-based incident alerting.

The project uses **GitHub Actions, Docker, Docker Hub, Ubuntu Linux, Prometheus, Node Exporter, Grafana, Python, and Flask**.

## Project Overview

This project implements a CI/CD pipeline for a containerized Python Flask application.

Whenever code is pushed to the `main` branch, GitHub Actions automatically runs unit tests, builds a Docker image, publishes it to Docker Hub, and deploys the image to an Ubuntu Linux server using a self-hosted GitHub Actions runner.

Prometheus collects application and server metrics, while Grafana provides visualization dashboards and alerts when the Flask application becomes unavailable.

The infrastructure runs in a local VMware-based Ubuntu lab environment.

## Architecture

Developer (Windows / VS Code)
           |
           v
      GitHub Repository
           |
           v
       GitHub Actions
           |
           +-- Run Python Unit Tests
           |
           +-- Build Docker Image
           |
           +-- Push Image to Docker Hub
           |
           v
   Self-Hosted GitHub Runner
           |
           v
       Ubuntu Server
           |
           v
   Flask Application Container
           |
           +-- /health
           +-- /metrics
           |
           v
        Prometheus
           |
           +-- Flask Application Metrics
           +-- Node Exporter Server Metrics
           |
           v
         Grafana
           |
           +-- Monitoring Dashboards
           +-- Application Availability Alerts
           |
           v
      Gmail SMTP Alerts

## Technology Stack

| Technology | Purpose |
|---|---|
| Python / Flask | Application development |
| Git / GitHub | Source control |
| GitHub Actions | CI/CD automation |
| GitHub Self-Hosted Runner | Automated Ubuntu deployment |
| Docker | Containerization |
| Docker Hub | Container image registry |
| Ubuntu Linux | Deployment environment |
| VMware Workstation | Local virtualized infrastructure |
| Prometheus | Metrics collection |
| Node Exporter | Linux server monitoring |
| Grafana | Dashboards and alerting |
| Gmail SMTP | Email notifications |

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Application status |
| `/health` | Application health and timestamp |
| `/info` | Environment and version information |
| `/metrics` | Prometheus-compatible application metrics |

## CI/CD Pipeline

The pipeline is defined in `.github/workflows/ci-cd.yml`.

### Continuous Integration

Triggered by pushes and pull requests targeting the configured branches.

1. Check out source code.
2. Configure Python 3.12.
3. Install dependencies.
4. Execute automated unit tests.
5. Configure Docker Buildx.
6. Build the Docker image.
7. Publish the image to Docker Hub on pushes to `main`.

Docker images are tagged using `latest` and the Git commit SHA.

### Continuous Deployment

For successful pushes to `main`:

1. The CI job completes successfully.
2. A deployment job runs on a self-hosted GitHub Actions runner.
3. The runner executes a restricted deployment script on Ubuntu.
4. The deployment script pulls the image tagged with the commit SHA.
5. The previous application container is replaced.
6. The application starts with Docker's `unless-stopped` restart policy.
7. The deployment script checks `/health` before reporting success.

**Deployment target:** Ubuntu Linux VM running on VMware Workstation.

**Container:** `balaji-flask-prod`

**Application port:** `5000`

## Docker Hub

Published image:

`balajimd07/balaji-flask-service`

Run the latest image manually:

docker pull balajimd07/balaji-flask-service:latest

docker run -d \
  --name balaji-flask-service \
  -p 5000:5000 \
  balajimd07/balaji-flask-service:latest

Verify:

curl http://localhost:5000/health

## Monitoring with Prometheus

Prometheus is configured to scrape metrics every 15 seconds.

### Monitoring Targets

| Job | Target | Purpose |
|---|---|---|
| `prometheus` | `localhost:9090` | Prometheus self-monitoring |
| `ubuntu-server` | `node-exporter:9100` | Ubuntu server metrics |
| `flask-application` | `host.docker.internal:5000` | Flask application metrics |

The Flask application exposes Prometheus-compatible metrics through `/metrics`.

Application monitoring includes HTTP request counts, response codes, and request durations.

Node Exporter provides Linux system metrics such as CPU, memory, disk, and network utilization.

## Grafana Dashboards

Two monitoring dashboards are configured.

### Ubuntu Server Monitoring

Uses the Node Exporter Full dashboard to visualize:

- CPU utilization
- Memory usage
- Disk utilization
- Network traffic
- System uptime

### Flask Application Monitoring

A custom Grafana dashboard displays:

- HTTP requests per second
- HTTP error rate
- Average HTTP response time
- Application availability

Example PromQL queries:

**HTTP Requests per Second**

sum(rate(flask_http_request_total{job="flask-application"}[5m]))

**HTTP Error Rate (%)**

100 *
sum(rate(flask_http_request_total{job="flask-application",status=~"4..|5.."}[5m]))
/
clamp_min(sum(rate(flask_http_request_total{job="flask-application"}[5m])), 0.000001)

**Application Availability**

up{job="flask-application"}

## Grafana Alerting

A Grafana-managed alert rule named **Flask Application Down** monitors application availability.

PromQL:

up{job="flask-application"}

The alert triggers when the metric falls below `1` for the configured pending period.

Configuration:

| Setting | Value |
|---|---|
| Alert rule | Flask Application Down |
| Evaluation interval | 1 minute |
| Pending period | 2 minutes |
| Severity | Critical |
| Notification channel | Email |
| SMTP provider | Gmail |

### Verified Alert Lifecycle

A controlled downtime test was performed:

1. Stopped the Flask application container.
2. Prometheus detected the unavailable metrics endpoint.
3. Grafana transitioned the alert to `Firing`.
4. A firing notification was delivered through Gmail SMTP.
5. Restarted the Flask application container.
6. Prometheus detected application recovery.
7. Grafana transitioned the alert to `Normal`.
8. A resolved notification was successfully received.

Both firing and recovery notifications were verified.

## Running the Application Locally

Clone the repository:

git clone https://github.com/balaji0007-md/end-to-end-devops-pipeline.git
cd end-to-end-devops-pipeline

Install dependencies:

python -m pip install -r app/requirements.txt

Run automated tests:

python -m unittest discover -s tests -v

Start the Flask application:

python app/app.py

Open:

`http://localhost:5000`

## Automated Testing

The application includes three automated unit tests:

- Home endpoint
- Health endpoint
- Application information endpoint

Tests run automatically during the GitHub Actions CI workflow.

## Security Considerations

- Docker Hub credentials are stored as GitHub Actions secrets.
- The deployment job runs only after the CI job succeeds.
- The self-hosted runner uses a dedicated Linux account.
- The runner is granted narrowly scoped sudo access to a deployment script.
- Deployment uses commit-SHA image tags.
- SMTP credentials are kept outside the Git repository.
- Monitoring and deployment are performed in an isolated local lab environment.

The current deployment replaces the running container and does not implement zero-downtime releases or automatic rollback.

## Troubleshooting

### Check Flask Container

sudo docker ps -a
sudo docker logs --tail 50 balaji-flask-prod

### Check Application Health

curl http://localhost:5000/health

### Check Prometheus Targets

Open:

`http://localhost:9090/targets`

Verify that the Flask application and Ubuntu server targets show `UP`.

### Check Monitoring Containers

cd /opt/devops-monitoring
sudo docker compose ps

### Check Grafana Logs

sudo docker logs --tail 50 devops-grafana

### Check CI/CD Failures

Review the workflow execution logs under the GitHub repository's **Actions** tab.

## Project Scope and Limitations

This project demonstrates a working CI/CD and observability pipeline in a local Ubuntu VM.

It does not currently include:

- Kubernetes orchestration
- Terraform infrastructure provisioning
- AWS cloud deployment
- High availability
- Automatic deployment rollback
- Zero-downtime deployment

These are potential future enhancements.

## Key Learning Outcomes

- Building and containerizing a Python application
- Creating GitHub Actions CI/CD workflows
- Publishing Docker images to Docker Hub
- Configuring a self-hosted deployment runner
- Automating application deployment on Linux
- Writing and validating deployment health checks
- Collecting metrics using Prometheus
- Monitoring Linux servers with Node Exporter
- Building Grafana dashboards with PromQL
- Configuring SMTP-based alert notifications
- Testing application downtime and recovery scenarios

## Author

**balaji0007-md**

GitHub: https://github.com/balaji0007-md

