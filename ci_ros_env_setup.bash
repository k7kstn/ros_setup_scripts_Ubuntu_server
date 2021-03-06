#!/bin/bash -exv

### This script is modified from  
###   https://github.com/ryuichiueda/ros_setup_scripts_Ubuntu16.04_server

### bind  Ubuntu ver. - ROS ver. combination
UBUNTU_VER=$(lsb_release -sc)
[ "$UBUNTU_VER" = "precise" ] && ROS_VER=hydro  ### Ubuntu12.04 = Precise
[ "$UBUNTU_VER" = "trusty" ] && ROS_VER=indigo  ### Ubuntu14.04 = Trusty
[ "$UBUNTU_VER" = "xenial" ] && ROS_VER=kinetic ### Ubuntu16.04 = Xenial

echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_VER main" > /tmp/$$-deb
sudo mv /tmp/$$-deb /etc/apt/sources.list.d/ros-latest.list

set +vx
# while ! sudo apt-get install -y curl ; do
while ! sudo apt-get install -y wget ; do
	echo '***WAITING TO GET A LOCK FOR APT...***'
	sleep 1
done
set -vx

# Linux kernel headers  installement
# sudo apt-get install linux-headers-$(uname -r)
### sudo apt-get install linux-headers-3.13.0-32  linux-libc-dev

# resolve certificate error for below wget
sudo apt-get install ca-certificates

# curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
### [ "$UBUNTU_VER" = "precise" ] && CERT_OPT="--no-check-certificate"  ### add this option on Ubuntu 12.04 env ( "precise" )  as the ca-cert package seems old even if updated.
### wget $CERT_OPT  https://packages.ros.org/ros.key | sudo apt-key add -
wget $CERT_OPT  https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
[ "$UBUNTU_VER" = "precise" ] && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5523BAEEB01FA116   ### Ubuntu12.04 = Precise
sudo apt-get update || echo ""

sudo apt-get install -y python-rosinstall-generator
sudo apt-get install -y python-wstool       ### depend unresovable on Ubuntu12.04
# sudo apt-get install -y --force-yes python-rosdistro
sudo apt-get install -y python-rosdistro
# sudo apt-get install -y --force-yes python-rosinstall
sudo apt-get install -y python-rosinstall   ### depend unresovable on Ubuntu12.04
sudo apt-get install -y build-essential

### sudo pip install -U rosinstall  ### this seems to install  rosdistro env as well under dependencies.

### sudo apt-get install -y ros-${ROS_VER}-ros-base
### sudo apt-get install -y --force-yes  ros-${ROS_VER}-ros-base
### sudo aptitude install  ros-${ROS_VER}-ros-base

# [ ! -d /home/magnum/.cache/pip ] && mkdir -p '/home/magnum/.cache/pip'
# sudo chown -R magnum:magnum /home/magnum/.cache/pip*

### Ubuntu 12.04 (Precise)  special routine  as apt-get on ROS does not work well
[ $UBUNTU_VER = "precise" ] && sudo pip install -U rosdep
[ ! $UBUNTU_VER = "precise" ] && sudo apt-get install -y python-rosdep

# sudo apt-get install -y ros-${ROS_VER}-ros
[ ! $UBUNTU_VER = "precise" ] && sudo apt-get install -y ros-${ROS_VER}-ros-base
# sudo apt-get install -y ros-${ROS_VER}-ros-comm

# ls /etc/ros/rosdep/sources.list.d/20-default.list && sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
sudo rosdep init 
rosdep update

#[ "$ROS_VER" = "kinetic" ] && sudo apt-get install -y ros-${ROS_VER}-roslaunch

if [ ! $UBUNTU_VER = "precise" ]; then   ### exclude Ubuntu 12.04 (Precise) env
  grep -F "source /opt/ros/$ROS_VER/setup.bash" ~/.bashrc ||
  echo "source /opt/ros/$ROS_VER/setup.bash" >> ~/.bashrc
fi

grep -F "ROS_MASTER_URI" ~/.bashrc ||
echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc

grep -F "ROS_HOSTNAME" ~/.bashrc ||
echo "export ROS_HOSTNAME=localhost" >> ~/.bashrc


### instruction for user ###
set +xv

echo '***INSTRUCTION*****************'
echo '* do the following command    *'
echo '* $ source ~/.bashrc          *'
echo '* after that, try             *'
echo '* $ LANG=C roscore            *'
echo '*******************************'
