# # 基础镜像
# FROM harbor.lins.lab/determinedai/environments:cuda-11.3-pytorch-1.10-tf-2.8-gpu-0.19.4

# # 设置非交互式前端和环境变量
# ARG DEBIAN_FRONTEND=noninteractive
# ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8 PIP_NO_CACHE_DIR=1

# # 更新APT源为中国科学技术大学的镜像源，并安装必要的系统依赖
# RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
#     sed -i "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
#     rm -f /etc/apt/sources.list.d/* && \
#     # 更新包列表并升级已安装的包
#     apt-get update && apt-get upgrade -y && \
#     # 安装必要的软件包和工具
#    apt-get update && apt-get upgrade -y && \
#     # 安装必要的软件包和工具
#     apt-get install -y --no-install-recommends \
#         # 常用的编译工具和开发库
#         autoconf automake autotools-dev build-essential ca-certificates \
#         make cmake ninja-build pkg-config g++ ccache yasm \
#         ccache doxygen graphviz plantuml \
#         # 网络、用户管理及其他工具
#         daemontools krb5-user ibverbs-providers libibverbs1 \
#         libkrb5-dev librdmacm1 libssl-dev libtool \
#         libnuma1 libnuma-dev libpmi2-0-dev \
#         openssh-server openssh-client pkg-config nfs-common \
#         # 常用的命令行工具
#         git curl wget unzip nano net-tools sudo htop iotop \
#         cloc rsync screen tmux xz-utils software-properties-common libaio-dev && \
#     # 删除现有的SSH主机密钥（避免密钥重复）
#     rm /etc/ssh/ssh_host_ecdsa_key && \
#     rm /etc/ssh/ssh_host_ed25519_key && \
#     rm /etc/ssh/ssh_host_rsa_key && \
#     # 备份SSH配置文件
#     cp /etc/ssh/sshd_config /etc/ssh/sshd_config_bak && \
#     # 启用X11转发以支持图形界面的远程访问
#     sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config && \
#     sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config && \
#     # 确保X11UseLocalhost设置为no
#     grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config && \
#     # 清理APT缓存以减小镜像大小
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*
# # 设置工作目录和环境变量
# WORKDIR /tmp
# # 设置Python和Jupyter相关的环境变量
# ENV PYTHONUNBUFFERED=1 PYTHONFAULTHANDLER=1 PYTHONHASHSEED=0
# ENV JUPYTER_CONFIG_DIR=/run/determined/jupyter/config
# ENV JUPYTER_DATA_DIR=/run/determined/jupyter/data
# ENV JUPYTER_RUNTIME_DIR=/run/determined/jupyter/runtime

# # 克隆Determined AI的容器脚本，并安装所需的包和配置
# RUN git clone https://github.com/LingzheZhao/determinedai-container-scripts && \
#     cd determinedai-container-scripts && \
#     # 切换到指定的版本
#     git checkout v0.2.1 && \
#     # 设置pip使用清华大学的PyPI镜像源，以加快包的下载速度
#     pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
#    # 安装notebook-requirements.txt中列出的Python包
#     pip install -r notebook-requirements.txt && \
#     # 安装additional-requirements.txt中列出的Python包
#     pip install -r additional-requirements.txt && \
#     # 禁用JupyterLab的公告扩展
#     jupyter labextension disable "@jupyterlab/apputils-extension:announcements" && \
#     if ! getent group det-nobody > /dev/null; then ./add_det_nobody_user.sh; fi && \
#     # 运行脚本，安装libnss_determined库
#     ./install_libnss_determined.sh && \
#     # 清理/tmp目录中的临时文件
#     rm -rf /tmp/*

FROM harbor.lins.lab/library/zhiying_base_image:v1.0

# Update conda to the latest version
RUN conda update -n base -c defaults conda -y
COPY environment.yml /tmp/environment.yml
COPY pip_requirements.txt /tmp/pip_requirements.txt
RUN conda env update --name base --file /tmp/environment.yml
RUN conda clean --all --force-pkgs-dirs --yes
RUN eval "$(conda shell.bash hook)" && \
    conda activate base && \
    pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple &&\
    pip install -r /tmp/pip_requirements.txt && \
    # git clone https://github.com/jiaweizzhao/GaLore.git && \
    #         cd GaLore && \
    #         pip install -e . && \
    #         pip install -r exp_requirements.txt