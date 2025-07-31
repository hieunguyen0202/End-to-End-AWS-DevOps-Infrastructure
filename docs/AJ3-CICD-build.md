# 📘 [AJ3] Github Action CICD for Build Docker Image 

Below is a complete GitHub Actions CI/CD pipeline to automate build docker image with dynamic version tag

## Goals
- Pulls latest from dev
- Runs SonarQube scan and checks Quality Gate
- Publishes artifacts to JFrog Artifactory
- Builds a Docker image
- Scans it with Trivy
- Pushes to AWS ECR with dynamic version tag (e.g., 0.0.0 or from commit/tag)


## 🚀 GitHub Actions CI/CD Workflow

```
# File: .github/workflows/aj3-build-cicd.yml
name: Build & Push Docker Image to ECR

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Docker image version tag (e.g., 0.0.0)'
        required: true
        default: '0.0.0'

jobs:
  build:
    name: CI/CD Build & Push
    runs-on: ubuntu-latest

    env:
      AWS_REGION: us-east-1
      ECR_REPO: my-ecr-repo-name                     # <- Replace with your ECR repo
      IMAGE_TAG: ${{ github.event.inputs.version }}

    steps:
      - name: Checkout latest from dev
        uses: actions/checkout@v3
        with:
          ref: dev

      # SonarQube Scan
      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@v1.2
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          projectBaseDir: .
          args: >
            -Dsonar.projectKey=my-project
            -Dsonar.organization=my-org
            -Dsonar.host.url=${{ secrets.SONAR_HOST_URL }}

      - name: Check SonarQube Quality Gate
        uses: sonarsource/sonarqube-quality-gate-action@v1.1
        timeout-minutes: 5
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

      # JFrog Upload (replace with correct JFrog CLI commands or plugins)
      - name: Upload artifacts to JFrog Artifactory
        run: |
          curl -u ${{ secrets.JFROG_USER }}:${{ secrets.JFROG_API_KEY }} \
          -T ./path/to/your-artifact.zip \
          "https://mycompany.jfrog.io/artifactory/my-repo/your-artifact-${{ env.IMAGE_TAG }}.zip"

      # Docker build
      - name: Build Docker image
        run: |
          docker build -t $ECR_REPO:${{ env.IMAGE_TAG }} .

      # Trivy Scan
      - name: Scan Docker image with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.ECR_REPO }}:${{ env.IMAGE_TAG }}
          format: table
          exit-code: '1'
          ignore-unfixed: true

      # Configure AWS credentials
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      # Login to ECR
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      # Push Docker image to ECR
      - name: Push Docker image to ECR
        run: |
          docker tag $ECR_REPO:${{ env.IMAGE_TAG }} ${{ steps.login-ecr.outputs.registry }}/$ECR_REPO:${{ env.IMAGE_TAG }}
          docker push ${{ steps.login-ecr.outputs.registry }}/$ECR_REPO:${{ env.IMAGE_TAG }}

```

## 🔐 GitHub Secrets You Need

| Secret Name             | Description                                                |
|-------------------------|------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID`     | Your AWS access key                                        |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret access key                                 |
| `SONAR_TOKEN`           | Your SonarQube authentication token                        |
| `SONAR_HOST_URL`        | SonarQube server URL (e.g., `https://sonarcloud.io`)       |
| `JFROG_USER`            | JFrog username                                             |
| `JFROG_API_KEY`         | JFrog API key or password                                  |


## 💡 CI/CD Workflow Explanation

| Stage                         | Purpose                                                                 |
|-------------------------------|-------------------------------------------------------------------------|
| `checkout from dev`           | Pulls the latest source code from the `dev` branch                      |
| `SonarQube Scan`              | Analyzes code quality using SonarQube                                   |
| `Check Sonar Quality Gate`    | Verifies code meets defined quality standards                           |
| `Upload to JFrog`             | Publishes build artifacts to JFrog Artifactory                          |
| `Docker Build`                | Builds a Docker image from the latest codebase                          |
| `Trivy Image Scan`            | Scans the Docker image for vulnerabilities                              |
| `AWS ECR Login`               | Authenticates Docker to push images to AWS Elastic Container Registry   |
| `Push Docker to ECR`          | Tags and pushes the built image to AWS ECR with dynamic version (e.g., `0.0.0`) |

