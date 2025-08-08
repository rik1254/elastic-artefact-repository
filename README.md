# Elastic Artifact Registry
Nginx based container that serves Elastic Artifacts within an airgapped envrioment.

# Limitations
- Uses this [script](https://www.elastic.co/docs/deploy-manage/deploy/self-managed/air-gapped-install#additional-artifact-registry-examples) to download artefacts.
- Uses this [command](https://www.elastic.co/docs/solutions/security/configure-elastic-defend/configure-offline-endpoints-air-gapped-environments#_step_3_manually_copy_artifact_updates) to download endpoint updates

# Build the image
## Requirements
1. An internet connected machine with <b>Docker</b> installed
2. At least 15GB of free disk space


Set the environment variables in ```variables.env``` using a text editor of your choice.
```
export STACK_VERSION=9.0.4
export NGINX_VERSION=1.29.0
export REPOSITORY=docker.io
export CREATOR=rik1254
export NAME=artefact-repository
export CREATION_DATE=2025-08-08


# Add the absolute or relative path from the deploy.sh script
export CERTIFICATE_PATH=./certs/wildcard.crt
export KEY_PATH=./certs/wildcard.pem

# Only change if there is a port conflict on the node EAR will be deployed on to
export EAR_PORT=8443

# DO NOT CHANGE
export IMAGE=$REPOSITORY/$CREATOR/$NAME:$STACK_VERSION-$CREATION_DATE
```
Export the variables
```
source variables.env
```
Verify
```
echo $NGINX_VERSION
1.29.0

echo $ELASTIC_VERSION
9.0.4
```

Run the following script. It will fail if the above variables are not set.
```
cd build 
./build.sh
```
This script creates a new Docker image containing the artefacts for updates and upgrades to Elastic Agents and also Endpoint Security Definitions.
## Verify the image has created
The Version, Image ID and Size will differ:
```
docker images

REPOSITORY                             TAG               IMAGE ID      CREATED             SIZE
docker.io/rik1254/artefact-repository  9.0.4-2025-08-08  1ec42dd0481b  About a minute ago  2.63 GB
```
Future references to ```IMAGE``` will require the ```REPOSITORY``` and ```TAG``` elements from above.

Using the above example, the IMAGE will be ```docker.io/rik1254/ear:9.0.4-2025-08-08```.

# Save the image
## Save the image
To do this, the image name will need to be known.
```
docker save IMAGE > ear.tar
```
At this stage, the image can be exported from the machine and copied to another machine. The 'deploy' directory will also be required.

The image enables HTTPS by default, this repository provides a self signed certificate and key to use, however it is recommended to create a new certificate and key for the environment this will be deployed into.
# Load the image
## Requirements
1. A machine with <b>Docker</b> and <b>Docker Compose </b>installed
2. At least 15GB of free disk space

Once the image has been copied to the new machine, it can be loaded in using the following:
```
docker load < ear.tar
```
Verify it has loaded with the following (the Version, Image ID and Size will differ):
```
docker images

REPOSITORY                             TAG               IMAGE ID      CREATED             SIZE
docker.io/rik1254/artefact-repository  9.0.4-2025-08-08  1ec42dd0481b  About a minute ago  2.63 GB
```

# Run the image
## Requirements
Unpack the 'deploy' package taken at the same time the image was save. This will contain the following:
```
It is expected to have the following directory layout and all of the following commands are to be executed in the same directory as the ```docker-compose.yml``` file.
```
.
├── certs
│   ├── CERTIFICATE
│   └── KEY
├── deploy.sh
├── docker-compose.yml
├── nginx.conf
└── variables.env
```
The image enforces HTTPS, and as such requires a certificate and key to be provided. As default, these should be called ```els.crt``` and ```els.key``` and be stored in the ```certs``` directory (see above). However if there is an enforced naming policy for certificates and keys within the environment, these can also be updated in the ```nginx.conf``` file.
## Configure
Out of the box, the provided files (```nginx.conf```, ```variables.env``` and ```docker-compose.yml```) will start a fully functioning Docker container hosting the artefacts assuming they were exported at the same time as the image was created. However, it is possible to modify the ```nginx.conf``` file if additional changes are required to handle external factors such as access via a proxy.


```
cd deploy
./deploy.sh
```
Follow the prompts printed on screen.

EAR will be listening on port 8443. Firewalls and SELinux may need adjusting to allow access to the port.
Additional changes will be required within Kibana to accept the air-gapped changes.
