#!/usr/bin/env bash

vmname="windows8vm"
configfile=/etc/vfio-pci.cfg

vfiobind() {
    dev="$1"
    vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
    device=$(cat /sys/bus/pci/devices/$dev/device)
    if [ -e /sys/bus/pci/devices/$dev/driver ]; then
        echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
    fi
    echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id

}


if ps -A | grep -q $vmname; then
    echo "VM is already running"
    exit 1
else
    cat $configfile | while read line;do
        echo $line | grep ^# >/dev/null 2>&1 && continue
        vfiobind $line
    done
fi

# use pulseaudio
export QEMU_AUDIO_DRV=pa
#export QEMU_PA_SAMPLES=8192
#export QEMU_AUDIO_TIMER_PERIOD=99
export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd

taskset -c 0-3 /home/cpai/work/qemu/build/x86_64-softmmu/qemu-system-x86_64 \
    -name $vmname,process=$vmname \
    -machine type=q35,accel=kvm \
    -cpu host,kvm=off \
    -smp 4,sockets=1,cores=2,threads=2 \
    -enable-kvm \
    -m 8G \
    -mem-prealloc \
    -balloon none \
    -rtc clock=host,base=localtime \
    -serial none \
    -parallel none \
    -soundhw hda \
    -vga none \
    -device vfio-pci,host=02:00.0,multifunction=on \
    -device vfio-pci,host=02:00.1 \
    -device vfio-pci,host=06:00.0 \
    -usb -usbdevice host:046d:c21d \
    -boot dc \
    -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
    -device virtio-scsi-pci,id=scsi \
    -drive file=/dev/mapper/lmhdd-windows,id=disk0,format=raw \
    -drive file=./virtio-win-0.1.140.iso,id=virtiocd,format=raw,if=none -device ide-cd,bus=ide.1,drive=virtiocd
#-drive file=./Windows_8_Professional.iso,id=isocd,format=raw,if=none -device scsi-cd,drive=isocd \
