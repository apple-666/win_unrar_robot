@echo off
chcp 65001 >nul 2>&1
echo ============================================
echo GitHub 上传助手
echo ============================================
echo.

REM 检查Git是否安装
git --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Git，请先安装Git for Windows
    echo 下载地址: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo [检查] Git已安装
git --version
echo.

REM 检查是否已初始化Git仓库
if not exist ".git" (
    echo [初始化] 正在初始化Git仓库...
    git init
    if errorlevel 1 (
        echo [错误] Git初始化失败
        pause
        exit /b 1
    )
    echo [成功] Git仓库初始化完成
    echo.
) else (
    echo [检查] Git仓库已存在
    echo.
)

REM 提示用户配置信息
echo ============================================
echo 请提供以下信息：
echo ============================================
set /p GITHUB_USERNAME="GitHub用户名: "
set /p GITHUB_EMAIL="GitHub邮箱: "
set /p REPO_NAME="仓库名称（例如: auto-unzip-robot）: "
echo.

REM 配置Git用户信息
echo [配置] 正在配置Git用户信息...
git config user.name "%GITHUB_USERNAME%"
git config user.email "%GITHUB_EMAIL%"
echo [成功] Git用户信息配置完成
echo.

REM 添加文件
echo [添加] 正在添加文件...
git add .
if errorlevel 1 (
    echo [错误] 添加文件失败
    pause
    exit /b 1
)
echo [成功] 文件添加完成
echo.

REM 检查是否有更改
git status --porcelain >nul 2>&1
if errorlevel 1 (
    echo [提示] 没有需要提交的更改
    echo.
) else (
    REM 提交更改
    echo [提交] 正在提交更改...
    git commit -m "Initial commit: 自动解压机器人项目"
    if errorlevel 1 (
        echo [错误] 提交失败
        pause
        exit /b 1
    )
    echo [成功] 提交完成
    echo.
)

REM 提示创建远程仓库
echo ============================================
echo 下一步操作：
echo ============================================
echo 1. 访问 https://github.com/new 创建新仓库
echo 2. 仓库名称: %REPO_NAME%
echo 3. 描述: Windows平台下的智能压缩文件解压工具
echo 4. 选择 Public 或 Private
echo 5. 不要勾选 "Initialize this repository with a README"
echo 6. 点击 "Create repository"
echo.
echo 创建完成后，按任意键继续...
pause >nul
echo.

REM 添加远程仓库
echo [远程] 正在添加远程仓库...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git
if errorlevel 1 (
    echo [错误] 添加远程仓库失败
    pause
    exit /b 1
)
echo [成功] 远程仓库添加完成
echo.

REM 设置主分支
git branch -M main >nul 2>&1

REM 推送
echo [推送] 正在推送到GitHub...
echo [提示] 如果提示输入用户名和密码：
echo        - 用户名: 输入你的GitHub用户名
echo        - 密码: 输入Personal Access Token（不是GitHub密码）
echo        生成Token: https://github.com/settings/tokens
echo.
git push -u origin main
if errorlevel 1 (
    echo.
    echo [错误] 推送失败
    echo [提示] 可能需要配置Personal Access Token
    echo        访问: https://github.com/settings/tokens
    echo        生成新token，权限选择 repo
    echo        推送时密码处输入token
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo [成功] 项目已成功上传到GitHub！
echo ============================================
echo 仓库地址: https://github.com/%GITHUB_USERNAME%/%REPO_NAME%
echo ============================================
echo.
pause
