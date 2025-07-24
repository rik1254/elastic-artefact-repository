#!/bin/bash
source variables.env

if [[ -z $NGINX_VERSION || -z $STACK_VERSION ]];
then
  echo "NGINX Version = "$NGINX_VERSION
  echo "Stack Version = "$STACK_VERSION
  echo "One or more variables are unset. Update 'variables.env'."
  exit 1
fi

echo "Variables set."
echo $IMAGE
#docker build --rm --build-arg NGINX_VERSION=$NGINX_VERSION -t $IMAGE .


# Move items into deployable directory
cp -R certs ../deploy/ -f
cp variables.env ../deploy/ -f
cp nginx.conf ../deploy/ -f

# Save newly created image into 'deploy' directory
#docker save $IMAGE > ../deploy/ear.tar
