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
#else
    #cat $configfile | while read line;do
    #    echo $line | grep ^# >/dev/null 2>&1 && continue
    #    vfiobind $line
    #done
fi

# use pulseaudio
#export QEMU_AUDIO_DRV=pa
#export QEMU_PA_SAMPLES=8192
#export QEMU_AUDIO_TIMER_PERIOD=99
#export QEMU_PA_SERVER=/run/user/1000/pulse/native

cp /usr/share/OVMF/OVMF_VARS.fd /tmp/my_vars.fd

/hdd/cpai/work/qemu-5.2.0/build/qemu-system-x86_64 \
    -name $vmname,process=$vmname \
    -machine type=q35,accel=kvm \
    -cpu host,kvm=off,hv_vendor_id=1234567890ab,-hypervisor,hv_vapic,hv_time,hv_relaxed,hv_spinlocks=0x1fff,l3-cache=on,migratable=no,+invtsc  \
    -smp 6,sockets=1,cores=3,threads=2 \
    -enable-kvm \
    -m 16G \
    -mem-prealloc \
    -rtc clock=host,base=localtime \
    -serial none \
    -parallel none \
    -soundhw hda \
    -audiodev pa,id=pa1,server=/run/user/1000/pulse/native \
    -vga none \
    -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
    -device vfio-pci,host=02:00.0,bus=root.1,addr=00.0,multifunction=on \
    -device vfio-pci,host=02:00.1,bus=root.1,addr=00.1 \
    -device usb-host,hostbus=3,vendorid=0x04d9,productid=0x0203 \
    -device usb-host,hostbus=3,vendorid=0x046d,productid=0xc52f \
    -device usb-host,vendorid=0x046d,productid=0xc21d \
    -boot order=dc \
    -usb \
    -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=/tmp/my_vars.fd \
    -device virtio-scsi-pci,id=scsi \
    -drive file=/dev/mapper/lmhdd-windows,id=disk0,format=raw,cache=none,cache.direct=on,aio=threads
   # -drive file=/dev/mapper/lmhdd-windows,id=disk0,format=raw \
   # -device vfio-pci,host=06:00.0
   # -drive file=./virtio-win-0.1.140.iso,id=virtiocd,format=raw,if=none -device ide-cd,bus=ide.1,drive=virtiocd \
   # -drive file=/home/cpai/Downloads/Win10_20H2_v2_English_x64.iso,id=isocd,format=raw,if=none -device scsi-cd,drive=isocd \
