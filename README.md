## kubeadm-config-pack

> 本仓库为 kubeadm 配置文件以及 OCI 镜像安装包，方便在宿主机安装以及配置。

### 一、使用

可直接从 [release](https://github.com/mritd/kubeadm-config-pack/releases) 页面下载对应版本安装包，然后执行 `kubeadm-config_*.run install` 既可安装。

```sh
➜ ~ ./kubeadm-config_v1.20.2.run
Verifying archive integrity...  100%   MD5 checksums are OK. All good.
Uncompressing kubeadm-config  100%

NAME:
    kubeadm-config_v1.20.2.run - kubeadm config tool

USAGE:
    kubeadm-config_v1.20.2.run command

AUTHOR:
    mritd <mritd@linux.com>

COMMANDS:
    install     Install kubeadm & containerd config
    uninstall   Remove kubeadm & containerd config
    load        Load kubernetes images

COPYRIGHT:
   Copyright (c) 2021 mritd, All rights reserved.
```

### 二、配置

**安装包会释放文件列表如下:**

- `/etc/kubernetes/kubeadm.yaml`: kubeadm 引导配置文件
- `/etc/kubernetes/addons`: 一些 kubernetes 扩展应用
- `/etc/containerd/config.toml`: containerd 配置文件
- `/etc/crictl.yaml`: crictl 配置文件

可自行调整相关配置进行安装定制。
