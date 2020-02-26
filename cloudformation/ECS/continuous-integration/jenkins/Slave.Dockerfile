FROM jenkins/jnlp-slave

# GID currently in use by AWS EC2 Container Service
ENV DOCKER_GID 497

USER root

RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz && tar --strip-components=1 -xvzf docker-18.06.3-ce.tgz -C /usr/local/bin

RUN groupadd -g ${DOCKER_GID} docker
RUN usermod -G docker jenkins
RUN \
  # install utilities
  apt-get update && apt-get install -y \
     wget \
     curl \
     vim \
     git \
     zip \
     jq \
     python \
     python-pip

RUN pip install awscli

COPY slave-entrypoint.sh /usr/local/bin/slave-entrypoint.sh
RUN chmod +x /usr/local/bin/slave-entrypoint.sh

USER jenkins
ENTRYPOINT ["slave-entrypoint.sh"]
