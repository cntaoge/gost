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
wget -O install_gost.sh [https://raw.githubusercontent.com/cntaoge/gost/master/install_gost.sh](https://raw.githubusercontent.com/cntaoge/gost/master/install_gost.sh) && chmod +x install_gost.sh && ./install_gost.sh
