#! /bin/bash
#auto_connection_wifi 1.0
clear
echo "auto_connection_wifi 1.0"
echo "在任何时候想要退出本脚本请键入Ctrl+c"
echo "有问题请发邮件到helenfrank@protonmail.com,或者issue"
echo -e "github地址： https://github.com/helen-frank/auto_connection_wifi 欢迎各位star,fork\n"
echo "环境须知"
echo "1.可能需要先行连通互联网（如果命令都已安装可离线）,有无线网卡设备"
echo "2.适用于centos7，yum正常配置,其他linux暂时请自行修改测试脚本（主要在于yum和systemctl）"
echo "3.使用root权限运行此脚本，确保一些命令和yum能够正常使用"
echo -e "4.如果没有yum,请自行安装必备命令 killall,wpa_supplicant,dhclient,crontab\n"
echo -e "确认yum能正常使用，请输入y，确认自己必备命令都已正常安装，请输入n:y/n"
read p1
if [ ${p1} = 'y' ]; then
    yum install -y ncurses
    yum install -y vixie-cron
    yum install -y crontabs
    yum install -y wpasupplicant
    yum install -y dhclient
    yum install -y psmisc
fi

clear
echo "auto_connection_wifi 1.0"
echo "在任何时候想要退出本脚本请键入Ctrl+c"
echo "有问题请发邮件到helenfrank@protonmail.com,或者issue"
echo -e "github地址： https://github.com/helen-frank/auto_connection_wifi 欢迎各位star,fork\n"
echo "开始扫描,确保自己的笔记本电脑有wifi网卡"
ip addr | grep wl
echo -e "...\n...\n如果上面没有显示，请确认网卡正常，百度如何安装对应wifi驱动，并键入Ctrl+c退出脚本$1"

clear
echo "auto_connection_wifi 1.0"
echo "在任何时候想要退出本脚本请键入Ctrl+c"
echo "有问题请发邮件到helenfrank@protonmail.com,或者issue"
echo -e "github地址： https://github.com/helen-frank/auto_connection_wifi 欢迎各位star,fork\n"
echo "好的，现在可以继续了，我的wifi无线网卡名是wlp1s0，供参考，输入你的无线网卡名："
read Network_Name
ip link set ${Network_Name} up
ip link show ${Network_Name}
echo -e "\n括号中出现UP,说明驱动已经开启\n"
killall wpa_supplicant
killall dhclient
echo -e "请输wifi SSID(wifi名):"
read Wifi_Name
echo -e "请输入wifi password(wifi密码):"
read Wifi_passwd
wpa_supplicant -B -i ${Network_Name} -c <(wpa_passphrase ${Wifi_Name} ${Wifi_passwd})
while (($? != "successfully initialized wpa_supplicant")); do
    echo -e "请检查自己的wifi SSID:\n${Wifi_Name}\nwifi password:${Wifi_passwd}"
    echo -e "请输入新的wifi SSID:"
    read Wifi_Name
    echo -e "请输入新的Wifi password:"
    read Wifi_passwd
    wpa_supplicant -B -i ${Network_Name} -c <(wpa_passphrase ${Wifi_Name} ${Wifi_passwd})
done
dhclient ${Network_Name}

clear
echo "auto_connection_wifi 1.0"
echo "在任何时候想要退出本脚本请键入Ctrl+c"
echo "有问题请发邮件到helenfrank@protonmail.com,或者issue"
echo -e "github地址： https://github.com/helen-frank/auto_connection_wifi 欢迎各位star,fork\n"
ip addr show ${Network_Name}
ping -c 4 www.baidu.com >/dev/null
if [ $? -ne 0 ]; then
    echo "链接不上互联网，请检查/etc/resolv.conf是否已经配置,wifi是否是wifi6笔记本网卡无法连接到wifi6,wifi是否连通互联网,wifi是否已经分配完ip等等问题（待更多数据实践）"
    echo "如果是/etc/reslov.conf没有配置，请输入y,否则输入n"
    if [ $? == 'y' ]; then
        echo "nameserver 114.114.114.114" >/etc/reslov.conf
        echo "nameserver 8.8.8.8" >>/etc/reslov.conf
        ping -c 4 www.baidu.com >/dev/null
        if [ $? -ne 0 ]; then
            echo "请自行查找上面提到的问题，尝试换手机热点连接等等解决"
            echo "有无法解决的问题请发邮件到helenfrank@protonmail.com,或者issue"
            echo "我尝试解决，不保证一定能$1"
            exit
        fi
    fi
fi

clear
echo "auto_connection_wifi 1.0"
echo "在任何时候想要退出本脚本请键入Ctrl+c"
echo "有问题请发邮件到helenfrank@protonmail.com,或者issue"
echo -e "github地址： https://github.com/helen-frank/auto_connection_wifi 欢迎各位star,fork\n"
echo "当你看到这里的时候，证明已经链接wifi成功了"
echo "现在选择是否要自动连接这个wifi以防止偶尔断连，需要输入y,否则输入n:"
read p2
if [ ${p2} = 'y']; then
    echo "脚本会在你的/root/shell下建立一个reconnection.sh"
    echo "并将其设为每25分钟测试能否连通互联网，断网重连两次（对系统资源占用极小）"
    echo "reconnection.sh会在断网重连时向/mnt/reconnection_log.txt发送重连时间"
    mkdir /root/shell
    touch /root/shell/reconnection.sh
    cat >/root/shell/reconnection.sh <<EOF
#! /bin/bash
. /etc/profile
. ~/.bash_profile
ping -c 1 www.baidu.com > /dev/null
if [ \$? -ne 0 ]; then
        date >> /mnt/reconnection_log.txt
        ip link set ${Network_Name} up
        killall wpa_supplicant
        killall dhclient
        wpa_supplicant -B -i ${Network_Name} -c <(wpa_passphrase ${Wifi_Name} ${Wifi_passwd})
        dhclient ${Network_Name}
        ping -c 1 www.baidu.com > /dev/null
        if [ $? -ne 0 ]; then
                ip link set ${Network_Name} up
                killall wpa_supplicant
                killall dhclient
                wpa_supplicant -B -i ${Network_Name} -c <(wpa_passphrase ${Wifi_Name} ${Wifi_passwd})
                dhclient ${Network_Name}
        fi
fi
EOF
    systemctl restart crond
    systemctl enable crond
    if [ $(grep -c "*/4 * * * * /root/shell/reconnection.sh" /var/spool/cron/root) -ne '0']; then
        ehco "*/4 * * * * /root/shell/reconnection.sh" >>/var/spool/cron/root
    fi
    systemctl reload crond
fi

clear
echo "脚本结束"
echo "github地址： https://github.com/helen-frank/auto_connection_wifi "
echo "最后，还是希望给个star,这样才有动力更新阿，秋泥膏(๑＞ڡ＜)☆"

