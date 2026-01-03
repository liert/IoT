#!/bin/bash

# ========================
# 网络设备设置（带存在性检查）
# ========================

# 创建 TAP 设备 tap0（如果不存在）
if ! ip link show tap0 &>/dev/null; then
    echo "创建 TAP 设备 tap0..."
    sudo ip tuntap add dev tap0 mode tap
    sudo ip link set tap0 up
else
    echo "TAP 设备 tap0 已存在，跳过创建。"
fi

# 创建网桥 br0（如果不存在）
if ! ip link show br0 &>/dev/null; then
    echo "创建网桥 br0..."
    sudo brctl addbr br0
    sudo ip link set br0 up
else
    echo "网桥 br0 已存在，跳过创建。"
fi

# 将 tap0 加入 br0（如果尚未加入）
if ! brctl show br0 | grep -q 'tap0'; then
    echo "将 tap0 添加到 br0..."
    sudo brctl addif br0 tap0
else
    echo "tap0 已在 br0 中，跳过添加。"
fi

# 为 br0 配置 IP（仅当尚未配置时）
if ! ip addr show br0 | grep -q '192.168.1.10'; then
    echo "为 br0 分配 IP 地址 192.168.1.10/24..."
    sudo ip addr add 192.168.1.10/24 dev br0
else
    echo "br0 已配置 IP 192.168.1.10/24，跳过分配。"
fi

# ========================
# 启动 QEMU 虚拟机
# ========================

echo "启动 OpenWrt ARM32 (ARMv7) ..."

# 启动 QEMU 模拟 ARMv7 机器
qemu-system-arm \
  -M virt \
  -cpu cortex-a15 \
  -m 512M \
  -nographic \
  -kernel openwrt-24.10.4-armsr-armv7-generic-kernel.bin \
  -append "root=/dev/vda rw console=ttyAMA0 earlyprintk" \
  -drive if=none,file=openwrt-24.10.4-armsr-armv7-generic-ext4-rootfs.img,format=raw,id=hd \
  -device virtio-blk-device,drive=hd \
  -fsdev local,id=nand_share,path=$(pwd),security_model=none \
  -device virtio-9p-device,fsdev=nand_share,mount_tag=nand_tag \
  -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
  -device virtio-net-pci,netdev=net0 | tee ./qemu.final.serial.log
