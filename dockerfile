FROM centos
RUN rpm -ivh http://repo.mysql.com/mysql57-community-release-el7.rpm 
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
RUN yum install wget epel-release -y
RUN wget https://download.bell-sw.com/java/11.0.4/bellsoft-jdk11.0.4-linux-amd64.rpm
RUN rpm -ivh bellsoft-jdk11.0.4-linux-amd64.rpm
RUN echo 'vm.max_map_count=262144' >/etc/sysctl.conf
RUN sysctl -p
RUN echo '* - nofile 80000' >>/etc/security/limits.conf
RUN sed -i -e '/query_cache_size/ d' -e '$ a query_cache_size = 15M' /etc/my.cnf
RUN yum install unzip -y
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












FROM centos:7
RUN yum install java-11-openjdk -y
ADD https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.98/bin/apache-tomcat-8.5.98.tar.gz ./
RUN tar -xzf apache-tomcat-8.5.98.tar.gz -C /opt/ && \
    rm -rf ./apache-tomcat-8.5.98.tar.gz
WORKDIR /opt/apache-tomcat-8.5.98
COPY  context.xml conf/context.xml
ADD https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar lib/mysql-connector.jar
COPY student.war webapps/student.war
EXPOSE 8080
CMD ["./bin/catalina.sh", "run"]