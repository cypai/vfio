#!/usr/bin/env bash

vmname=windows10vm

configfile=/etc/vfio-pci.cfg

if ps -A | grep -q $vmname; then
    echo "VM is already running"
    exit 1
fi

# use pulseaudio
#export QEMU_AUDIO_DRV=pa
#export QEMU_PA_SAMPLES=8192
#export QEMU_AUDIO_TIMER_PERIOD=99
#export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/edk2-ovmf/x64/OVMF_VARS.fd /tmp/my_vars.fd

qemu-system-x86_64 \
    -name $vmname,process=$vmname \
    -machine type=q35,accel=kvm \
    -cpu host,kvm=off,hv_vendor_id=1234567890ab,-hypervisor,hv_vapic,hv_time,hv_relaxed,hv_spinlocks=0x1fff,l3-cache=on,migratable=no,+invtsc,+topoext \
    -smp 8,sockets=1,cores=4,threads=2 \
    -enable-kvm \
    -m 16G \
    -mem-prealloc \
    -rtc clock=host,base=localtime \
    -serial none \
    -parallel none \
    -vga none \
    -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
    -device ich9-intel-hda,bus=pcie.0,addr=0x1b \
    -device hda-micro,audiodev=hda \
    -audiodev pa,id=hda,server=/run/user/1000/pulse/native \
    -device vfio-pci,host=0a:00.0,bus=root.1,addr=00.0,multifunction=on \
    -device vfio-pci,host=0a:00.1,bus=root.1,addr=00.1 \
    -device usb-host,hostbus=1,vendorid=0x04d9,productid=0x0203 \
    -device usb-host,hostbus=1,vendorid=0x046d,productid=0xc52f \
    -device usb-host,vendorid=0x046d,productid=0xc21d \
    -boot order=dc \
    -usb \
    -drive if=pflash,format=raw,readonly,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
    -object iothread,id=io1 \
    -device virtio-scsi-pci,id=disk0,iothread=io1,num_queues=4,bus=pcie.0 \
    -device scsi-hd,drive=disk0 \
    -drive file=/dev/mapper/lmsdd-windows,id=disk0,format=raw,cache=none,cache.direct=on,aio=threads,if=none
    #-drive file=./virtio-win-0.1.140.iso,id=virtiocd,format=raw,if=none -device ide-cd,bus=ide.1,drive=virtiocd \
    #-drive file=/home/cpai/Downloads/Win10_20H2_v2_English_x64.iso,id=isocd,format=raw,if=none -device scsi-cd,drive=isocd \
