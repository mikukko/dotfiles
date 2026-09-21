# dotfiles

macOS 下的 Zsh、Fish、Git、Vim 和 Conda 配置。

## 结构

```text
dotfiles/
├── install.sh
├── Brewfile
├── configs/
│   ├── .zshrc
│   ├── .zprofile
│   ├── .zsh_scripts
│   ├── config.fish
│   ├── .gitconfig
│   ├── .gitignore_global
│   ├── .vimrc
│   └── .condarc
└── scripts/
    ├── link_icloud.sh
    ├── link_fish.sh
    ├── link_obsidian.sh
    ├── clear_vscode_cache.sh
    ├── clean_icon_cache.sh
    ├── remove_localized.sh    # 手工清理 .localized
    ├── delocalize-guard.c     # 常驻守护的源码（编译成 bin/）
    ├── localized_guard.sh     # 编译 + 安装守护
    └── bin/                   # 编译产物，已 gitignore
```

## 安装

```bash
./install.sh
```

安装器会链接核心配置：

- Zsh: `~/.zshrc`、`~/.zprofile`、`~/.zsh_scripts`
- Fish: `~/.config/fish/config.fish`
- Git: `~/.gitconfig`、`~/.gitignore_global`
- Vim: `~/.vimrc`
- Conda: `~/.condarc`

并安装「系统文件夹保持英文」的常驻守护（见下文）。

已有配置会暂存到 `$TMPDIR/dotfiles-install.*`。安装成功后立即删除临时文件；安装失败时自动恢复原配置。正确的符号链接会直接跳过，如果目标是目录则拒绝删除。

Git 提交使用 GitHub noreply 邮箱，可以保留 GitHub 账号关联，同时不公开真实邮箱。

### 参数

```text
--dry-run        只显示将要执行的操作
--yes            跳过交互询问
--with-icloud    创建 ~/iCloud
--with-obsidian  创建 ~/Obsidian
--all             启用所有可选链接
```

例如：

```bash
./install.sh --dry-run --all
./install.sh --yes --with-icloud
```

也可以只安装 Fish 配置：

```bash
./scripts/link_fish.sh
```

## 系统文件夹显示英文

系统语言是中文时，Finder 会把 Desktop、Documents、Downloads 这些自带文件夹显示成
桌面、文稿、下载。真实文件名一直是英文，翻译来自
`/System/Library/CoreServices/SystemFolderLocalizations/zh_CN.lproj`，而 Finder 只有在
文件夹里存在一个空的隐藏标记 `.localized` 时才套用翻译。所以让文件夹保持英文的唯一办法
就是让这个标记始终不存在——它不是一个可以关掉的偏好设置。

麻烦在于 macOS 自己会把它写回来：系统更新/安装时，标准文件夹里的 `.localized` 会被重新
写入（本机 `/Applications`、`/Library`、`/Users`、`/System` 下的标记时间戳都与系统安装
时间完全一致），于是文件夹又变回中文。所以除了手工脚本，还有一个常驻守护。

### 在新电脑上

```bash
xcode-select --install                                   # 没有编译工具时先装
git clone git@github.com:mikukko/dotfiles.git ~/Codebase/Dev/dotfiles
cd ~/Codebase/Dev/dotfiles
./install.sh                                             # 就这一条
```

`install.sh` 会顺带把守护装好：链接配置 → 编译 `scripts/bin/delocalize-guard` → 安装
LaunchAgent `com.miku.delocalize-folders` 并立即清一次现有的 `.localized` → 跑自检。

克隆路径建议保持 `~/Codebase/Dev/dotfiles`：plist 里记的是绝对路径，换了位置重新跑一次
`./scripts/localized_guard.sh` 即可。机器上还没有 `cc` 时 `install.sh` 会跳过守护
并提示，装好 Xcode Command Line Tools 后再单独执行那个脚本。

### 守护做了什么

LaunchAgent `com.miku.delocalize-folders` 用 `WatchPaths` 直接盯住下面这 10 个
`.localized` 路径 —— 只有该路径真的出现时才触发，平时零开销，出现即删除；另有
`RunAtLoad`（登录时）和每 5 分钟兜底。清理记录写在 `~/Library/Logs/remove-localized.log`，
带标记文件的创建时间，方便回溯是哪次系统更新写回来的。

覆盖目录：`~/Desktop`、`~/Documents`、`~/Downloads`、`~/Movies`、`~/Music`、`~/Pictures`、
`~/Public`、`~/Applications`、`~/Library`、`/Applications`
（不想要 `~/Library`，就从 `remove_localized.sh` 的列表里删掉那一行再重装守护）。

```bash
./scripts/localized_guard.sh            # 编译 + 安装 + 自检（幂等）
./scripts/localized_guard.sh --check    # 只跑自检
./scripts/localized_guard.sh --status   # 状态 + 最近的清理记录
./scripts/localized_guard.sh --uninstall
```

手工清一次（例如刚装完系统、还没装 dotfiles 时）：

```bash
./scripts/remove_localized.sh
```

注意：守护之所以是**编译出来的二进制**（`scripts/delocalize-guard.c`）而不是 shell 脚本，
是因为 `~/Desktop`、`~/Documents`、`~/Downloads` 受 macOS 的 TCC 保护，从 LaunchAgent 里运行
的 shell 脚本删除这些目录下的文件会被拒绝（`rm: Operation not permitted`），换成编译并
ad-hoc 签名的二进制就正常。万一某个目录将来不再被自动清理，自检会把它列出来，按提示给
它一次性授权「系统设置 → 隐私与安全性 → 完全磁盘访问」即可。

另外：删掉标记后 Finder 立即生效，不需要 `killall Finder`（脚本里的 `--restart-finder`
只是保留旧行为）。

## 可选依赖

```bash
brew bundle --file ./Brewfile
```

配置中对 Homebrew、Java、pyenv 和 Starship 都有存在性检查，未安装时不会影响 Shell 启动。

## 维护脚本

维护脚本需要单独执行：

```bash
./scripts/clear_vscode_cache.sh
./scripts/clean_icon_cache.sh
./scripts/remove_localized.sh                  # 手工清一次
./scripts/localized_guard.sh --status  # 守护状态 + 最近的清理记录
./scripts/localized_guard.sh --check   # 检查守护是否正常工作
```

`clean_icon_cache.sh` 会请求管理员权限。执行清理脚本前请先阅读其内容。
