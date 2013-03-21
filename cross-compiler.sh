#!/bin/bash

OLDPATH=${PATH}

UpdateBox()
{
   echo "-> Installing apt-get packages"
   aptitude update
   aptitude -y install build-essential
   aptitude -y remove libruby1.8 ruby1.8 ruby1.8-dev rubygems1.8
   aptitude -y install ruby1.9.1-full
   gem install fpm
}

XtoolsArmv5()
{
   if [ ! -d x-tools ]; then 
         echo "-> Installing Cross Compiler ARMv5"
         echo "-> Downloading Cross Compiler ARMv5"
         wget -q http://archlinuxarm.org/builder/xtools/x-tools.tar.xz;
         echo "-> End of Download Cross Compiler ARMv5"
         tar Jxfv x-tools.tar.xz
      else
         echo "Cross Compiler for ARMv5 already installed ..."
   fi
}

XtoolsArmv6()
{
   if [ ! -d x-tools6h ]; then 
         echo "-> Installing Cross Compiler ARMv6"
         echo "-> Downloading Cross Compiler ARMv6"
         wget -q http://archlinuxarm.org/builder/xtools/x-tools6h.tar.xz;
         echo "-> End of Download Cross Compiler ARMv6"
         tar Jxfv x-tools6h.tar.xz
      else
         echo "Cross Compiler for ARMv6 already installed ..."
   fi
}

XtoolsArmv7()
{
   pwd
   if [ ! -d x-tools7h ]; then 
         echo "-> Installing Cross Compiler ARMv7"
         echo "-> Downloading Cross Compiler ARMv7"
         wget -q http://archlinuxarm.org/builder/xtools/x-tools7h.tar.xz;
         echo "-> End of Download Cross Compiler ARMv7"
         tar Jxfv x-tools7h.tar.xz
      else
         echo "Cross Compiler for ARMv7 already installed ..."
   fi
}

DownloadNodeJS()
{
   echo "-> Getting latest node.js version"
   result=$(wget -qO- http://nodejs.org/dist/latest/ | egrep -o 'node-v[0-9\.]+.tar.gz' | tail -1)
   tmp=$(echo $result | egrep -o 'node-v[0-9\.]+')
   mm=$(echo $result | egrep -o '[0-9\.]+')
   majorminor=${mm:0:${#mm} - 3} # chop 3 last chars
   version=${tmp:0:${#tmp} - 1}
   if [ ! -e $result ]; then
         echo "-> Downloading $result"
         wget -q http://nodejs.org/dist/latest/$result
         echo "-> End of Download $result"
         tar xvzf $result
         ln -s $version node
      else
         echo "You already have the latest node.js version : $version"
   fi
}

BuildNodeJSArmv5()
{
   export PATH=/home/vagrant/x-tools/arm-unknown-linux-gnueabi/bin:$PATH
   export TOOL_PREFIX="arm-unknown-linux-gnueabi"
   export CC="${TOOL_PREFIX}-gcc"
   export CXX="${TOOL_PREFIX}-g++"
   export AR="${TOOL_PREFIX}-ar"
   export RANLIB="${TOOL_PREFIX}-ranlib"
   export LINK="${CXX}"
   export CCFLAGS="-march=armv5t -mfpu=softfp -marm"
   export CXXFLAGS="-march=armv5t -mno-unaligned-access"
   export OPENSSL_armcap=5
   export GYPFLAGS="-Darmeabi=soft -Dv8_can_use_vfp_instructions=false -Dv8_can_use_unaligned_accesses=false -Darmv7=0"
   export VFP3=off
   export VFP2=off
   PREFIX_DIR="/usr"
   sudo chown -R vagrant: /home/vagrant/
   cd /home/vagrant/node
   ./configure --without-snapshot --dest-cpu=arm --dest-os=linux --prefix="${PREFIX_DIR}"
   make -j 2
   sudo chown -R vagrant: /home/vagrant/
   make install DESTDIR=/tmp/installARMv5
   fpm -s dir -t deb -n nodejs -v "$majorminor-1vr~squeeze1" --category web -m "Vincent RABAH <vincent.rabah@gmail.com>" --url http://nodejs.org/ \
   --description "Node.js event-based server-side javascript engine Node.js is similar in design to and influenced by systems like Ruby's Event Machine or Python's Twisted. It takes the event model a bit further - it presents the event loop as a language construct instead of as a library. Node.js is bundled with several useful libraries to handle server tasks : System, Events, Standard I/O, Modules, Timers, Child Processes, POSIX, HTTP, Multipart Parsing, TCP, DNS, Assert, Path, URL, Query Strings." \
   -C /tmp/installARMv5 -a armel  -p ../cross-compiler/nodejs_$majorminor-1vr~squeeze1_armel.deb  usr/
   make clean
}

BuildNodeJSArmv6()
{
   export PATH=/home/vagrant/x-tools6h/arm-unknown-linux-gnueabi/bin:$PATH
   export TOOL_PREFIX="arm-unknown-linux-gnueabi"
   export CC="${TOOL_PREFIX}-gcc"
   export CXX="${TOOL_PREFIX}-g++"
   export AR="${TOOL_PREFIX}-ar"
   export RANLIB="${TOOL_PREFIX}-ranlib"
   export LINK="${CXX}"
   export CCFLAGS="-march=armv6j -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
   export CXXFLAGS="-march=armv6j -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
   export OPENSSL_armcap=6
   export GYPFLAGS="-Darmeabi=hard -Dv8_use_arm_eabi_hardfloat=true -Dv8_can_use_vfp3_instructions=false -Dv8_can_use_vfp2_instructions=true -Darm7=0 -Darm_vfp=vfp"
   export VFP3=off
   export VFP2=on
   PREFIX_DIR="/usr"
   sudo chown -R vagrant: /home/vagrant/
   cd /home/vagrant/node
   ./configure --without-snapshot --dest-cpu=arm --dest-os=linux --prefix="${PREFIX_DIR}"
   make -j 2
   sudo chown -R vagrant: /home/vagrant/
   make install DESTDIR=/tmp/installARMv6
   fpm -s dir -t deb -n nodejs -v "$majorminor-1vr~wheeze1" --category web -m "Vincent RABAH <vincent.rabah@gmail.com>" --url http://nodejs.org/ \
   --description "Node.js event-based server-side javascript engine Node.js is similar in design to and influenced by systems like Ruby's Event Machine or Python's Twisted. It takes the event model a bit further - it presents the event loop as a language construct instead of as a library. Node.js is bundled with several useful libraries to handle server tasks : System, Events, Standard I/O, Modules, Timers, Child Processes, POSIX, HTTP, Multipart Parsing, TCP, DNS, Assert, Path, URL, Query Strings." \
   -C /tmp/installARMv6 -a armhf  -p ../cross-compiler/nodejs_$majorminor-1vr~wheezy1_armhf.deb  usr/
   make clean
}

BuildNodeJSArmv7()
{
   export PATH=/home/vagrant/x-tools7h/arm-unknown-linux-gnueabi/bin:$PATH
   export TOOL_PREFIX="arm-unknown-linux-gnueabi"
   export CC="${TOOL_PREFIX}-gcc"
   export CXX="${TOOL_PREFIX}-g++"
   export AR="${TOOL_PREFIX}-ar"
   export RANLIB="${TOOL_PREFIX}-ranlib"
   export LINK="${CXX}"
   export CCFLAGS="-march=armv7-a -mtune=cortex-a8 -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
   export CXXFLAGS="-march=armv7-a -mtune=cortex-a8 -mfpu=vfp -mfloat-abi=hard -DUSE_EABI_HARDFLOAT"
   export OPENSSL_armcap=7
   export GYPFLAGS="-Darmeabi=hard -Dv8_use_arm_eabi_hardfloat=true -Dv8_can_use_vfp3_instructions=true -Dv8_can_use_vfp2_instructions=true -Darm7=1"  
   export VFP3=on
   export VFP2=on
   PREFIX_DIR="/usr"
   sudo chown -R vagrant: /home/vagrant/
   cd /home/vagrant/node
   ./configure --without-snapshot --without-ssl --dest-cpu=arm --dest-os=linux --prefix="${PREFIX_DIR}"
   make -j 2
   sudo chown -R vagrant: /home/vagrant/
   make install DESTDIR=/tmp/installARMv7
   fpm -s dir -t deb -n nodejs -v "$majorminor-1vr~ubuntu1" --category web -m "Vincent RABAH <vincent.rabah@gmail.com>" --url http://nodejs.org/ \
   --description "Node.js event-based server-side javascript engine Node.js is similar in design to and influenced by systems like Ruby's Event Machine or Python's Twisted. It takes the event model a bit further - it presents the event loop as a language construct instead of as a library. Node.js is bundled with several useful libraries to handle server tasks : System, Events, Standard I/O, Modules, Timers, Child Processes, POSIX, HTTP, Multipart Parsing, TCP, DNS, Assert, Path, URL, Query Strings." \
   -C /tmp/installARMv7 -a armhf  -p ../cross-compiler/nodejs_$majorminor-1vr~ubuntu1_armhf.deb  usr/bin usr/lib usr/include usr/share/man
   make clean
}

UpdateBox
DownloadNodeJS
XtoolsArmv5
BuildNodeJSArmv5
cd /home/vagrant/
PATH="$OLDPATH"
XtoolsArmv6
BuildNodeJSArmv6
#cd /home/vagrant/
#PATH="$OLDPATH"
#XtoolsArmv7
#BuildNodeJSArmv7
