```yaml
name: build-push-docker
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  build:
    name: Build Spring Boot
    runs-on: ubuntu-latest
    steps:
      - name: Git Checkout Code
        uses: actions/checkout@v1
        id: git_checkout
      - name: Build Docker Image
        id: buildAndPushImage
        uses: bds1959/build-push-docker@v1.0
        with:
          registry_url: 'docker.io'
          repository_name: 'demo-app'
          user_name: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          image_version: 'v1.0'
          docker_file: '.'
      - name: Get pre step result output image_pull_url
        run: echo "The time was ${{ steps.buildAndPushImage.outputs.image_pull_url }}"
```
