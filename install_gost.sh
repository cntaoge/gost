#!/bin/bash

# ================= 配置区 =================
# 初始安装使用的个人备份仓库地址
MY_REPO_BASE="https://github.com/cntaoge/gost/releases/download"
# 官方 GitHub API 地址（用于检查更新）
OFFICIAL_API="https://api.github.com/repos/go-gost/gost/releases/latest"
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

# 权限检查[cite: 1]
[[ $EUID -ne 0 ]] && echo -e "${RED}错误：${PLAIN} 必须使用 root 用户运行此脚本！\n" && exit 1

# 环境准备[cite: 1]
prepare_env() {
    echo -e "${YELLOW}正在检查并安装必要组件...${PLAIN}"
    if command -v apt-get > /dev/null; then
        apt-get update -y
        apt-get install -y wget curl tar procps iproute2 ca-certificates logrotate
    elif command -v yum > /dev/null; then
        yum install -y wget curl tar procps-ng iproute2 ca-certificates logrotate
    fi
}

# 防火墙自动放行逻辑[cite: 1]
open_fw() {
    local port=$1
    echo -e "${YELLOW}正在自动配置防火墙放行端口: $port...${PLAIN}"
    if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
        ufw allow "$port"/tcp >/dev/null
        ufw allow "$port"/udp >/dev/null
    elif command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --permanent --add-port="$port"/tcp >/dev/null 2>&1
        firewall-cmd --permanent --add-port="$port"/udp >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
    fi
    # 兜底强制放行 iptables[cite: 1]
    iptables -I INPUT -p tcp --dport "$port" -j ACCEPT >/dev/null 2>&1
    iptables -I INPUT -p udp --dport "$port" -j ACCEPT >/dev/null 2>&1
}

# 获取架构[cite: 1]
set_arch() {
    arch=$(uname -m)
    case $arch in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        armv7l) arch="armv7" ;;
        *) echo -e "${RED}不支持的架构: $arch${PLAIN}"; exit 1 ;;
    esac
}

# 获取当前已安装版本[cite: 1]
get_current_version() {
    if [[ -f /usr/local/bin/gost ]]; then
        local curr_v=$(/usr/local/bin/gost -V 2>&1 | grep -Po 'gost v\K[0-9.]+')
        echo "$curr_v"
    else
        echo "未安装"
    fi
}

# 核心安装逻辑[cite: 1]
install_gost() {
    prepare_env
    local version=$1
    local mode=$2 # "new" 为初次安装, "update" 为更新
    set_arch

    local file_name="gost_${version}_linux_${arch}.tar.gz"
    
    # 关键逻辑：根据 mode 切换下载源[cite: 1]
    if [[ "$mode" == "new" ]]; then
        local download_url="${MY_REPO_BASE}/v${version}/${file_name}"
        echo -e "${YELLOW}正在从个人备份源下载 Gost v$version...${PLAIN}"
    else
        local download_url="https://github.com/go-gost/gost/releases/download/v${version}/${file_name}"
        echo -e "${YELLOW}正在从官方仓库下载最新版 v$version...${PLAIN}"
    fi

    if [[ "$mode" == "new" ]]; then
        echo -e "\n${YELLOW}====== 配置代理信息 ======${PLAIN}"
        read -p "设置代理用户名: " USER
        while [[ -z "$USER" ]]; do read -p "不能为空: " USER; done
        read -p "设置代理密码: " PASS
        while [[ -z "$PASS" ]]; do read -p "不能为空: " PASS; done
        read -p "设置代理端口: " PORT
        while [[ -z "$PORT" || ! "$PORT" =~ ^[0-9]+$ ]]; do read -p "请输入数字: " PORT; done
        open_fw "$PORT"
    fi

    cd /tmp
    wget -N --timeout=15 "$download_url"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}下载失败！请检查网络或版本号是否存在。${PLAIN}"
        return 1
    fi

    tar -zxvf "${file_name}"
    mv gost /usr/local/bin/gost
    chmod +x /usr/local/bin/gost

    if [[ "$mode" == "new" ]]; then
        cat > /etc/systemd/system/gost.service <<EOF
[Unit]
Description=Gost v3 Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gost -L socks5://$USER:$PASS@:$PORT
StandardOutput=append:/var/log/gost.log
StandardError=append:/var/log/gost.log
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
        cat <<LOG > /etc/logrotate.d/gost
/var/log/gost.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    copytruncate
}
LOG
        systemctl daemon-reload
        systemctl enable gost
    fi

    systemctl restart gost
    rm -f "/tmp/${file_name}"
    echo -e "${GREEN}操作成功！当前版本: $(get_current_version)${PLAIN}"
}

# 更新检查逻辑[cite: 1]
update_check() {
    echo -e "${YELLOW}正在从官方 GitHub 获取最新版本信息...${PLAIN}"
    local curr=$(get_current_version)
    local late=$(curl -s --connect-timeout 5 "$OFFICIAL_API" | grep -Po '"tag_name": "v\K[0-9.]+')
    
    if [[ -z "$late" ]]; then
        echo -e "${RED}无法连接官方 GitHub 接口。${PLAIN}"
        return 1
    fi

    if [[ "$curr" == "$late" ]]; then
        echo -e "${GREEN}已经是最新版本 ($curr)。${PLAIN}"
    else
        echo -e "${YELLOW}检测到新版本: $late (当前: $curr)${PLAIN}"
        read -p "是否直接从官方下载更新？(y/n): " confirm
        [[ "$confirm" == "y" ]] && install_gost "$late" "update"
    fi
}

# 卸载逻辑[cite: 1]
uninstall_all() {
    read -p "确定要彻底卸载 Gost 及其所有日志吗？(y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        systemctl stop gost
        systemctl disable gost
        rm -f /etc/systemd/system/gost.service
        rm -f /usr/local/bin/gost
        rm -f /etc/logrotate.d/gost
        rm -f /var/log/gost.log*
        systemctl daemon-reload
        echo -e "${GREEN}卸载完成。系统已恢复干净。${PLAIN}"
    fi
}

# 主菜单[cite: 1]
while true; do
    echo -e "
  ${GREEN}Gost v3 交互式管理工具 (私有安装+官方更新)${PLAIN}
  -----------------------------
  ${GREEN}1.${PLAIN} 全新安装 Gost (默认 3.2.6)
  ${GREEN}2.${PLAIN} 检查服务状态
  ${GREEN}3.${PLAIN} 重载 Systemd 配置
  ${GREEN}4.${PLAIN} 重启 Gost 服务
  ${GREEN}5.${PLAIN} 检查系统防火墙
  ${GREEN}6.${PLAIN} 检查进程及端口
  ${GREEN}7.${PLAIN} 检查并执行官方更新
  ${GREEN}8.${PLAIN} 查看当前公网 IP
  ${RED}9.${PLAIN} 卸载 Gost
  ${RED}0. 退出脚本${PLAIN}
  "
    read -p "请输入选项 [0-9]: " choice
    case "$choice" in
        1) install_gost "3.2.6" "new" ;;
        2) systemctl status gost --no-pager ;;
        3) systemctl daemon-reload; echo -e "${GREEN}重载成功${PLAIN}" ;;
        4) systemctl restart gost; echo -e "${GREEN}已重启${PLAIN}" ;;
        5) if command -v ufw > /dev/null; then ufw status;
           elif command -v firewall-cmd > /dev/null; then firewall-cmd --list-all;
           else iptables -L -n | grep -i "tcp"; fi ;;
        6) ps aux | grep gost | grep -v grep; ss -tlnp | grep gost ;;
        7) update_check ;;
        8) curl -s --connect-timeout 8 ipv4.icanhazip.com || echo "获取 IP 失败" ;;
        9) uninstall_all ;;
        0) exit 0 ;;
        *) echo -e "${RED}无效选项${PLAIN}" ;;
    esac
done
