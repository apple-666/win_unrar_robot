# 自动解压机器人

> Windows 平台下的智能压缩文件解压工具

## 📁 项目结构

```
win_rar_autor_by_cursor/
├── scripts/
│   └── auto_unzip_robot.bat    # 主脚本（自动解压机器人）
├── peng_src/                   # 源文件备份
├── out/                        # 输出目录
└── README.md                   # 项目说明
```

## 🚀 快速开始

### 1. 配置参数（重要）
编辑 `scripts/auto_unzip_robot.bat`，在文件开头的【用户配置区域】修改以下参数：

```batch
REM 【必需】压缩文件源路径（要解压的压缩文件所在目录）
set "SOURCE_PATH=E:\game\SLG\ 0101\2"

REM 【必需】WinRAR程序路径（WinRAR.exe的完整路径）
set "WINRAR_PATH=D:\apple\software\WinRAR.exe"

REM 【必需】游戏目录目标路径（识别出的游戏目录将复制到此路径）
set "DEST_PATH=E:\game\SLG\ 0101\cursor_do_2"

REM 【可选】解压密码列表（按顺序尝试，空密码表示无密码）
set "PASSWORD1="
set "PASSWORD2=cracg.xyz"
set "PASSWORD3=cracg.com"
```

### 2. 执行脚本
```batch
cd scripts
auto_unzip_robot.bat
```

## 🎯 执行流程

### 第一阶段：解压所有压缩文件

**Step1: 解压RAR文件**
- 扫描所有 `.rar` 文件
- 跳过 `.part2.rar` 等分卷文件
- 尝试多个密码解压（空密码 → cracg.xyz → cracg.com）

**Step2: JPG转ZIP并解压**
- 搜索所有 `.jpg` 文件
- 重命名为 `.zip` 并解压

**Step3: 解压所有ZIP文件**
- 递归搜索所有 `.zip` 文件
- 尝试多个密码解压

### 第二阶段：识别并复制游戏目录

**Step4: 识别游戏目录**
- 扫描目录结构
- 识别条件：当前目录有 `.exe` 文件且无 `.rar`/`.7z` 压缩文件
- 忽略 `.zip` 文件（可能是图片转换失败的残留）

**Step5: 复制游戏目录**
- 将识别出的游戏目录复制到 `DEST_PATH`
- 跳过已存在的目录

## ⚙️ 配置说明

### 必需配置（在脚本开头修改）
- **SOURCE_PATH**：压缩文件源路径（要解压的压缩文件所在目录）
- **WINRAR_PATH**：WinRAR程序完整路径（如：`D:\apple\software\WinRAR.exe`）
- **DEST_PATH**：游戏目录目标路径（识别出的游戏目录将复制到此路径）

### 密码配置
脚本会按顺序尝试以下密码：
1. 空密码（无密码）
2. `cracg.xyz`
3. `cracg.com`

### 处理规则
- ✅ 只解压 `.part1.rar`，跳过其他分卷
- ✅ 自动处理嵌套压缩文件
- ✅ 支持多密码自动尝试
- ✅ 不删除源文件（安全模式）

## 📋 使用示例

### 示例1：单个游戏目录
```
源路径: E:\game\SLG\ 0101\2\荒诞\pc\pc
→ 解压 pc.rar
→ 识别游戏目录
→ 复制到目标路径
```

### 示例2：多个游戏目录
```
源路径: E:\game\SLG\ 0101\2
→ 解压所有压缩文件
→ 识别多个游戏目录
→ 批量复制到目标路径
```

## 🔧 故障排除

### 常见问题

1. **脚本闪退**
   - 检查路径配置是否正确
   - 确保 WinRAR 路径存在

2. **解压失败**
   - 检查压缩文件是否损坏
   - 确认密码是否正确

3. **未识别游戏目录**
   - 确认目录中有 `.exe` 文件
   - 检查是否有未解压的 `.rar` 文件

4. **CMD乱码**
   - 脚本已设置 `chcp 936`（GBK编码）
   - 如仍有问题，检查系统区域设置

## 📝 注意事项

- 脚本执行完成后不会自动退出（按任意键退出）
- 源文件不会被删除，可安全重复执行
- 目标路径已存在的目录会被跳过
- 支持中文路径和文件名