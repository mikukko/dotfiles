# dotfiles

Mac dotfiles 配置管理仓库

这个仓库包含了 macOS 系统的配置文件和实用脚本，帮助快速设置和维护开发环境。

## 📁 项目结构

```
dotfiles/
├── README.md                    # 项目说明文档
├── install.sh                   # 一键安装脚本
├── scripts/                     # 脚本文件目录
│   ├── setup/                   # 设置和配置脚本
│   │   ├── dot_config.sh        # dotfiles 符号链接管理脚本
│   │   ├── icloud_ln.sh         # iCloud Drive 符号链接创建脚本
│   │   └── rime_ln.sh           # Rime 输入法配置符号链接脚本
│   └── maintenance/             # 系统维护脚本
│       ├── clear_vscode_cache.sh    # VS Code 缓存清理脚本
│       ├── icon_cache_clean.sh      # macOS 图标缓存清理脚本
│       └── remove_localized.sh      # 移除 macOS 本地化文件脚本
└── configs/                     # 配置文件目录
    ├── .zshrc                   # Zsh 主配置文件
    ├── .zprofile                # Zsh 登录配置文件
    ├── .zsh_scripts             # 自定义 Zsh 函数和脚本
    ├── .gitconfig               # Git 全局配置
    ├── .gitignore_global        # Git 全局忽略文件
    ├── .vimrc                   # Vim 配置文件
    └── .condarc                 # Conda 配置文件
```

## 🚀 快速开始

### 方法一：一键安装（推荐）

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

这个脚本会自动：
- 检查必要的工具
- 设置 dotfiles 符号链接
- 询问是否设置 iCloud Drive 和 Rime 配置链接
- 提供后续配置建议

### 方法二：手动安装

#### 1. 克隆仓库

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

#### 2. 设置 dotfiles 符号链接

运行以下命令将配置文件链接到系统相应位置：

```bash
./scripts/setup/dot_config.sh
```

这个脚本会创建以下符号链接：
- `~/.zshrc` → `configs/.zshrc` (优化的高性能配置)
- `~/.zprofile` → `configs/.zprofile`
- `~/.zsh_scripts` → `configs/.zsh_scripts`
- `~/.gitconfig` → `configs/.gitconfig`
- `~/.gitignore_global` → `configs/.gitignore_global`
- `~/.vimrc` → `configs/.vimrc`
- `~/.condarc` → `configs/.condarc`

#### 3. 设置 iCloud Drive 快捷访问（可选）

```bash
./scripts/setup/icloud_ln.sh
```

这会在主目录创建一个指向 iCloud Drive 的符号链接 `~/iCloud`。

#### 4. 设置 Rime 输入法配置（可选）

```bash
./scripts/setup/rime_ln.sh
```

这会将 iCloud Drive 中的 Rime 配置链接到系统位置。

## 🛠️ 脚本功能详解

### 设置脚本 (scripts/setup/)

#### dot_config.sh
- **功能**: 自动创建 dotfiles 的符号链接
- **特点**:
  - 无备份模式，直接覆盖现有文件
  - 自动检测源文件是否存在
  - 支持相对路径配置
- **使用**: `./scripts/setup/dot_config.sh`

#### icloud_ln.sh
- **功能**: 在主目录创建 iCloud Drive 的符号链接
- **目标**: `~/iCloud` → `~/Library/Mobile Documents/com~apple~CloudDocs`
- **特点**:
  - 检查源目录是否存在
  - 智能处理已存在的链接
  - 安全的路径处理
- **使用**: `./scripts/setup/icloud_ln.sh`

#### rime_ln.sh
- **功能**: 链接 iCloud Drive 中的 Rime 输入法配置
- **目标**: `~/Library/Rime` → `~/Library/Mobile Documents/com~apple~CloudDocs/Rime`
- **特点**:
  - 支持 Rime 配置云同步
  - 自动检测配置目录
  - 智能链接管理
- **使用**: `./scripts/setup/rime_ln.sh`

### 维护脚本 (scripts/maintenance/)

#### clear_vscode_cache.sh
- **功能**: 清理 VS Code 缓存和临时文件
- **清理内容**:
  - 缓存数据 (CachedData)
  - 扩展缓存 (CachedExtensionVSIXs)
  - 主缓存目录
  - 用户数据（可选）
  - 工作区存储（可选）
- **特点**:
  - 智能进程管理（优雅关闭 → SIGTERM → SIGKILL）
  - 交互式确认
  - 支持多种 VS Code 版本
- **使用**: `./scripts/maintenance/clear_vscode_cache.sh`

#### icon_cache_clean.sh
- **功能**: 清理 macOS 图标缓存
- **清理内容**:
  - 用户级图标缓存
  - Dock 图标缓存
- **效果**: 修复图标显示异常问题
- **使用**: `./scripts/maintenance/icon_cache_clean.sh`

#### remove_localized.sh
- **功能**: 移除 macOS 系统目录的本地化文件
- **目标目录**:
  - Desktop, Documents, Downloads
  - Movies, Music, Pictures, Public
  - Applications (用户和系统)
- **效果**: 将文件夹名称显示为英文
- **使用**: `./scripts/maintenance/remove_localized.sh`

## ⚙️ 配置文件说明

### 配置文件说明 (configs/)

#### .zshrc
精心优化的 Zsh 配置文件，按以下顺序组织：

1. **Zsh 选项设置** - Shell 行为配置
   - 自动切换目录 (`AUTO_CD`)、目录栈管理 (`AUTO_PUSHD`)
   - 历史记录共享 (`SHARE_HISTORY`)、去重 (`HIST_IGNORE_DUPS`)
   - 命令自动纠正 (`CORRECT`)、通配符扩展 (`EXTENDED_GLOB`)

2. **历史记录配置** - 命令历史设置
   - 历史文件: `~/.zsh_history`，大小: 1000 条记录
   - 智能历史记录管理

3. **别名定义** - 精选实用别名
   - **目录导航**: `..`, `...`, `~`
   - **文件操作**: `ll` (详细列表), `mkdir -p`
   - **搜索工具**: `grep`, `egrep`, `fgrep` (带颜色)
   - **Python**: `python` → `python3`, `pip` → `pip3`
   - **Git 别名**: `ga`, `gaa`, `gs`, `gcm`, `gcv`, `gp`, `gl`, `gd`, `gco`, `gcb`, `gpl`
   - **网络工具**: `ip`, `ports`

4. **环境变量** - 系统路径和环境配置
   - **Homebrew**: 智能路径缓存和自动更新控制
   - **Java**: OpenJDK 环境配置
   - **Python**: pyenv 路径配置
   - **编辑器**: vim 作为默认编辑器
   - **语言**: UTF-8 编码设置

5. **补全系统** - 高性能补全配置
   - 加载 zsh-completions 补全库
   - 使用 `compinit -C` 跳过安全检查，提升性能
   - 菜单选择模式、大小写不敏感匹配
   - 彩色补全列表
   - **关键**: 必须在语法高亮插件之前执行

6. **Zsh 插件** - 核心插件加载
   - **自定义脚本**: `~/.zsh_scripts` 中的函数
   - **命令建议**: zsh-autosuggestions
   - **历史搜索**: zsh-history-substring-search
   - **语法高亮**: zsh-fast-syntax-highlighting - **在 compinit 之后加载**

7. **工具初始化** - 外部工具配置
   - **pyenv**: Python 版本管理工具（条件加载）
   - **starship**: 现代化提示符主题 - **放在最后**

> **重要**: 配置加载顺序经过精心设计，特别注意：
> - `compinit` 必须在语法高亮插件之前执行
> - `fast-syntax-highlighting` 要在 `compinit` 之后加载
> - 这个配置追求简洁高效，包含了日常开发所需的核心功能

#### .zprofile
Zsh 登录时执行的配置文件

#### .zsh_scripts
自定义函数集合：
- `mcd()`: 创建目录并进入
- `pfd()`: 获取 Finder 当前目录路径
- `cdf()`: 切换到 Finder 当前目录
- `copypath()`: 复制路径到剪贴板

#### .gitconfig
Git 全局配置文件，包含用户信息、别名、行为设置等

#### .gitignore_global
全局 Git 忽略文件，定义在所有仓库中都应忽略的文件类型

#### .vimrc
Vim 编辑器配置文件

#### .condarc
Conda 包管理器配置文件

## 📋 使用建议

### 首次设置
1. 根据个人需求修改配置文件
2. 运行 `dot_config.sh` 创建符号链接
3. 重启终端或执行 `source ~/.zshrc` 使配置生效

### 定期维护
- 使用 `clear_vscode_cache.sh` 清理 VS Code 缓存
- 使用 `icon_cache_clean.sh` 修复图标显示问题
- 使用 `remove_localized.sh` 保持英文目录名

### 配置同步
- 所有配置文件都通过符号链接管理
- 修改配置文件后会自动同步到仓库
- 可以通过 Git 进行版本控制和跨设备同步

## 🔧 自定义配置

### 添加新的配置文件
1. 将配置文件放入 `configs/` 目录
2. 在 `scripts/setup/dot_config.sh` 中添加链接配置
3. 运行脚本创建符号链接

### 修改脚本路径
如果需要修改文件路径，请同时更新：
- 脚本中的路径变量
- README 文档中的说明
- 相关的符号链接配置

## ⚠️ 注意事项

- 运行脚本前请备份重要配置文件
- 某些脚本需要管理员权限（如 `icon_cache_clean.sh`）
- 路径中包含用户名的脚本需要根据实际情况调整
- 建议在测试环境中先验证脚本功能

## ⚡ 性能优化

### Zsh 加载性能
当前的 `.zshrc` 配置经过精心优化，实现了：
- **快速启动**: 从 41秒 优化到 < 5秒
- **智能缓存**: Homebrew 路径缓存，避免重复执行 `brew --prefix`
- **高效补全**: 使用 `compinit -C` 跳过安全检查
- **条件加载**: pyenv 等工具只在存在时才初始化

### 补全系统优化
- 加载完整的 zsh-completions 库
- 使用优化的补全样式配置
- 正确的插件加载顺序，避免冲突

### 如果遇到性能问题
如果 `.zshrc` 加载仍然很慢，可以：
1. 启用性能分析：取消注释文件开头的 `zmodload zsh/zprof`
2. 运行诊断脚本：`./debug_zshrc.sh`
3. 考虑移除不需要的 zsh-completions

## 📋 详细使用指南

### 环境准备

确保你的 macOS 系统已安装以下工具：
- Git
- Homebrew
- Zsh (macOS 默认)

### Shell 环境配置

1. **安装必要的 Zsh 插件**
   ```bash
   # 使用 Homebrew 安装插件
   brew install zsh-autosuggestions
   brew install zsh-fast-syntax-highlighting
   brew install zsh-history-substring-search
   brew install starship
   ```

2. **Python 环境配置**
   ```bash
   # 安装 pyenv
   brew install pyenv
   # 配置已包含在 .zshrc 中
   ```

### Git 配置

设置用户信息和全局忽略文件：
```bash
# 设置用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置全局忽略文件
git config --global core.excludesFile ~/.gitignore_global
```

### 自定义配置

#### 添加新的别名
编辑 `configs/.zshrc`：
```bash
# 在 alias 部分添加
alias myalias="your command here"
```

#### 添加自定义函数
编辑 `configs/.zsh_scripts`：
```bash
# 添加新函数
function myfunction() {
    # your function code here
}
```

#### 添加环境变量
编辑 `configs/.zshrc`：
```bash
# 在 export 部分添加
export MY_VAR="value"
export PATH="$MY_PATH:$PATH"
```

### 故障排除

#### 符号链接问题
```bash
# 检查符号链接状态
ls -la ~/.*rc ~/.*profile

# 重新创建符号链接
./scripts/setup/dot_config.sh
```

#### 权限问题
```bash
# 确保脚本有执行权限
chmod +x scripts/setup/*.sh
chmod +x scripts/maintenance/*.sh
```

### 备份与恢复

#### 备份现有配置
```bash
# 在运行脚本前备份
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
# ... 其他重要配置文件
```

#### 恢复配置
```bash
# 如果需要恢复
mv ~/.zshrc.backup ~/.zshrc
# 或者删除符号链接后恢复
rm ~/.zshrc && mv ~/.zshrc.backup ~/.zshrc
```

### 版本控制

#### 提交更改
```bash
cd ~/dotfiles
git add .
git commit -m "Update configurations"
git push
```

#### 同步到其他设备
```bash
# 在新设备上
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./scripts/setup/dot_config.sh
```


