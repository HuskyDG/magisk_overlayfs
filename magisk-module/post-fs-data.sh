MODDIR="${0%/*}"

mv -fT /cache/overlayfs.log /cache/overlayfs.log.bak
rm -rf /cache/overlayfs.log
echo "--- Start debugging log ---" >/cache/overlayfs.log

mkdir -p /mnt/overlay_system
mkdir -p /data/adb/overlay

if [ -d /data/adb/overlay ]; then
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
