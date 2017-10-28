#!/usr/bin/env bash

# use pulseaudio
export QEMU_AUDIO_DRV=pa
export QEMU_PA_SAMPLES=8192
export QEMU_AUDIO_TIMER_PERIOD=99
export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd

sudo qemu-system-x86_64 \
    -name "windows7vm",process="windows7vm" \
    -machine type=q35,accel=kvm \
    -cpu host,kvm=off \
    -smp 6,sockets=1,cores=3,threads=2 \
    -enable-kvm \
    -m 6G \
    -mem-prealloc \
    -balloon none \
    -rtc clock=host,base=localtime \
    -serial none \
    -parallel none \
    -soundhw hda \
    -boot dc \
    -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
    -device virtio-scsi-pci,id=scsi \
    -drive file=./Win7_Ult_SP1_English_x64.iso,id=isocd,format=raw,if=none -device scsi-cd,drive=isocd \
    -drive file=/dev/mapper/lmhdd-windows,id=disk0,format=raw
    #-device vfio-pci,host=01:00.0,multifunction=on \
    #-device vfio-pci,host=01:00.1 \
