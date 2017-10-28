#!/usr/bin/env bash

# use pulseaudio
export QEMU_AUDIO_DRV=pa
export QEMU_PA_SAMPLES=8192
export QEMU_AUDIO_TIMER_PERIOD=99
export QEMU_PA_SERVER=/run/user/1000/pulse/native

sudo qemu-system-x86_64 \
    -enable-kvm \
    -m 6G \
    -cpu host \
    -smp 4,sockets=1,cores=2,threads=2 \
    -mem-prealloc \
    -balloon none \
    -rtc clock=host,base=localtime \
    -serial none \
    -parallel none \
    -soundhw hda \
    -boot dc \
    /dev/mapper/lmhdd-windows
