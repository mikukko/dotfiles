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
    └── remove_localized.sh
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
./scripts/remove_localized.sh
```

`clean_icon_cache.sh` 会请求管理员权限。执行清理脚本前请先阅读其内容。
