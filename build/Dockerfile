ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}
EXPOSE 443
RUN apt-get update
RUN apt-get install -y wget jq unzip
COPY index.html /usr/share/nginx/html/index.html
COPY variables.env /opt/variables.env
COPY download.sh /opt/download.sh
RUN ["chmod", "+x", "/opt/download.sh"]
RUN /opt/download.sh
