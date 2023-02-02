MODDIR="${0%/*}"

mv -fT /cache/overlayfs.log /cache/overlayfs.log.bak
rm -rf /cache/overlayfs.log
echo "--- Start debugging log ---" >/cache/overlayfs.log

loop_setup() {
  unset LOOPDEV
  local LOOP
  local MINORX=1
  [ -e /dev/block/loop1 ] && MINORX=$(stat -Lc '%T' /dev/block/loop1)
  local NUM=0
  while [ $NUM -lt 64 ]; do
    LOOP=/dev/block/loop$NUM
    [ -e $LOOP ] || mknod $LOOP b 7 $((NUM * MINORX))
    if losetup $LOOP "$1" 2>/dev/null; then
      LOOPDEV=$LOOP
      break
    fi
    NUM=$((NUM + 1))
  done
}

loop_setup /data/adb/overlay.img

mkdir -p /mnt/overlay_system

if [ ! -z "$LOOPDEV" ]; then
    echo "mount: $LOOPDEV -> /mnt/overlay_system" >>/cache/overlayfs.log
    mount  -o rw -t ext4 "$LOOPDEV" /mnt/overlay_system
elif [ -d /data/adb/overlay ]; then
    echo "mount: /data/adb/overlay -> /mnt/overlay_system" >>/cache/overlayfs.log
    mount --bind "/data/adb/overlay" /mnt/overlay_system
else
    echo "unable to mount writeable dir" >>/cache/overlayfs.log
    exit
fi
# overlay_system <writeable-dir> <mirror>
chmod 777 "$MODDIR/overlayfs_system"
"$MODDIR/overlayfs_system" /mnt/overlay_system "$(magisk --path)/.magisk/mirror" | tee -a /cache/overlayfs.log
umount -l /mnt/overlay_system
rmdir /mnt/overlay_system

echo "--- Mountinfo ---" >>/cache/overlayfs.log
cat /proc/mounts >>/cache/overlayfs.log
