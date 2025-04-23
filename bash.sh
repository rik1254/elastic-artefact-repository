#!/bin/bash
echo Currently Supports 'elastic-agent' 'heartbeat' 'filebeat' 'packetbeat' 'auditbeat' 'osquerybeat', 'fleet-server' 'cloudbeat' 'endpoint-dev' 'apm-server' ONLY!

cd /usr/share/nginx/html

version='8.17.5'

arch=('windows' 'linux')
app=('heartbeat/heartbeat' 'elastic-agent/elastic-agent' 'filebeat/filebeat' 'packetbeat/packetbeat' 'auditbeat/auditbeat' 'osquerybeat/osquerybeat' )
artifact_type=('fleet-server/fleet-server' 'cloudbeat/cloudbeat' 'endpoint-dev/endpoint-security' 'apm-server/apm-server' 'prodfiler/pf-host-agent' 'prodfiler/pf-elastic-collector' 'prodfiler/pf-elastic-symbolizer' )
for platform in "${arch[@]}"
do
   if [ "${platform}" == "windows" ]
    then
      for app in "${app[@]}"
      do
        file=zip
        echo $file
        echo "$platform + $version"
        curl https://artifacts.elastic.co/downloads/beats/$app-$version-$platform-x86_64.$file --create-dirs --output downloads/beats/$app-$version-$platform-x86_64.$file
        curl https://artifacts.elastic.co/downloads/beats/$app-$version-$platform-x86_64.$file.sha512 --create-dirs --output downloads/beats/$app-$version-$platform-x86_64.$file.sha512
        curl https://artifacts.elastic.co/downloads/beats/$app-$version-$platform-x86_64.$file.asc --create-dirs --output downloads/beats/$app-$version-$platform-x86_64.$file.asc
        continue  # read next file and skip the cp command
      done
      for artifact_type in "${artifact_type[@]}"
      do
        file=zip
        echo $file
        echo "$platform"
        curl https://artifacts.elastic.co/downloads/$artifact_type-$version-$platform-x86_64.$file --create-dirs --output downloads/$artifact_type-$version-$platform-x86_64.$file
        curl https://artifacts.elastic.co/downloads/$artifact_type-$version-$platform-x86_64.$file.sha512 --create-dirs --output downloads/$artifact_type-$version-$platform-x86_64.$file.sha512
        curl https://artifacts.elastic.co/downloads/$artifact_type-$version-$platform-x86_64.$file.asc --create-dirs --output downloads/$artifact_type-$version-$platform-x86_64.$file.asc
        continue  # read next file and skip the cp command
      done
    fi
    if [ "${platform}" == "linux" ]
    then
      for app in "${app[@]}"
      do
        file=tar.gz
        echo $file
        echo "$platform"
        curl https://artifacts.elastic.co/downloads/beats/$app-$version-$platform-x86_64.$file --create-dirs --output downloads/beats/$app-$version-$platform-x86_64.$file
        curl https://artifacts.elastic.co/downloads/beats/$app-$version-$platform-x86_64.$file.sha512 --create-dirs --output downloads/beats/$app-$version-$platform-x86_64.$file.sha512
        curl https://artifacts.elastic.co/downloads/beats/$app-$version-$platform-x86_64.$file.asc --create-dirs --output downloads/beats/$app-$version-$platform-x86_64.$file.asc
        continue  # read next file and skip the cp command
      done
      for artifact_type in "${artifact_type[@]}"
      do
        file=tar.gz
        echo $file
        echo "$platform"
        echo $artifact_type
        curl https://artifacts.elastic.co/downloads/$artifact_type-$version-$platform-x86_64.$file --create-dirs --output downloads/$artifact_type-$version-$platform-x86_64.$file
        curl https://artifacts.elastic.co/downloads/$artifact_type-$version-$platform-x86_64.$file.sha512 --create-dirs --output downloads/$artifact_type-$version-$platform-x86_64.$file.sha512
        curl https://artifacts.elastic.co/downloads/$artifact_type-$version-$platform-x86_64.$file.asc --create-dirs --output downloads/$artifact_type-$version-$platform-x86_64.$file.asc
        continue  # read next file and skip the cp command
      done
    fi
  echo $zone
done


export ENDPOINT_VERSION=$version && wget -P downloads/endpoint/manifest https://artifacts.security.elastic.co/downloads/endpoint/manifest/artifacts-$version.zip && zcat -q downloads/endpoint/manifest/artifacts-$version.zip | jq -r '.artifacts | to_entries[] | .value.relative_url' | xargs -I@ curl "https://artifacts.security.elastic.co@" --create-dirs -o ".@"
