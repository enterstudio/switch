FROM openjdk:7-jre

MAINTAINER "Cloud Computing Group - University of Ljubljana"

#----SETUP OF MONITORING AGENT----
RUN apt-get update \ 
    && DEBIAN_FRONTEND=noninteractive apt-get install -y wget \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y unzip

#change the workdir
WORKDIR /root

#download and unzip the .zip file
RUN wget https://www.dropbox.com/s/fe1y9lmuhtrn5kl/JCatascopia-Agent-0.0.1-SNAPSHOT.zip | tr -d '\r' \
    && unzip JCatascopia-Agent-0.0.1-SNAPSHOT

#----EXPOSE THE PORTS, CONFIGURE AND START THE SCRIPT WHICH SHOULD START THE MONITORING AGENT (or other component)----
#expose the ports of monitoring agent
EXPOSE 4242 4245

#configure and start monitoring agent (or components) with an external script
COPY /start.sh /root/start.sh 
RUN chmod 777 /root/start.sh


COPY /RTPproxyPortsProbe.jar /root/JarFiles/RTPproxyPortsProbe.jar
COPY /agent.properties /root/JCatascopia-Agent-0.0.1-SNAPSHOT/JCatascopiaAgentDir/resources/agent.properties

#we will use ENTRYPOINT so that: 1) the /root/start.sh script will be always called and user cannot override this 2) the user can specify any number of input parameters to this script
#if you look at the start.sh script you will see that it can take --hostIP and --monitoringServerIP parameters (but if you do not give them, script will use "defaults")
ENTRYPOINT ["/root/start.sh"]

