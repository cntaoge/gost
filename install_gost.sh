#!/bin/bash

# ================= 配置区 =================
# 个人 GitHub 仓库GOST备用地址
MY_REPO_BASE="https://github.com/cntaoge/gost/releases/download"
# 官方 GitHub API 地址（用于检查更新）
OFFICIAL_API="https://api.github.com/repos/go-gost/gost/releases/latest"
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

# 权限检查
[[ $EUID -ne 0 ]] && echo -e "${RED}错误：${PLAIN} 必须使用 root 用户运行此脚本！\n" && exit 1

# 环境准备
prepare_env() {
    echo -e "${YELLOW}正在检查并安装必要组件...${PLAIN}"
    if command -v apt-get > /dev/null; then
        apt-get update -y
        apt-get install -y wget curl tar procps iproute2 ca-certificates
    elif command -v yum > /dev/null; then
        yum install -y wget curl tar procps-ng iproute2 ca-certificates
    fi
}

# 获取架构
set_arch() {
    arch=$(uname -m)
    case $arch in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        armv7l) arch="armv7" ;;
        *) echo -e "${RED}不支持的架构: $arch${PLAIN}"; exit 1 ;;
    esac
}

# 获取当前已安装版本
get_current_version() {
    if [[ -f /usr/local/bin/gost ]]; then
        local curr_v=$(/usr/local/bin/gost -V 2>&1 | grep -Po 'gost v\K[0-9.]+')
        echo "$curr_v"
    else
        echo "未安装"
    fi
}

# 核心安装逻辑
install_gost() {
    prepare_env
    local version=$1
    local mode=$2

    set_arch

    if [[ "$mode" == "new" ]]; then
        echo -e "\n${YELLOW}==================================================${PLAIN}"
        echo -e "${YELLOW} 注意：以下输入的用户名和密码是为 GOST 代理设置的，${PLAIN}"
        echo -e "${YELLOW} 用于客户端连接，并非你的系统登录密码。${PLAIN}"
        echo -e "${YELLOW}==================================================${PLAIN}\n"
        read -p "设置代理连接用户名: " USER
        while [[ -z "$USER" ]]; do read -p "不能为空: " USER; done
        read -p "设置代理连接密码: " PASS
        while [[ -z "$PASS" ]]; do read -p "不能为空: " PASS; done
        read -p "设置代理连接端口: " PORT
        while [[ -z "$PORT" || ! "$PORT" =~ ^[0-9]+$ ]]; do read -p "请输入数字端口: " PORT; done
    fi

    echo -e "${YELLOW}正在从个人备份源下载 Gost v$version...${PLAIN}"
    cd /tmp
    local file_name="gost_${version}_linux_${arch}.tar.gz"
    
    # 【修改点】使用你自己的仓库地址进行下载
    wget -N --timeout=15 "${MY_REPO_BASE}/v${version}/${file_name}"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}下载失败！${PLAIN}"
        echo -e "请确保你的仓库 ${YELLOW}cntaoge/gost${PLAIN} 的 Release 中已上传该文件。"
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
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable gost
    fi

    systemctl restart gost
    
    echo -e "${YELLOW}正在清理安装临时文件...${PLAIN}"
    rm -f "/tmp/${file_name}"

    echo -e "${GREEN}操作成功！当前版本: $(get_current_version)${PLAIN}"
}

# 更新检查逻辑（依然指向官方）
update_check() {
    echo -e "${YELLOW}正在从官方 GitHub 获取最新版本信息...${PLAIN}"
    local curr=$(get_current_version)
    # 【保留点】依然请求官方 API
    local late=$(curl -s --connect-timeout 5 "$OFFICIAL_API" | grep -Po '"tag_name": "v\K[0-9.]+')
    
    if [[ -z "$late" ]]; then
        echo -e "${RED}无法连接官方 GitHub 接口，请检查网络。${PLAIN}"
        return 1
    fi

    echo -e "当前版本: ${YELLOW}$curr${PLAIN}"
    echo -e "官方最新: ${YELLOW}$late${PLAIN}"

    if [[ "$curr" == "$late" ]]; then
        echo -e "${GREEN}已经是最新版本。${PLAIN}"
    else
        echo -e "${YELLOW}检测到官方有新版本！${PLAIN}"
        echo -e "请先在你的仓库 ${YELLOW}cntaoge/gost${PLAIN} 中同步官方 Release 后再升级。"
        read -p "是否尝试从你的仓库升级？(y/n): " confirm
        [[ "$confirm" == "y" ]] && install_gost "$late" "update"
    fi
}

# 卸载逻辑（不触及系统组件）
uninstall_all() {
    read -p "确定要彻底卸载 Gost 吗？(y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        systemctl stop gost
        systemctl disable gost
        rm -f /etc/systemd/system/gost.service
        rm -f /usr/local/bin/gost
        systemctl daemon-reload
        echo -e "${GREEN}卸载完成。基础组件(wget/curl)已保留。${PLAIN}"
    fi
}

# 主菜单
while true; do
    echo -e "
  ${GREEN}Gost v3 交互式管理工具 (私有备份版)${PLAIN}
  -----------------------------
  ${GREEN}1.${PLAIN} 全新安装 Gost (默认稳定版 3.2.6)
  ${GREEN}2.${PLAIN} 检查服务状态
  ${GREEN}3.${PLAIN} 重载 Systemd 配置
  ${GREEN}4.${PLAIN} 重启 Gost 服务
  ${GREEN}5.${PLAIN} 检查系统防火墙
  ${GREEN}6.${PLAIN} 检查进程及端口
  ${GREEN}7.${PLAIN} 检查官方更新
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
