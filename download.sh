#!/bin/bash
echo Currently Supports 'elastic-agent' 'heartbeat' 'filebeat' 'packetbeat' 'auditbeat' 'osquerybeat', 'fleet-server' 'cloudbeat' 'endpoint-dev' 'apm-server' ONLY!
source /opt/variables.env

if [[ -z $NGINX_VERSION || -z $STACK_VERSION ]];
then
  echo "NGINX Version = "$NGINX_VERSION
  echo "Elastic Version = "$STACK_VERSION
  echo "One or more variables are unset. Update 'variables.env'."
  exit 1 
fi


cd /usr/share/nginx/html

ARTIFACT_DOWNLOADS_BASE_URL=https://artifacts.elastic.co/downloads

DOWNLOAD_BASE_DIR=downloads

COMMON_PACKAGE_PREFIXES="apm-server/apm-server beats/auditbeat/auditbeat beats/elastic-agent/elastic-agent beats/filebeat/filebeat beats/heartbeat/heartbeat beats/metricbeat/metricbeat beats/osquerybeat/osquerybeat beats/packetbeat/packetbeat cloudbeat/cloudbeat endpoint-dev/endpoint-security fleet-server/fleet-server"

WIN_ONLY_PACKAGE_PREFIXES="beats/winlogbeat/winlogbeat"

RPM_PACKAGES="beats/elastic-agent/elastic-agent"
DEB_PACKAGES="beats/elastic-agent/elastic-agent"

function download_packages() {
  local url_suffix="$1"
  local package_prefixes="$2"

  local _url_suffixes="$url_suffix ${url_suffix}.sha512 ${url_suffix}.asc"
  local _pkg_dir=""
  local _dl_url=""

  for _download_prefix in $package_prefixes; do
    for _pkg_url_suffix in $_url_suffixes; do
          _pkg_dir=$(dirname ${DOWNLOAD_BASE_DIR}/${_download_prefix})
          _dl_url="${ARTIFACT_DOWNLOADS_BASE_URL}/${_download_prefix}-${_pkg_url_suffix}"
          (mkdir -p $_pkg_dir && cd $_pkg_dir && curl -O "$_dl_url")
    done
  done
}

# and we download
for _os in linux windows; do
  case "$_os" in
    linux)
      PKG_URL_SUFFIX="${STACK_VERSION}-${_os}-x86_64.tar.gz"
      ;;
    windows)
      PKG_URL_SUFFIX="${STACK_VERSION}-${_os}-x86_64.zip"
      ;;
    *)
      echo "[ERROR] Something happened"
      exit 1
      ;;
  esac

  download_packages "$PKG_URL_SUFFIX" "$COMMON_PACKAGE_PREFIXES"

  if [[ "$_os" = "windows" ]]; then
    download_packages "$PKG_URL_SUFFIX" "$WIN_ONLY_PACKAGE_PREFIXES"
  fi

  if [[ "$_os" = "linux" ]]; then
    download_packages "${STACK_VERSION}-x86_64.rpm" "$RPM_PACKAGES"
    download_packages "${STACK_VERSION}-amd64.deb" "$DEB_PACKAGES"
  fi
done

export ENDPOINT_VERSION=$STACK_VERSION && wget -P downloads/endpoint/manifest https://artifacts.security.elastic.co/downloads/endpoint/manifest/artifacts-$ENDPOINT_VERSION.zip && zcat -q downloads/endpoint/manifest/artifacts-$ENDPOINT_VERSION.zip | jq -r '.artifacts | to_entries[] | .value.relative_url' | xargs -I@ curl "https://artifacts.security.elastic.co@" --create-dirs -o ".@"
