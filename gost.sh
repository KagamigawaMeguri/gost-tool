#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

filepath=$(cd "$(dirname "$0")"; pwd)
file_1=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')

gost_file="/usr/local/sbin/gost"
gost_conf="/root/gost.json"
demain_conf="/root/demain.conf"
gost_log="/root/gost.log"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

check_sys(){
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    bit=`uname -m`
}

check_installed_status(){
    [[ ! -e ${gost_file} ]] && echo -e "${Error} Gost 没有安装，请检查 !" && exit 1
}

Install_gost(){
	[[ -e ${gost_file} ]] && echo -e "${Error} 检测到 Gost 已安装 !" && exit 1
    # 默认AMD64
    gost_url="https://github.com/ginuerzh/gost/releases/download/v2.10.0/gost-linux-amd64-2.10.0.gz"
    wget $gost_url -O gost.gz && gunzip gost.gz && mv gost /usr/local/sbin
	chmod +x /usr/local/sbin/gost && cd
	cd /root && wget https://raw.githubusercontent.com/KagamigawaMeguri/gost-tool/master/gost.json && cd
	if [[ ${release} = "centos" ]]; then
		dnf install bind-utils
		yum install bind-utils
		cd /usr/lib/systemd/system
	else
		apt install dnsutils
		cd /etc/systemd/system
	fi
	wget https://raw.githubusercontent.com/KagamigawaMeguri/gost-tool/master/gost.service
    	systemctl enable gost && systemctl restart gost && cd
	echo -e "${Info} Gost 安装完成 ! "
}

check_pid(){
    PID=$(ps -ef| grep "gost"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}')
}

# script start
check_sys
Install_gost
check_pid
echo "${PID}"
