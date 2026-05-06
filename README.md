# Gost v3 交互式管理工具 (私有备份版)

这是一个基于 [GOST (Go Safety Tunnel)](https://github.com/go-gost/gost) v3 构建的自动化部署与管理脚本。本项目旨在为个人用户提供一个稳定、快速且自持的 Gost 部署方案。

---

## 🙏 致敬原作者

本项目的功能核心由 **[GOST](https://github.com/go-gost/gost)** 提供。衷心感谢 **[gost-core](https://github.com/go-gost)** 团队及所有贡献者，感谢他们开发了如此优秀、强大且灵活的安全隧道工具。

> **说明**：本仓库通过 Fork 官方项目进行个人备份，旨在确保在极端环境下依然拥有可用的二进制部署源。

---

## 🚀 快速开始

在你的 VPS 上运行以下命令即可启动交互式管理菜单。该脚本支持全新安装、版本更新、服务管理及防火墙检查等功能。
```bash
wget -O install_gost.sh [https://raw.githubusercontent.com/cntaoge/gost/master/install_gost.sh](https://raw.githubusercontent.com/cntaoge/gost/master/install_gost.sh) && chmod +x install_gost.sh && ./install_gost.sh

🌟 脚本特色
私有化保障：安装包从本仓库的 Release 区域下载，不受外部变动影响。

智能更新：自动检测官方最新的发布版本并提醒。

零残留清理：安装完成后自动清理临时文件，保持系统整洁。

安全卸载：仅移除 Gost 相关文件，不触动系统基础组件。

🛠️ 功能菜单说明
全新安装：一键配置 SOCKS5 代理及守护进程。

服务状态：实时查看运行日志。

重载配置：快速生效 Systemd 修改。

重启服务：快速重启代理进程。

防火墙检查：自动检测 UFW / Firewalld 等。

进程检查：查看端口占用情况。

检查更新：指引同步官方最新版本。

公网 IP：显示 VPS 外部访问地址。

彻底卸载：安全移除所有相关文件。

⚖️ 免责声明
本脚本仅供个人研究和学习使用，请勿用于任何违反当地法律法规的活动。用户自行承担相应风险。

🌟 支持原项目
如果你觉得 Gost 很好用，请前往 go-gost/gost 给原作者一个 Star！
