#!/usr/bin/env bash

# use pulseaudio
export QEMU_AUDIO_DRV=pa
export QEMU_PA_SAMPLES=8192
export QEMU_AUDIO_TIMER_PERIOD=99
export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd

taskset -c 0-7 qemu-system-x86_64 \
    -name "windows7vm",process="windows7vm" \
    -machine type=q35,accel=kvm \
    -cpu host,kvm=off \
    -smp 8,sockets=1,cores=2,threads=4 \
    -enable-kvm \
    -m 6G \
    -mem-prealloc \
    -balloon none \
    -rtc clock=host,base=localtime \
    -serial none \
    -parallel none \
    -soundhw hda \
    -vga none \
    -usb -usbdevice host:046d:c52f \
    -usb -usbdevice host:04d9:0203 \
    -device vfio-pci,host=01:00.0,multifunction=on \
    -device vfio-pci,host=01:00.1 \
    -boot dc \
    -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
    -device virtio-scsi-pci,id=scsi \
    -drive file=./Windows_8_Professional.iso,id=isocd,format=raw,if=none -device scsi-cd,drive=isocd \
    -drive file=/dev/mapper/lmhdd-windows,id=disk0,format=raw \
    -drive file=./virtio-win-0.1.140.iso,id=virtiocd,format=raw,if=none -device ide-cd,bus=ide.1,drive=virtiocd
