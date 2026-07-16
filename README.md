# DevSecOps 3-Tier Application Deployment Guide

This project demonstrates a complete **DevSecOps CI/CD pipeline** using:

* Jenkins
* Docker & Docker Compose
* SonarQube
* Trivy
* Python
* MySQL
* GitHub
* AWS EC2 (Ubuntu)

Follow the steps below to deploy the project on any Ubuntu-based cloud VM (AWS EC2, Azure VM, GCP VM, DigitalOcean, etc.).

---

# Prerequisites

Create an Ubuntu EC2 instance (recommended Ubuntu 22.04/24.04).

Open the following inbound ports in the Security Group:

| Port | Purpose                              |
| ---- | ------------------------------------ |
| 22   | SSH                                  |
| 8080 | Jenkins                              |
| 9000 | SonarQube                            |
| 5000 | Flask Application                    |
| 3000 | Frontend/Application (if applicable) |
| 25   | SMTP (Optional)                      |

---

# Step 1 - Connect to the Server

Connect using your SSH key.

```bash
ssh -i your-key.pem ubuntu@<PUBLIC-IP>
```

Switch to the root user.

```bash
sudo -i
```

Clone this repository.

```bash
git clone <YOUR_REPOSITORY_URL>
cd <REPOSITORY_NAME>
```

---

# Step 2 - Make Installation Scripts Executable

Before running any script:

```bash
chmod +x *.sh
```

or

```bash
chmod +x 1st-Jenkins.sh
chmod +x 2nd-Docker.sh
chmod +x 3rd-Adduser+python.sh
chmod +x 4th-Trivy.sh
chmod +x 5th-DockerScout.sh
```

---

# Step 3 - Install Java & Jenkins

Jenkins requires Java.

You can either:

* Run the provided Jenkins installation script.
* OR follow the official Jenkins documentation.

```bash
./1st-Jenkins.sh
```

After installation, open:

```
http://<PUBLIC-IP>:8080
```

Complete the Jenkins initial setup.

---

# Step 4 - Install Required Jenkins Plugins

Install the following plugins from:

**Manage Jenkins → Plugins**

Install:

* Pipeline
* Git
* Docker
* Docker Pipeline
* Docker API
* SonarQube Scanner
* Pipeline Stage View

Restart Jenkins after installation if required.

---

# Step 5 - Configure Jenkins Tools

Go to:

**Manage Jenkins → Tools**

Configure:

## Sonar Scanner

Tool Name:

```
sonar-scanner
```

Install automatically.

---

# Step 6 - Configure Jenkins Credentials

Go to:

**Manage Jenkins → Credentials → Global**

Add Docker Hub credentials.

Type:

```
Username with Password
```

Credential ID:

```
docker
```

Use your own Docker Hub username and password.

---

# Step 7 - Install Docker

Install Docker using the provided script.

```bash
./2nd-Docker.sh
```

Or follow the official Docker installation guide.

---

# Step 8 - Install Python & Configure Jenkins User

Run:

```bash
./3rd-Adduser+python.sh
```

This script:

* Adds the Jenkins user to the Docker group.
* Restarts Jenkins.
* Verifies Docker access.
* Installs Python 3.
* Installs pip.
* Installs Python virtual environment support.
* Installs Docker Compose Plugin.

These packages are required for Docker-based builds and Python applications.

---

# Step 9 - Install Trivy

Run:

```bash
./4th-Trivy.sh
```

## Why Trivy?

Trivy scans:

* Operating System vulnerabilities
* Application dependencies
* Docker images
* Misconfigurations
* Secrets

Example image scan:

```bash
trivy image nginx:latest
```

or

```bash
trivy image <your-image-name>
```

Trivy is used inside the Jenkins pipeline to identify security vulnerabilities before deployment.

---

# Step 10 - Install SonarQube

Run:

```bash
docker run -d \
  --name sonar \
  -p 9000:9000 \
  sonarqube:latest
```

Verify SonarQube:

```
http://<PUBLIC-IP>:9000
```

Default credentials:

```
Username : admin
Password : admin
```

Change the password when prompted.

---

# Step 11 - Generate SonarQube Token

Go to:

```
Administration
→ Security
→ Users
```

Click the token icon for the admin user.

Create a token.

Example:

```
Name : sonar-token
Expiration : 90 Days
```

Copy the generated token immediately.

**Note:** The token is displayed only once.

---

# Step 12 - Add Sonar Token in Jenkins

Go to:

```
Manage Jenkins
→ Credentials
→ Global
```

Add:

```
Secret Text
```

Credential ID:

```
sonar-token
```

Paste the token copied from SonarQube.

---

# Step 13 - Configure SonarQube Webhook

In SonarQube:

```
Administration
→ Configuration
→ Webhooks
```

Create a new webhook.

URL:

```
http://<JENKINS-PUBLIC-IP>:8080/sonarqube-webhook/
```

Save it.

---

# Step 14 - Configure SonarQube Server in Jenkins

Go to:

```
Manage Jenkins
→ System
```

Find:

```
SonarQube Servers
```

Configure:

Name:

```
sonar
```

Server URL:

```
http://<PUBLIC-IP>:9000
```

Authentication Token:

```
sonar-token
```

Save.

---

# Step 15 - Create Jenkins Pipeline

Create a new Jenkins Pipeline project.

Paste the provided Jenkins Pipeline (Jenkinsfile) from this repository.

Update the following values according to your environment:

* GitHub repository URL
* Branch name
* Docker image name
* Docker Hub username

Save and build the pipeline.

---

# Step 16 - Pipeline Execution Flow

The pipeline performs the following stages:

1. Git Checkout
2. Trivy File System Scan
3. SonarQube Code Analysis
4. Verify Docker Compose
5. Build Docker Image
6. Push Image to Docker Hub
7. Deploy Application
8. Verify Deployment

If any stage fails, review the Jenkins console logs, fix the issue, and rebuild the pipeline.

---

# Step 17 - Verify SonarQube Results

After a successful pipeline execution:

Open:

```
http://<PUBLIC-IP>:9000
```

You should see:

* Bugs
* Vulnerabilities
* Code Smells
* Security Hotspots
* Coverage
* Duplications
* Quality Gate

---

# Step 18 - Access the Application

Open:

```
http://<PUBLIC-IP>:5000
```

Complete the exam and submit your responses.

---

# Step 19 - Verify MySQL Data

Connect to the MySQL container.

```bash
docker exec -it mysql_db mysql -u root -p
```

Password:

```
rootpass
```

Select the database:

```sql
USE dev_exam;
```

Useful SQL commands:

```sql
SHOW DATABASES;

USE dev_exam;

SHOW TABLES;

SELECT * FROM users;

SELECT * FROM results;

DESCRIBE users;

EXIT;
```

Verify that the submitted exam data has been stored successfully.

---

# Project Architecture

```
GitHub
   │
   ▼
Jenkins Pipeline
   │
   ├── Git Checkout
   ├── Trivy Scan
   ├── SonarQube Analysis
   ├── Docker Build
   ├── Docker Push
   └── Docker Compose Deploy
            │
            ▼
     Flask + MySQL Application
```

---

# Troubleshooting

### Jenkins not opening

* Verify port 8080 is open.
* Check:

```bash
systemctl status jenkins
```

---

### Docker permission denied

Run:

```bash
usermod -aG docker jenkins
systemctl restart jenkins
```

---

### SonarQube not opening

Verify:

```bash
docker ps
docker logs sonar
```

---

### Docker Compose not found

Install:

```bash
apt-get install docker-compose-plugin
```

---

### Trivy not found

Verify installation:

```bash
trivy --version
```

---

# Congratulations!

You have successfully deployed a complete DevSecOps CI/CD pipeline with Jenkins, Docker, SonarQube, Trivy, MySQL, and a Flask application.
 
