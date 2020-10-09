#!/bin/bash

echo 'check java version(>=8)'
readonly JDK8_VER=52
jdk_ver=ver=$(javap -verbose java.lang.String 2>/dev/null | grep "major version" | cut -d " " -f5)
jdk_ver=$((${jdk_ver:-0} + 0))
echo "- java version: $jdk_ver"
if [ $jdk_ver -eq 0 ]; then
    echo " - Not Found Java"
    exit 1
fi

if [ $jdk_ver -lt $JDK8_VER ]; then
    echo "- Not Support JDK Version"
    exit 2
fi

echo "add apt-key..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -

echo "append source..."
readonly source_file="/etc/apt/sources.list"
readonly jenkins_source_link="deb https://pkg.jenkins.io/debian-stable binary/"
if [ $(grep -q "${jenkins_source_link}" "${source_file}") ]; then
    echo "${jenkins_source_link}" | sudo tee -a "${source_file}"
fi

echo "update and install jenkins"
sudo apt-get update
sudo apt-get install -y jenkins

echo "update path for jdk"
readonly jenkins_start_shell=/etc/init.d/jenkins
original_path_var=$(grep -E '^PATH=' "$jenkins_start_shell" | awk -F 'PATH=' '{print $2}' | tr -d '"')
original_path_var=${original_path_var:-"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"}
echo "- original config path: $original_path_var"
java_exec_home=$(type -p java | awk -F '/java$| ' '{print $1}')
echo "- java exec home: $java_exec_home"
sudo sed "s?^PATH=.*?PATH=\"${original_path_var}:${java_exec_home}\"?" -i "${jenkins_start_shell}"

echo "reload service"
sudo systemctl daemon-reload
sudo systemctl restart jenkins.service
