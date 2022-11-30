swapoff -a
sed -i '/.*swap.*/d' /etc/fstab
# trick to fix GPT
printf "fix\n" | parted ---pretend-input-tty /dev/nvme0n1 print
# remove partition 3 (swap)
parted -s /dev/nvme0n1 rm 3
# resize partition 2 to use 100% of available free space
parted -s /dev/nvme0n1 resizepart 2 100%
# resizing ext4 filesystem
resize2fs /dev/nvme0n1p2
