#!/bin/bash

#If there are parameters, synopsis: --hostIP=X.Y.Z.W --monitoringServerIP=A.B.C.D
while [[ $# -gt 0 ]]
do
	arg="${1}"

	key="${arg%%=*}"     	# Extract key.
    value="${arg##*=}"		# Extract value.

	case "${key}" in
		--hostIP)
			ARG_HOSTIP="${value}"
		;;
        --monitoringServerIP)
			ARG_MONSERV="${value}"
		;;
        *) echo "Unknown option" >&2
		exit 1
		esac
	shift
done
#---THE PUBLICALY ROUTABLE IP OF THE HOST MACHINE WHERE CONTAINER IS RUNNING: $HOST_IP---
#For the configuration of JCatascopia agent, the publicly routable IP of the host machine is needed.
#The user can provide the IP when running the script (--hostIP option).
#But if the user does not provide HOST_IP, it is needed to obtain this IP where the container is running programatically
HOST_IP=$ARG_HOSTIP
if [[ -z "$ARG_HOSTIP" ]]
then
    echo "WARNING: USER DID NOT PROVIDE PUBLICALY ROUTABLE IP OF THE HOST MACHINE WHERE CONTAINER WILL RUN. TRYING TO FIND OUT THIS IP WITH https://api.apify.org!"
    HOST_IP=`curl -s https://api.ipify.org`
    if [[ -z "$HOST_IP" ]]
	then
		echo "FATAL: USER DID NOT PROVIDE HOST IP. WHEN TRYING TO DETERMINE IP OF HOST AUTOMATICALLY THE METHOD FAILED. THE PROGRAM WILL EXIT!"
		exit 1
    fi
fi
#Now it is needed to set an environment variable called DOCKER_HOST.
#So the Agent is capable of publishing the IP of the host
export DOCKER_HOST=$HOST_IP
#---THE IP OF THE MONITORING SERVER: $MONITORING_SERVER_IP---
#Monitoring agent needs to know where the monitoring server is running.
#Because, it wants to register itself in the monitoring server and then continuously sends the measured values to the monitoring server
#Obtaining the IP of monitoring server from the user, if the user did not provide it, then use the default monitoring server
MONITORING_SERVER_IP=$ARG_MONSERV
if [[ -z "$ARG_MONSERV" ]]
then
    echo "WARINING: USER DID NOT PROVIDE MONITORING SERVER IP. DEFAULT VALUE WILL BE USED!"
    MONITORING_SERVER_IP=194.249.0.192
fi

#Install JCatascopia-Agent
JCATASCOPIA_AGENT_DIRECTORY="./" #".\\/"
JCATASCOPIA_AGENT_HOME="./" #".\\/"

cd /root/JCatascopia-Agent-0.0.1-SNAPSHOT
chmod  x installer.sh
#Replace all DEST=.* in file installer.sh with DEST=$JCATASCOPIA_AGENT_DIRECTORY (and the $JCATASCOPIA_AGENT_DIRECTORY is a variable defined above)
eval "sed -i 's/DEST=.*/DEST=$JCATASCOPIA_AGENT_DIRECTORY/g' ./installer.sh"
#Now run the modified installer script
./installer.sh
cd  JCatascopiaAgentDir
chmod  x resources/agent.properties
#In file resources/agent.properties, it is needed to replace server_ip=.* with server_ip=$MONITORING_SERVER_IP (and the MONITORING_SERVER_IP is a variable defined above)
eval "sed -i 's/server_ip=.*/server_ip=$MONITORING_SERVER_IP/g' resources/agent.properties"
chmod  x JCatascopia-Agent-start.sh
#in file JCatascopia-Agent-start.sh, it is needed to replace any JCATASCOPIA_AGENT_HOME=.* with JCATASCOPIA_AGENT_HOME=$JCATASCOPIA_AGENT_HOME (and $JCATASCOPIA_AGENT_HOME is a variable defined above)
eval "sed -i 's/JCATASCOPIA_AGENT_HOME=.*/JCATASCOPIA_AGENT_HOME=$JCATASCOPIA_AGENT_HOME/g' JCatascopia-Agent-start.sh"

#Originally we would call the JCatascopia-Agent-start.sh script
#./JCatascopia-Agent-start.sh
#But we will instead copy the code from the script here (this is because sometimes we may need the control of starting the process in foreground)
JAR="JCatascopia-Agent-0.0.1-SNAPSHOT.jar"
JCATASCOPIA_LOCK="/var/lock/JCatascopia-Agent-lock"
#If we would like to run the monitoring agent in foreground and force to use it PID1 (give the PID from the script to the program) then we should issue below command
exec java -jar $JCATASCOPIA_AGENT_HOME/$JAR  $JCATASCOPIA_AGENT_HOME $JCATASCOPIA_LOCK
#We put exec so the process gets the PID1 - in this way we will be able to kill the container (if run in foreground) with Ctrl   C commnad
#But, if we have other application to run, we run the monitoirng agent in background
#If we want to run the monitoring agent in background then we should issue below command
#The & character at the end of java call means that the java process will be started in background
#java -jar $JCATASCOPIA_AGENT_HOME/$JAR  $JCATASCOPIA_AGENT_HOME $JCATASCOPIA_LOCK &
#------------------------
