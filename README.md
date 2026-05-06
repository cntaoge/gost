# Gost v3 交互式管理工具 (私有备份版)

这是一个基于 [GOST (Go Safety Tunnel)](https://github.com/go-gost/gost) v3 构建的自动化部署与管理脚本。本项目旨在为个人用户提供一个稳定、快速且自持的 Gost 部署方案。

---

## 🙏 致敬原作者

本项目的功能核心由 **[GOST](https://github.com/go-gost/gost)** 提供。衷心感谢 **[gost-core](https://github.com/go-gost)** 团队及所有贡献者。

> **说明**：本仓库通过 Fork 官方项目进行个人备份，旨在确保在极端环境下依然拥有可用的二进制部署源。

---

## 🚀 快速开始

在你的 VPS 上运行以下命令即可启动交互式管理菜单：
```bash
wget -O install_gost.sh https://raw.githubusercontent.com/cntaoge/gost/master/install_gost.sh && chmod +x install_gost.sh && ./install_gost.sh
```

## 🌟 脚本特色

*   **私有化保障**：安装包从本仓库的 Release 区域下载，不受外部不可控因素影响。
*   **防火墙自动化**：自动识别并配置 UFW / Firewalld / Iptables 端口规则，无需手动放行。
*   **专业日志维护**：集成 `logrotate` 实现日志每日自动切割与压缩，防止占用过多磁盘空间。
*   **智能更新**：自动检测官方最新的发布版本并提醒，支持平滑升级。
*   **安全卸载**：一键移除所有相关配置与日志，保持系统环境洁净。

## 🛠️ 功能菜单说明
脚本运行后，你将看到以下功能选项：

全新安装：一键配置 SOCKS5 代理及 Systemd 守护进程。

服务状态：实时查看运行日志及服务健康状况。

重载配置：快速生效 Systemd 修改，无需重启机器。

重启服务：快速重启代理进程以应用配置更改。

防火墙检查：自动扫描并开启所需端口。

进程检查：查看当前端口占用及 GOST 运行详情。

检查更新：对比当前版本与官方最新版本。

公网 IP：快速显示 VPS 外部访问地址。

彻底卸载：安全清理所有 gost 相关文件与日志。

## 📝 版本更新记录
v3.2.6-Enhanced (2026-05-07)
新增：防火墙自动放行逻辑，支持主流 Linux 发行版。

新增：日志自动切割功能，日志存放路径：/var/log/gost.log。

优化：改进了安装环境检测，自动补全 wget, curl, tar 等依赖。

修复：修正了在部分旧版 Ubuntu 系统下卸载残留的问题。

## ⚖️ 免责声明
本脚本仅供个人研究和学习使用，请勿用于任何违反当地法律法规的活动。用户自行承担相应风险。

## 🌟 支持原项目
如果你觉得 Gost 很好用，请前往 **[go-gost/gost](https://github.com/go-gost/gost)** 给原作者一个 Star！
