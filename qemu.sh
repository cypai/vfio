#!/usr/bin/env bash

sudo qemu-system-x86_64 -enable-kvm -m 6G -boot /dev/mapper/lmhdd-windows,format=raw
