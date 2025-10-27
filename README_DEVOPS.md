
Task Overview

The main goal of this task was to set up the Zulip application using a complete CI/CD pipeline with Jenkins, Docker, and Kubernetes (Helm).
The process includes building a Docker image from the Zulip source code, pushing it to Docker Hub, and deploying it into a Kubernetes cluster through Helm.

⸻

Steps Performed

1. Repository Setup
	•	Forked the official Zulip repository into my own GitHub account.
	•	Cloned the forked repository into the EC2 instance.
	•	Verified the structure of the Zulip project. It contains backend (Python/Django), frontend (React + TypeScript), and several setup scripts related to PostgreSQL.

⸻

2. Jenkins Pipeline Setup
	•	Created a Jenkins pipeline to automate the build and deployment process.
	•	The pipeline does the following steps:
	1.	Pulls the latest code from the forked repository.
	2.	Builds the Docker image using the Dockerfile.
	3.	Pushes the image to my Docker Hub account.
	4.	Deploys the image into the Kubernetes cluster using Helm.
	•	Configured Jenkins with Docker and Helm access on the same EC2 server.

⸻

3. Helm Chart Setup
	•	Created a Helm chart for Zulip under helm/zulip/.
	•	The chart contains:
	•	Chart.yaml – metadata information.
	•	values.yaml – used to define image name, port, and environment variables.
	•	templates/deployment.yaml and service.yaml – used to create pods and expose them through a NodePort service.
	•	Deployed the chart using Jenkins after building and pushing the image.

⸻

4. Docker Image and Issues
	•	Inside the Zulip code, there are multiple Dockerfiles such as:
	•	Dockerfile-postgresql
	•	tools/ci/Dockerfile
	•	tools/ci/Dockerfile.prod
	•	These Dockerfiles are mainly for internal Zulip testing or for PostgreSQL setup, not for building the full application.
	•	I tried building using these Dockerfiles, but the container was failing to start.
	•	Later, I wrote a custom Dockerfile to build on top of the Zulip source code.
	•	During this, I faced several issues:
	•	Missing Python virtual environment (.venv).
	•	Missing frontend build steps for npm/pnpm.
	•	Permissions error because Zulip needs to run under a “zulip” user instead of root.
	•	Some startup scripts like setup-zulip-secrets were missing during container run.

Due to these, the container built successfully but was not able to start properly in Kubernetes.

⸻

5. Deployment in Kubernetes
	•	Jenkins pipeline successfully built the Docker image and pushed it to Docker Hub.
	•	Helm chart was deployed successfully to the Kubernetes cluster.
	•	The deployment and service were created correctly.
	•	However, the Zulip pod kept crashing (CrashLoopBackOff) due to the issues in the container start process.

⸻

Observations

Area	Status	Notes
Jenkins Pipeline	Working	Build, push, and deploy completed successfully
Helm Chart	Working	Deployment and service created properly
Docker Build	Partial	Image builds but fails during runtime
Kubernetes Pods	Created	Pod crashes due to application startup errors
Application	Not Running	Issue with Dockerfile and missing scripts


⸻

Root Cause
	•	Zulip does not have one single complete Dockerfile for production.
	•	The available Dockerfiles are limited to specific components.
	•	To run the full Zulip app, it needs:
	•	A separate zulip user.
	•	Python virtual environment setup.
	•	Frontend build using pnpm (not npm).
	•	Database initialization (PostgreSQL or SQLite).

Because of these missing configurations, the container is unable to start inside Kubernetes.

⸻

Current Status
	•	Jenkins pipeline is working fine end-to-end.
	•	Helm chart is deployed successfully.
	•	Docker image builds successfully but container fails at runtime.
	•	Kubernetes deployment is created but application is not accessible due to container errors.

⸻

Summary of Work Done
	1.	Forked the Zulip repository and cloned it to the EC2 instance.
	2.	Created Jenkins pipeline for automated build, push, and deploy.
	3.	Created Helm charts for Kubernetes deployment.
	4.	Analyzed multiple Dockerfiles in Zulip source.
	5.	Tried building the image using existing and custom Dockerfiles.
	6.	Deployment successful, but pod crashed because of missing setup steps.

