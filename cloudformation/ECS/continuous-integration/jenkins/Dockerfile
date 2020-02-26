FROM jenkins/jenkins:2.165

USER root
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz && tar --strip-components=1 -xvzf docker-18.06.3-ce.tgz -C /usr/local/bin

RUN apt-get update -q
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py \
    && pip install ecs-deploy awscli

COPY ./plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY seed-job.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY cloud.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY init.groovy /usr/share/jenkins/ref/init.groovy
COPY jobs/ /usr/share/jenkins/ref/jobs/seed-job/workspace/jobs/

RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion
# ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# drop back to the regular jenkins user - good practice
USER jenkins

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sh","-c", "/usr/local/bin/jenkins.sh"]

