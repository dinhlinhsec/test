#!/bin/bash
MODE=$1
export WAZUH_AGENT_NAME=$2
export WAZUH_AGENT_GROUP=$3
export WAZUH_MANAGER='connect.vadar.vn'
export WAZUH_MANAGER_PORT='15141'
export WAZUH_REGISTRATION_SERVER='connect.vadar.vn' 
export WAZUH_REGISTRATION_PORT='15151'
source /etc/os-release; OS=$NAME

case $MODE in
	
	-i | install) 
		if [[ "$OS" = "CentOS Linux" || "$OS" = "Oracle Linux Server" ]];
		then
			EXIST=$(rpm -qa | grep wazuh)
			echo "Checking if agent have been installed before..."
			if [ ${#EXIST} -eq 0 ];
			then
				echo "Starting to install VADAR agent..."
				yum install -y https://packages.wazuh.com/4.x/yum5/x86_64/wazuh-agent-4.3.9-1.el5.x86_64.rpm >/dev/null 2>&1
				CHECK=$(rpm -qa | grep wazuh)
				if [ ${#CHECK} -eq 0 ];
				then
					echo "Install failed, please check internet connection or use -o to offline install!"
				else
					echo "VADAR agent install successfully!"
					mv /usr/lib/systemd/system/wazuh-agent.service /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
					sed -i 's/\<Description=Wazuh agent\>/Description=VADAR agent/' /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
					systemctl daemon-reload
					systemctl enable vadar-agent
					systemctl start vadar-agent
					echo "VADAR agent started!"
				fi
			else
				echo "VADAR agent is already installed on this endpoint!"
			fi
		elif [ "$OS" = "Ubuntu" ];
		then
			EXIST=$(apt-cache search wazuh | grep -o "wazuh-agent")
			echo "Checking if agent have been installed before..."
			if [ ${#EXIST} -eq 0 ];
			then
				echo "Starting to install VADAR agent..."
				curl -so wazuh-agent-4.3.9.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.3.9-1_amd64.deb
				dpkg -i ./wazuh-agent-4.3.9.deb >/dev/null 2>&1
				rm -f ./wazuh-agent-4.3.9.deb
				CHECK=$(apt-cache search wazuh | grep -o "wazuh-agent")
				if [ ${#CHECK} -eq 0 ];
				then 
					echo "Install failed, please check internet connection or use -o to offline install!"
				else
					echo "VADAR agent install successfully!"
					mv /usr/lib/systemd/system/wazuh-agent.service /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
					sed -i 's/\<Description=Wazuh agent\>/Description=VADAR agent/' /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
					systemctl daemon-reload
					systemctl enable vadar-agent
					systemctl start vadar-agent
					echo "VADAR agent started!"
				fi
			else
				echo "VADAR agent is already installed on this endpoint!"
			fi
		fi
	;;
	
	-u | uninstall)
		if [[ "$OS" = "CentOS Linux" || "$OS" = "Oracle Linux Server" ]];
		then
			EXIST=$(rpm -qa | grep wazuh)
			echo "Checking if agent have been installed before..."
			if [ ${#EXIST} -eq 0 ];
			then
				echo "Nothing to uninstall!"
			else
				echo "Starting to uninstall VADAR agent..."
				systemctl disable vadar-agent
				systemctl stop vadar-agent
				yum -y remove wazuh-agent >/dev/null 2>&1
				rm -f /usr/lib/systemd/system/vadar-agent.service
				systemctl daemon-reload
				echo "VADAR agent uninstall successfully!!"
			fi
		elif [ "$OS" = "Ubuntu" ];
		then
			EXIST=$(apt-cache search wazuh | grep -o "wazuh-agent")
			echo "Checking if agent have been installed before..."
			if [ ${#EXIST} -eq 0 ];
			then
				echo "Nothing to uninstall!"
			else
				echo "Starting to uninstall VADAR agent..."
				systemctl disable vadar-agent
				systemctl stop vadar-agent
				apt-get purge -y wazuh-agent >/dev/null 2>&1
				rm -f /usr/lib/systemd/system/vadar-agent.service
				systemctl daemon-reload
				echo "VADAR agent uninstall successfully!!"
			fi
		fi
	;;

	-o | offline-install)
		PATH=$4
		if [[ "$OS" = "CentOS Linux" || "$OS" = "Oracle Linux Server" ]];
		then
			yum install ${PATH} > /dev/null 2>&1
			echo "VADAR agent install successfully!"
			mv /usr/lib/systemd/system/wazuh-agent.service /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
			sed -i 's/\<Description=Wazuh agent\>/Description=VADAR agent/' /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
			systemctl daemon-reload
			systemctl enable vadar-agent
			systemctl start vadar-agent
			echo "VADAR agent started!"
		elif [ "$OS" = "Ubuntu" ];
		then
			dpkg -i ${PATH}
			echo "VADAR agent install successfully!"
			mv /usr/lib/systemd/system/wazuh-agent.service /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
			sed -i 's/\<Description=Wazuh agent\>/Description=VADAR agent/' /usr/lib/systemd/system/vadar-agent.service >/dev/null 2>&1
			systemctl daemon-reload
			systemctl enable vadar-agent
			systemctl start vadar-agent
			echo "VADAR agent started!"
		fi
	;;

	
	-h | help)
		echo "vadar-installer [-i install] | [-u uninstall] | [-o offline-install] | [-h help]"
		echo "Usage:"
		echo -e "\t -i install [name] [group] e.g: ./vadar-installer.sh -i test_agent default" 
		echo -e "\t -o offline-install [path-to-file] [name] [group] e.g: ./vadar-installer.sh -o test_agent default /absolute/path/to/vadar-agent.deb"
		echo -e "\t -u uninstall"
		exit 1
	;;

	*)  
		echo "Command not found, please use [./vadar-installer.sh -h | help] option"
		exit 1
	;; 
esac


