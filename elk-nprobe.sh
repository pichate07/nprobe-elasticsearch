#!/bin/bash
#
# ntop.org & qxip.net - Experimental nProbe + ELQ Installer + nProbe custom dashboards
#
# Description: 
#    This script will automatically install and configure nProbe + Logstash, Elasticsearch 
#    and Qbana on a single node/server to facilitate testing and prototyping with nProbe. 
#    The script also installs some nProbe specific dashboards as starting point for users
#    to begin modeling their own datasets and dashboards based on nProbe generated metrics.
#
#    THIS SCRIPT IS IN ALPHA STAGE: USE AT YOUR OWN RISK!
#    SUGGESTED OPERATING SYSTEM: UBUNTU SERVER 14.04

VERS='1.03'
f
CWD=$(pwd)

# Determine OS
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/lsb-release ]; then
    # Ubuntu
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Debian
    OS=Debian  
    VER=$(cat /etc/debian_version)
    #echo "$OS/$VER temporarily unsupported! check back soon!"
    #exit 0;
else
    OS=$(uname -s)
    VER=$(uname -r)
    echo "$OS/$VER not yet supported!"
    exit 0;
fi

echo "  ...............................................   "
echo " ..................................................  "
echo " .................   .............................,. "
echo " .................   .............................,. "
echo " ....... '.    ..     '...    ..... .'   .........,. "
echo " ,,,,,,         '      ..      ',,        ,,,,,,,,,. "
echo " ,,,,,,    .'   ,      ,        ,,         ,,,,,,,,. "
echo " ,,,,,,   ,,,   ,,   ,,.   ,,.  ',   ,,,   ,,,,,,,,. "
echo " ,,,,,,   :::   ::   ::'  ::::   :   :::,  .,,,,,,,. "
echo " ,:::::   :::   ::   ::   ::::   :   ::::  .:::::,,. "
echo " ::::::   :::   ::   ::.  ,:::   :   :::'  :::::::,. "
echo " ::::::   :::   ::   :::   .,   ::    ,'   :::::::,. "
echo " ::::::   :::   ::   :::'       ::        .:::::::,. "
echo " :::::::  ::::  :::  ::::'     :::       .::::::::,. "
echo " :::::::::::::::::::::::::::::::::   :::::::::::::,. "
echo " :::::::::::::::::::::::::::::::::   :::::::::::::,. "
echo " :::::::::::::::::::::::::::::::::  .:::::::::::::,. "
echo "  ,::::::::::::::::::::::::::::::::::::::::::::::,.  "
echo
echo "   ntop.org - Local nProbe + ELQ Installer (v$VERS)"
echo "              os: $OS/$VER"
echo
echo "## Would you like to install nProbe (unlicensed)? [y/N]: "
    read  setNPROBE
    case $setNPROBE in
        Y|y)
            # OS IF
            if [ "$OS" == "Ubuntu" ]; then
                lsb=$(lsb_release -r | awk '{print $2}');
                # use new ntop ubuntu deb package
                echo 'Installing nProbe from ntop Ubuntu $lsb repository...'
                sudo wget http://www.nmon.net/apt/$lsb/all/apt-ntop.deb
                sudo dpkg -i apt-ntop.deb
                sudo apt-get update
                sudo apt-get install -y --force-yes pfring nprobe
                sudo rm -rf ./apt-ntop.deb
                echo "## Would you like to install ZC drivers? [Y/n]: "
                read  setZC
                case $setZC in
                    Y|y)
                    sudo apt-get install -y --force-yes pfring-drivers-zc-dkms
                    ;;
                    N|n|*)
                    echo
                    ;;
                esac
                echo "## Would you like to install DNA drivers? [Y/n]: "
                read  setZC
                case $setZC in
                    Y|y)
                    sudo apt-get install -y --force-yes pfring-drivers-dna-dkms
                    ;;
                    N|n|*)
                    echo
                    ;;
                esac
    
                echo "## Would you like to install Maxmind GeoIP data files? [y/N]: "
                read  setMAX
                case $setMAX in
                    Y|y)
                    echo "Installing Maxmind GeoIP...."
                    cd /tmp
                    #wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz
                    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
                    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
                    #wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
                    gunzip Geo*
                    if [ ! -d "/usr/local/nprobe" ]; then
                        sudo mkdir /usr/local/nprobe
                    fi
                    sudo mv Geo*.dat /usr/local/nprobe/
                    ;;
                    n|N|*)
                    echo "Skipping Maxmind..."
                    ;;
                esac
                
            elif [ "$OS" == "Debian" ]; then
                echo 'Installing base packages...'
                echo 'Installing nProbe from ntop $OS $VER repository...'
                $sudo wget http://www.nmon.net/apt/7.6/all/apt-ntop.deb
                $sudo dpkg -i apt-ntop.deb
                $sudo apt-get clean all
                $sudo apt-get update
                $sudo apt-get install -y --force-yes pfring nprobe
                $sudo rm -rf ./apt-ntop.deb
                
                echo "## Would you like to install Maxmind GeoIP data files? [y/N]: "
                read  setMAX
                case $setMAX in
                    Y|y)
                    echo "Installing Maxmind GeoIP...."
                    cd /tmp
                    wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz
                    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
                    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
                    wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
                    gunzip Geo*
                    if [ ! -d "/usr/local/nprobe" ]; then
                        mkdir /usr/local/nprobe
                    fi
                    mv Geo*.dat /usr/local/nprobe/
                    ;;
                    n|N|*)
                    echo "Skipping Maxmind..."
                    ;;
                esac
            fi
            # END IF
            
            
            echo "nProbe Installation complete!"
            echo
            NPROBE='YES'
            ;;
        N|n|*)
            echo "Skipping nProbe Installation...."
            ;;
    esac

echo "## Would you like to install a local ELQ? [y/N]: "
    read  setELK
    case $setELK in
        Y|y)
            echo "Installing ELQ...."
            # ubuntu 
            if [ "$OS" == "Ubuntu" ]; then
            echo 'Installing required ubuntu packages...'
            sudo='sudo'
                sudo wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
                sudo add-apt-repository 'deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main'
                #sudo add-apt-repository 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' 
                sudo apt-get update
                sudo apt-get install -y --force-yes default-jdk ruby ruby1.9.1-dev libcurl4-openssl-dev apache2 apache2-utils libzmq-dev redis-server
            elif [ "$OS" == "Debian" ]; then
            echo 'Installing required debian packages...'
                sudo=''
                wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
                #wget -O /tmp/esgpg.key http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add /tmp/esgpg.key && rm -rf /tmp/esgpg.key
                echo 'deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main' > /etc/apt/sources.list.d/elk.list
                #echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' >> /etc/apt/sources.list.d/elk.list
                apt-get update
                apt-get install -y --force-yes default-jdk ruby ruby1.9.1-dev libcurl4-openssl-dev apache2 libzmq-dev redis-server
            fi
            ################################## ELK #################################
            echo 'Install Pre-Reqs and EL from elasticsearch repository'
            cd /usr/src
            # $sudo apt-get install -y --force-yes elasticsearch logstash
            $sudo apt-get install -y --force-yes elasticsearch
            $sudo update-rc.d elasticsearch defaults 95 10
            echo 'Configuring Elasticsearch'
            if [ ! -d "/var/data" ]; then  
                $sudo mkdir /var/data/
            fi
            if [ ! -d "/var/data/elasticsearch" ]; then  
                $sudo mkdir /var/data/elasticsearch
            fi
            if [ ! -d "/var/data/elasticsearch/tmp" ]; then  
                $sudo mkdir /var/data/elasticsearch/tmp
            fi
            $sudo chmod -R 777 /var/data/elasticsearch
            
            # adjust settings for single nodes
            $sudo cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.bak
            #regexp='^[ \t]*index.number_of_shards[ \t]*:.*'
            #line='index.number_of_shards: 1'
            #$sudo sed -i "s#$regexp#$line#g" /etc/elasticsearch/elasticsearch.yml
            #regexp='^[ \t]*index.number_of_replicas[ \t]*:.*'
            #line='index.number_of_replicas: 0'
            #$sudo sed -i "s#$regexp#$line#g" /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\cluster.name: elk' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\node.name: "elastic-master"' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\node.master: true' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\node.data: true' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\path.data: /var/data/elasticsearch' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\path.work: /var/data/elasticsearch/tmp' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\path.logs: /var/log/elasticsearch' /etc/elasticsearch/elasticsearch.yml
             $sudo sed -i '$a\index.number_of_shards: 1' /etc/elasticsearch/elasticsearch.yml
             $sudo sed -i '$a\index.number_of_replicas: 0' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\discovery.zen.ping.multicast.enabled: false' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\discovery.zen.ping.unicast.hosts: ["127.0.0.1:[9300-9400]"]' /etc/elasticsearch/elasticsearch.yml
            # $sudo sed -i '$a\bootstrap.mlockall: true' /etc/elasticsearch/elasticsearch.yml
            cd /tmp

            # echo 'Create grok pattern folder'
            # if [ ! -d "/etc/logstash/patterns" ]; then
            #     $sudo mkdir -p /etc/logstash/patterns
            # fi
            # git clone https://github.com/logstash/logstash
            # $sudo cp logstash/patterns/* /etc/logstash/patterns/
            # rm -rf logstash
            # echo 'Remember to set you patterns_dir to "/etc/logstash/patterns" (i.e. patterns_dir => "/etc/logstash/patterns")'
            ################################# Qbana ################################
            echo 'Installing the Qbana frontend...'
            cd /usr/src
            # We use the Packetbeat fork in this version
            if [ "$OS" == "Debian" ]; then
                $sudo git clone https://github.com/QXIP/Qbana.git qbana
                $sudo mkdir /var/www/qbana
                $sudo mv qbana/src/* /var/www/qbana
            elif [ "$OS" == "Ubuntu" ]; then
                $sudo git clone https://github.com/QXIP/Qbana.git qbana
                $sudo mkdir /var/www/html/qbana
                $sudo mv qbana/src/* /var/www/html/qbana
            fi
            ############################# nprobe ELK ################################
            echo 'Configuring nProbe ELQ...'
            cd $CWD
            # $sudo cp logstash/conf.d/* /etc/logstash/conf.d/
            
            # Sys. Misc Optimize
            $sudo sh -c "ulimit -l unlimited"
            $sudo sh -c "ulimit -n 999999" 
            
            #disable logstash-web, just in case...
            # $sudo update-rc.d logstash-web disable
            # $sudo service logstash-web stop
            # $sudo rm -rf /etc/init/logstash-web.conf 
            
            echo 'Restarting ELQ..'
            $sudo service elasticsearch restart
            # $sudo /etc/init.d/logstash restart
            
            # Let's give it a sec to start
            echo "Waiting for services to start... "
            sleep 20
            
            cd $CWD
            # Installing optional .htaccess for qbana
            echo "## Would you like to password protect Qbana [y/N]: "
            read  setELK
            case $setELK in
                Y|y)
                # Create pass
                echo "Please choose a username:"
                read kUSER
                echo "Please choose a password for user $kUSER:"
                $sudo htpasswd -c /var/elk.htpasswd $kUSER
                
                if [ "$OS" == "Debian" ]; then
                    HTFILE="/var/www/qbana/.htaccess"
                elif [ "$OS" == "Ubuntu" ]; then
                    HTFILE="/var/www/html/qbana/.htaccess"
                fi
                if [ -f "/var/elk.htpasswd" ]; then
                    $sudo echo "AuthType Basic" > $HTFILE
                    $sudo echo "AuthName 'nProbe ELK'" >> $HTFILE
                    $sudo echo "AuthUserFile /var/elk.htpasswd" >> $HTFILE
                    $sudo echo "Require valid-user" >> $HTFILE
                    echo
                    echo "Authentication set in: $HTFILE with access defined in /var/elk.htpasswd"
                else
                    echo "Could not set authentication! Please configure .htaccess manually."
                fi
                ;;
                N|n|*)
                # no password
                echo "No password - Please do manually protect your server!"
                ;;
            esac

            
            echo "Installing maintenance scripts/tools for ES indexes..."
            cd /usr/src
            $sudo git clone https://github.com/QXIP/elasticsearch-logstash-index-mgmt
            $sudo cp elasticsearch-logstash-index-mgmt/*.sh /usr/local/bin/
            $sudo rm -rf elasticsearch-logstash-index-mgmt*
            cd $CWD
            #cp -r 
            
            # All Done
            localip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
            echo "ELK Installation complete!"
            echo
            echo -e "Start nprobe and connect to http://$localip/qbana"

            

            ;;
        N|n|*)
            echo "Skipping ELQ Installation...."
            if [ "$NPROBE" == "Y" ]; then
                echo "* To install the nprobe template, copy logstash/conf.d/nprobe.conf to your Logstash(es)."
                echo "* To install your own Qbana: https://github.com/QXIP/Qbana.git"
                echo
            fi
            ;;
    esac
    
    echo "## Would you like to start a local nProbe w/ default template? [y/N]: "
        read  startNP
        case $startNP in
            Y|y)
                echo "Starting nProbe in background..."
                $sudo nprobe -b 0 -i any --json-labels -t 60 --redis localhost --elastic "nProbe;nprobe;http://127.0.0.1:9200/_bulk" -T "%IPV4_SRC_ADDR %L4_SRC_PORT %IPV4_DST_ADDR %L4_DST_PORT %PROTOCOL %IN_BYTES %OUT_BYTES %FIRST_SWITCHED %LAST_SWITCHED %IN_PKTS %OUT_PKTS %IP_PROTOCOL_VERSION %APPLICATION_ID %L7_PROTO_NAME %ICMP_TYPE %SRC_IP_COUNTRY %DST_IP_COUNTRY %APPL_LATENCY_MS" -G
                ;;
            N|n|*)
                echo "Do not forget to start a local or remote nProbe to start injecting data to your ELQ."
                ;;
        esac
echo
echo "## All Done! Exiting..."
exit 0;
