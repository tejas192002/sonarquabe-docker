FROM centos

# Install MySQL repository and JDK
RUN rpm -ivh http://repo.mysql.com/mysql57-community-release-el7.rpm && \
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 && \
    yum install -y wget && \
    wget https://download.bell-sw.com/java/11.0.4/bellsoft-jdk11.0.4-linux-amd64.rpm && \
    rpm -ivh bellsoft-jdk11.0.4-linux-amd64.rpm && \
    rm bellsoft-jdk11.0.4-linux-amd64.rpm && \
    yum install -y unzip
RUN wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.1.zip /opt/
WORKDIR /opt/
RUN unzip ~/sonarqube-7.9.1.zip
RUN mv sonarqube-7.9.1 sonar
WORKDIR /root/
RUN sed -i -e '/^sonar.jdbc.username/ d' -e '/^sonar.jdbc.password/ d' -e '/^sonar.jdbc.url/ d' -e '/^sonar.web.host/ d' -e '/^sonar.web.port/ d' /opt/sonar/conf/sonar.properties
RUN sed -i -e '/#sonar.jdbc.username/ a sonar.jdbc.username=sonarqube' -e '/#sonar.jdbc.password/ a sonar.jdbc.password=Redhat@123' -e '/InnoDB/ a sonar.jdbc.url=jdbc.mysql://172.17.0.2:3306/sonarqube?useUnicode=true&characterEncoding=utf&rewriteBatchedStatements=true&useConfigs=maxPerformance' -e '/#sonar.web.host/ a sonar.web.host=0.0.0.0' /opt/sonar/conf/sonar.properties
RUN useradd sonar
RUN chown sonar:sonar /opt/sonar/ -R
WORKDIR /opt/sonar/bin/linux-x86-64/
CMD ["./catalina.sh", "start"]

