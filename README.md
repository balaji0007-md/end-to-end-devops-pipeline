# End-to-End DevOps CI/CD Pipeline

A containerized Python Flask application with automated testing and Docker image builds using GitHub Actions.

## Project Overview

This project demonstrates a basic CI workflow that validates application code, runs automated unit tests, and builds a Docker image whenever code is pushed to GitHub or a pull request targets the main branch.

## Architecture

Developer → GitHub → GitHub Actions → Automated Tests → Docker Image Build

## Technology Stack

- **Python and Flask:** Web application and HTTP endpoints
- **Git and GitHub:** Source control and repository hosting
- **Docker:** Application containerization
- **GitHub Actions:** CI workflow automation
- **unittest:** Automated application testing

## Application Endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Returns application status |
| `/health` | Returns health status |
| `/info` | Returns environment and application version |

## Project Structure

```text
end-to-end-devops-pipeline/
├── app/
│   ├── app.py
│   └── requirements.txt
├── tests/
│   └── test_app.py
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── Dockerfile
├── .dockerignore
├── .gitignore
└── README.md
```

## Prerequisites

- Git
- Python 3.12
- Docker Desktop or Docker Engine

## Run Locally

Clone the repository:

```bash
git clone https://github.com/balaji0007-md/end-to-end-devops-pipeline.git
cd end-to-end-devops-pipeline
```

Install dependencies and run the tests:

```bash
python -m pip install -r app/requirements.txt
python -m unittest discover -s tests -v
```

Start the application directly:

```bash
python app/app.py
```

Open `http://localhost:5000/` in your browser.

## Run with Docker

Build the image:

```bash
docker build -t devops-demo:1.0 .
```

Start the container:

```bash
docker run -d --name devops-demo -p 5000:5000 devops-demo:1.0
```

Test the endpoints:

```bash
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/info
```

View container logs:

```bash
docker logs devops-demo
```

Stop and remove the container:

```bash
docker stop devops-demo
docker rm devops-demo
```

## CI Workflow

The GitHub Actions workflow is located at `.github/workflows/ci-cd.yml`.

On a push or pull request targeting `main` or `master`, it:

1. Checks out the repository.
2. Sets up Python 3.12.
3. Installs application dependencies.
4. Runs the automated unit tests.
5. Sets up Docker Buildx.
6. Builds the Docker image without publishing it.

The workflow has been executed successfully in GitHub Actions, including the test and image-build steps.

## Testing

The automated tests cover:

- Home endpoint response
- Health endpoint response
- Application information endpoint

Run the test suite with:

```bash
python -m unittest discover -s tests -v
```

## Troubleshooting

**Container exits unexpectedly**

```bash
docker ps -a
docker logs devops-demo
```

**Port 5000 is already in use**

Run the container on host port 5001 instead:

```bash
docker run -d --name devops-demo -p 5001:5000 devops-demo:1.0
```

Then access `http://localhost:5001/`.

**CI workflow fails**

Open the repository's Actions tab and inspect the failed step's logs.

## Current Scope

Implemented and verified:
- Flask application with three endpoints
- Three automated unit tests
- Docker image build and local container execution
- GitHub Actions CI workflow
- Successful GitHub Actions run

Kubernetes deployment, Docker image publishing, Terraform infrastructure, and monitoring are planned extensions and are not yet implemented in this version.

## Learning Outcomes

- Writing and testing a small web application
- Building and running Docker containers
- Automating tests and image builds with GitHub Actions
- Managing code using Git and GitHub
- Investigating basic container and CI failures

## Author

**balaji0007-md**

GitHub: https://github.com/balaji0007-md
