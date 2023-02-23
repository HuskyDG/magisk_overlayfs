MODDIR="${0%/*}"

MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin
DATAMIRROR="$MAGISKTMP/.magisk/mirror/data"
OVERLAYDIR="$DATAMIRROR/adb/overlay"
OVERLAYMNT="/mnt/overlay_system"

mv -fT /cache/overlayfs.log /cache/overlayfs.log.bak
rm -rf /cache/overlayfs.log
echo "--- Start debugging log ---" >/cache/overlayfs.log

mkdir -p "$OVERLAYMNT"
mkdir -p "$OVERLAYDIR"

if [ -d "$OVERLAYDIR" ]; then
    mount --bind "$OVERLAYDIR" "$OVERLAYMNT"
else
    echo "unable to mount writeable dir" >>/cache/overlayfs.log
    exit
fi
# overlay_system <writeable-dir> <mirror>
chmod 777 "$MODDIR/overlayfs_system"
"$MODDIR/overlayfs_system" "$OVERLAYMNT" "$MAGISKTMP/.magisk/mirror" | tee -a /cache/overlayfs.log
umount -l "$OVERLAYMNT"
rmdir "$OVERLAYMNT"

echo "--- Mountinfo ---" >>/cache/overlayfs.log
cat /proc/mounts >>/cache/overlayfs.log
