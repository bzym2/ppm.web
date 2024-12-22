#!/bin/bash

# 彩色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# 输出函数
log_info() {
    echo -e "${BLUE}<>${RESET} $1"
}

log_warning() {
    echo -e "${YELLOW}<>${RESET} $1"
}

log_error() {
    echo -e "${RED}<>${RESET} $1"
}

log_success() {
    echo -e "${GREEN}<>${RESET} $1"
}

# 提示用户输入是否启用 GitHub 镜像
prompt_github_mirror() {
    log_warning "是否使用 GitHub 镜像（默认为不使用）？(y/n)"
    read -r USE_GITHUB_MIRROR
    if [[ "$USE_GITHUB_MIRROR" == "y" || "$USE_GITHUB_MIRROR" == "Y" ]]; then
        GITHUB_URL="https://ghproxy.com/https://github.com/Stevesuk0/ppm.git"
        log_success "启用 GitHub 镜像..."
    else
        GITHUB_URL="https://github.com/Stevesuk0/ppm.git"
    fi
}

# 提示用户设置安装路径
prompt_install_path() {
    log_warning "请输入自定义安装路径（默认安装到 /opt/ppm）："
    read -r INSTALL_PATH
    if [[ -z "$INSTALL_PATH" ]]; then
        INSTALL_PATH="/opt/ppm"
        log_success "使用默认安装路径：$INSTALL_PATH"
    else
        log_success "安装路径设置为：$INSTALL_PATH"
    fi
}

# 安装依赖
install_dependencies() {
    DISTRO=$1
    log_info "安装系统依赖..."

    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
        sudo apt update
        sudo apt install -y python3-dbus python3-colorama python3-requests
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "fedora" ]]; then
        sudo dnf install -y python3-dbus python3-colorama python3-requests
    elif [[ "$DISTRO" == "arch" ]]; then
        sudo pacman -S --noconfirm python-dbus python-colorama python-requests
    else
        log_error "不支持的发行版: $DISTRO"
        exit 1
    fi
}

# 检测操作系统
detect_distro() {
    if [ -f /etc/os-release ]; then
        DISTRO=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        log_error "无法检测操作系统版本。"
        exit 1
    fi

    log_info "检测到的操作系统：$DISTRO"
    install_dependencies $DISTRO
}

# 克隆仓库并设置软连接
setup_ppm() {
    log_info "克隆 PPM 仓库到 $INSTALL_PATH..."
    sudo git clone "$GITHUB_URL" "$INSTALL_PATH"
    sudo ln -sf "$INSTALL_PATH/launcher.py" /usr/bin/ppm
}

# 初始化 PPM
initialize_ppm() {
    log_info "初始化 PPM..."
    ppm --init
}

# 主程序执行
main() {
    log_success "开始安装 Plusto 包管理器（PPM）..."

    # 获取用户输入
    prompt_github_mirror
    prompt_install_path

    # 检测并安装依赖
    detect_distro

    # 克隆仓库并设置软连接
    setup_ppm

    # 初始化 PPM
    initialize_ppm

    log_success "PPM 安装与配置完成！"
}

# 执行主程序
main