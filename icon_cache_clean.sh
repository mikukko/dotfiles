# 停止图标服务代理，防止在删除时它又写入新缓存
killall iconservicesagent

# 找到并删除用户级的图标缓存目录（这是最主要的位置）
# getconf DARWIN_USER_CACHE_DIR 会自动定位到正确的缓存文件夹
rm -rfv "$(getconf DARWIN_USER_CACHE_DIR)/com.apple.iconservices"

# 为保险起见，也清理一下 Dock 的图标缓存
# 这条命令会查找并删除所有用户下的 Dock 图标缓存文件
sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm -rf {} +

# 重启 Dock 和 Finder，让更改生效
killall Dock
killall Finder
