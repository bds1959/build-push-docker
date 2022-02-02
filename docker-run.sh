#!/bin/sh
docker_file=$INPUT_DOCKER_FILE
if [[ "${docker_file}" = "" ]] 
  then
    docker_file="."
  else
    docker_file="-f ${docker_file} ."
fi
echo "$DOCKER_PASSWORD" > "$HOME"/docker-login_password.text
DOCKER_REGISTRY_URL="$REGISTRY_URL"
DOCKER_IMAGE_NAME="$1"
DOCKER_IMAGE_TAG="$2"
REGISTRY=${DOCKER_REGISTRY_URL}
NAMESPACE=${DOCKER_NAMESPACE}
IMAGE_NAME=${DOCKER_IMAGE_NAME}
IMAGE_TAG=${DOCKER_IMAGE_TAG}
sh -c "cat "$HOME"/docker-login_password.text | docker login --username $DOCKER_USERNAME --password-stdin"
sh -c "docker build -t $IMAGE_NAME ${docker_file}"
REGISTRY_IMAGE="$NAMESPACE/$IMAGE_NAME"
sh -c "docker tag $IMAGE_NAME $REGISTRY_IMAGE:$DOCKER_IMAGE_TAG"
sh -c "docker push $REGISTRY_IMAGE:$IMAGE_TAG"

#output
echo "::set-output name=image_pull_url::$REGISTRY_IMAGE:$IMAGE_TAG"
