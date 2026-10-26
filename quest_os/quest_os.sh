#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
set -eu

usage() {
	echo "Usage: quest_os [--accel auto|kvm|tcg] [-- QEMU-options]"
}

accel=auto
while [ "$#" -gt 0 ]; do
	case "$1" in
		--accel)
			[ "$#" -ge 2 ] || { usage >&2; exit 2; }
			accel=$2
			shift 2
			;;
		--help|-h) usage; exit 0 ;;
		--) shift; break ;;
		*) usage >&2; exit 2 ;;
	esac
done

case "$accel" in
	auto)
		if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
			accel=kvm
		else
			accel=tcg
		fi
		;;
	kvm|tcg) ;;
	*) usage >&2; exit 2 ;;
esac

case "$accel" in
	kvm) cpu=host ;;
	tcg) cpu=max ;;
esac
image=${QUEST_OS_IMAGE:-/usr/share/quest_os/quest_os.bin}
[ -s "$image" ] || { echo "quest_os: image missing: $image" >&2; exit 1; }
command -v qemu-system-aarch64 >/dev/null || {
	echo "quest_os: qemu-system-aarch64 is not installed" >&2
	exit 1
}
echo "Quest OS: $accel, 4 virtual CPUs"
exec qemu-system-aarch64 \
	-accel "$accel" -cpu "$cpu" \
	-machine virt,secure=off,virtualization=off,gic-version=3,its=off \
	-m 1024 -smp 4 \
	-bios "$image" \
	-nographic -nic none "$@"
