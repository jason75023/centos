#!/bin/bash
#
#Vizgem agent installation on nagios core server  
#usage:
#1. login to nagios server
#2. bash <(wget -qO - https://raw.githubusercontent.com/jason75023/centos/master/vizgeminstall.sh)
#
# To install ila agent: 1, 2, 4, 5, 6, 7
# To uninstall ila agent: 5, 3, 7
# select 8 to exit program 

checkfiles() {
cd /root

for FILE in ila820lx64.full.tar.gz log-nagios-sl nagios-sl.tar
do 
    if [ ! -f $FILE ]
    then
        echo "File $FILE does not exists, Please download it under /root before continue"
        exit 1
    fi 
done

echo "You have all required files for ila agent setup on nagios server" 
ls -la  ila820lx64.full.tar.gz log-nagios-sl nagios-sl.tar

return
}

installila() {

yum install perl.x86_64
yum install net-snmp.x86_64
yum install net-snmp-libs.x86_64                                                                              
yum install net-snmp-utils.x86_64                                                    

#mkdir –p /opt/app/data/ila

if [!-d /opt/app/data/ila]; then
    mkdir -p /opt/app/data/ila
fi

cp ila820lx64.full.tar /opt/app/data/ila
cd /opt/app/data/ila
tar xvf ila820lx64.full.tar
cd /opt/app/data/ila/bin
/opt/app/data/ila/bin/install

return
}

uninstallila() {
rm -rf /opt/app/data/ila
return 
}


configupdate() {
cd /opt/app/data/ila/stage
cp /root/nagios-sl.tar.Z  /opt/app/data/ila/stage
tar -xzf nagios-sl.tar.Z
cp /root/log-nagios-sl /opt/app/data/ila/stage
/opt/app/data/ila/bin/modin proto-nagios-sl
cd /opt/app/data/ila/cfg

#snmpi file update  
sed -i.old '$,$s/^/#/'  snmpi
echo "SNMPDEST:75.55.96.51:162:public" >> snmpi
echo "SNMPDEST:75.62.48.54:162:public" >> snmpi

#xmit file update 
sed -i.old -e '/SNMP:0/s/0/1/' -e '/SNMPDEST:/s/^/#/' -e '/^#SNMPDEST:/a\
SNMPDEST:75.55.96.51:1162:public\
SNMPDEST:75.62.48.54:1162:public' xmit

#log-nagios-sl file update 
sed -i.old -e '/OUTPUTREGEX/s/^/#/' -e '/LOGFILE/s/^/#/' -e '/#LOGFILE/a\
LOGFILE:/usr/local/nagios/var/nagios.log' log-nagios-sl

#SCHEDULE file update 
sed -i.old '/cklog:-c logsyslog/s/^/#/' SCHEDULE 

return
}

stopila() {
/etc/init.d/ila stop

return
}

startila() {
/etc/init.d/ila start

return
}

checkila() {
ps -ef | grep [i]la

return
}

#
# MAIN program
#
IFS='
'
MENU="
check files before install
install vizgem agent 
uninstall vizgem agent
config vizgem agent 
stop ila process
start ila process
check ila process 
Exit/Stop
"
PS3='Select task:'
select m1 in $MENU
do
case $REPLY in
1) checkfiles;;
2) installila;;
3) uninstallila;;
4) configupdate;;
5) stopila;;
6) startila;;
7) checkila;;
8) exit 0 ;;
esac
done
