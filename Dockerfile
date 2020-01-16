FROM tomcat:8.0-alpine

COPY sample.war /usr/local/tomcat/webapps/

EXPOSE 8080
