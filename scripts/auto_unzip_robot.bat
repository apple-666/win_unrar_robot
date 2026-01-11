@echo off
REM ============================================
REM 自动解压机器人 - Auto Unzip Robot
REM ============================================
REM 功能：自动解压压缩文件并识别复制游戏目录
REM ============================================

REM 设置CMD代码页为GBK（936），确保中文正确显示
chcp 936 >nul 2>&1
setlocal enabledelayedexpansion

REM ============================================
REM 【重要】用户配置区域 - 请在此修改以下参数
REM ============================================

REM 【必需】压缩文件源路径（要解压的压缩文件所在目录）
set "SOURCE_PATH=E:\game\SLG\ 0101\3"

REM 【必需】WinRAR程序路径（WinRAR.exe的完整路径）
set "WINRAR_PATH=D:\apple\software\WinRAR.exe"

REM 【必需】游戏目录目标路径（识别出的游戏目录将复制到此路径）
set "DEST_PATH=E:\game\SLG\ 0101\cursor_do_3"

REM 【可选】解压密码列表（按顺序尝试，空密码表示无密码）
REM 如果压缩文件有密码，请按顺序填写，脚本会自动尝试
set "PASSWORD1="
set "PASSWORD2=cracg.xyz"
set "PASSWORD3=cracg.com"

REM ============================================
REM 配置区域结束
REM ============================================

echo ============================================
echo 自动解压机器人 - Auto Unzip Robot
echo ============================================

echo [配置检查]
echo 源路径: !SOURCE_PATH!
echo WinRAR: !WINRAR_PATH!
echo 目标路径: !DEST_PATH!

REM 检查路径
if not exist "!SOURCE_PATH!" (
    echo 错误: 源路径不存在
    goto :end
)

if not exist "!WINRAR_PATH!" (
    echo 错误: WinRAR不存在
    goto :end
)

echo 路径检查通过

REM 切换目录
echo 切换到: !SOURCE_PATH!
cd /d "!SOURCE_PATH!" 2>nul
if errorlevel 1 (
    echo 错误: 无法切换目录
    goto :end
)

echo 开始扫描文件...

REM ============================================
REM Step1: 解压rar文件
REM ============================================
echo [Step1] 解压rar文件...
set "rar_count=0"
set "rar_processed=0"

for /r %%f in (*.rar) do (
    if exist "%%f" (
        set /a rar_count+=1
        set "rar_name=%%~nxf"

        REM 跳过分卷
        echo !rar_name! | findstr /R "\.part[2-9]" >nul
        if !errorlevel! equ 0 (
            echo [跳过] 分卷文件: !rar_name!
        ) else (
            echo [处理] !rar_name!

            REM 尝试多个密码解压
            call :TryUnzipWithPasswords "%%f" "."
            if !errorlevel! equ 0 (
                set /a rar_processed+=1
            )
        )
    )
)

echo [Step1完成] 找到 !rar_count! 个rar文件，成功解压 !rar_processed! 个
echo.

REM ============================================
REM Step2: 搜索jpg文件，转换为zip并解压
REM ============================================
echo [Step2] 搜索jpg文件并转换为zip...
set "jpg_count=0"
set "zip_count=0"
set "zip_processed=0"

REM 搜索所有jpg文件
for /r %%f in (*.jpg) do (
    if exist "%%f" (
        set /a jpg_count+=1
        set "jpg_file=%%f"
        set "jpg_name=%%~nxf"
        set "jpg_dir=%%~dpf"
        
        echo [发现] 找到jpg文件: !jpg_name!
        echo [提示] 位置: !jpg_dir!
        echo [转换] 将 .jpg 改为 .zip: !jpg_name!
        
        REM 转换为zip
        ren "!jpg_file!" "%%~nf.zip" >nul 2>&1
        if !errorlevel! equ 0 (
            set "zip_file=!jpg_dir!%%~nf.zip"
            echo [成功] 转换完成: %%~nf.zip
            
            REM 解压转换后的zip文件
            if exist "!zip_file!" (
                set /a zip_count+=1
                echo [解压] 开始解压: %%~nf.zip
                call :TryUnzipWithPasswords "!zip_file!" "!jpg_dir!"
                if !errorlevel! equ 0 (
                    set /a zip_processed+=1
                )
            )
        ) else (
            echo [失败] 转换失败: !jpg_name!
        )
        echo.
    )
)

echo [Step2完成] 找到 !jpg_count! 个jpg文件，转换为 !zip_count! 个zip文件，成功解压 !zip_processed! 个
echo.

REM ============================================
REM Step3: 解压所有zip文件
REM ============================================
echo [Step3] 搜索并解压所有zip文件...
set "zip_total_count=0"
set "zip_total_processed=0"

REM 搜索所有zip文件（包括原本的zip和转换后的zip）
for /r %%f in (*.zip) do (
    if exist "%%f" (
        set /a zip_total_count+=1
        set "zip_file=%%f"
        set "zip_name=%%~nxf"
        set "zip_dir=%%~dpf"
        
        echo [发现] 找到zip文件: !zip_name!
        echo [提示] 位置: !zip_dir!
        echo [解压] 开始解压: !zip_name!
        
        REM 尝试多个密码解压zip文件到其所在目录
        call :TryUnzipWithPasswords "!zip_file!" "!zip_dir!"
        if !errorlevel! equ 0 (
            set /a zip_total_processed+=1
        )
        echo.
    )
)

echo [Step3完成] 找到 !zip_total_count! 个zip文件，成功解压 !zip_total_processed! 个
echo.

REM ============================================
REM Step4: 识别所有游戏目录（当前目录层级有exe且无压缩文件）
REM ============================================
echo [Step4] 识别所有游戏目录...
set "game_dir_count=0"
set "game_dir_list=%TEMP%\game_dirs_%RANDOM%.txt"

REM 清空游戏目录列表文件
if exist "!game_dir_list!" del "!game_dir_list!" >nul 2>&1

REM 从上到下扫描所有目录，找出所有符合条件的游戏目录
REM 使用栈来管理待扫描的目录（只扫描一层，不递归）
set "scan_stack=%SOURCE_PATH%"

:scan_loop
if "!scan_stack!"=="" goto :scan_done

REM 取出栈顶目录
for /f "tokens=1* delims=;" %%a in ("!scan_stack!") do (
    set "current_dir=%%a"
    set "scan_stack=%%b"
)

if "!current_dir!"=="" goto :scan_loop

REM 进入目录，检查当前层级
pushd "!current_dir!" 2>nul
if errorlevel 1 goto :scan_loop

REM 检查当前目录层级是否有压缩文件（只检查rar和7z，zip可能是图片转换失败的残留）
set "has_archive=0"
if exist "*.rar" set "has_archive=1"
if exist "*.7z" set "has_archive=1"

REM 检查当前目录层级是否有exe文件
set "has_exe=0"
if exist "*.exe" set "has_exe=1"

REM 如果没有rar/7z压缩文件且有exe文件，则是游戏目录（忽略zip文件）
if !has_archive! equ 0 (
    if !has_exe! equ 1 (
        REM 检查这个目录是否已经记录过
        findstr /C:"!current_dir!" "!game_dir_list!" >nul 2>&1
        if !errorlevel! neq 0 (
            REM 新发现的游戏目录，记录到列表
            echo !current_dir!>>"!game_dir_list!"
            
            REM 获取游戏目录名
            for %%n in ("!current_dir!") do set "game_name=%%~nxn"
            
            echo [发现] 游戏目录: !game_name!
            echo [路径] !current_dir!
            echo.
            
            REM 找到游戏目录后，不再进入其子目录继续查找
            popd
            goto :scan_loop
        )
    )
)

REM 如果当前目录不是游戏目录，继续扫描其子目录（但只扫描一层）
REM 收集当前目录的直接子目录（使用绝对路径）
set "subdirs="
for /d %%d in (*) do (
    if exist "%%d" (
        REM 获取绝对路径
        set "subdir_path=!current_dir!\%%d"
        if "!subdirs!"=="" (
            set "subdirs=!subdir_path!"
        ) else (
            set "subdirs=!subdirs!;!subdir_path!"
        )
    )
)

popd

REM 将子目录添加到扫描栈（添加到栈顶，实现深度优先）
if not "!subdirs!"=="" (
    if "!scan_stack!"=="" (
        set "scan_stack=!subdirs!"
    ) else (
        set "scan_stack=!subdirs!;!scan_stack!"
    )
)

goto :scan_loop

:scan_done
REM 统计游戏目录数量
set "game_dir_count=0"
if exist "!game_dir_list!" (
    for /f %%i in ('type "!game_dir_list!" ^| find /c /v ""') do set "game_dir_count=%%i"
)

if !game_dir_count! gtr 0 (
    echo [Step4完成] 识别出 !game_dir_count! 个游戏目录
) else (
    echo [Step4完成] 未识别出游戏目录
)
echo.

REM ============================================
REM Step5: 复制所有游戏目录到目标路径（第二阶段）
REM ============================================
if !game_dir_count! gtr 0 (
    echo [Step5] 复制所有游戏目录到目标路径...
    
    REM 检查目标路径是否存在，不存在则创建
    if not exist "!DEST_PATH!" (
        echo [创建] 创建目标目录: !DEST_PATH!
        mkdir "!DEST_PATH!" >nul 2>&1
        if errorlevel 1 (
            echo [错误] 无法创建目标目录: !DEST_PATH!
            goto :step5_done
        )
    )
    
    REM 遍历所有游戏目录并复制
    set "copy_success=0"
    set "copy_skip=0"
    set "copy_fail=0"
    
    if exist "!game_dir_list!" (
        for /f "usebackq delims=" %%g in ("!game_dir_list!") do (
            set "game_dir_path=%%g"
            
            REM 检查游戏目录是否存在
            if exist "!game_dir_path!" (
                REM 获取游戏目录名
                for %%n in ("!game_dir_path!") do set "game_dir_name=%%~nxn"
                
                REM 构建目标路径（目标目录 + 游戏目录名）
                set "target_game_path=!DEST_PATH!\!game_dir_name!"
                
                REM 检查目标位置是否已存在同名目录
                if exist "!target_game_path!" (
                    echo [跳过] 目标位置已存在: !game_dir_name!
                    set /a copy_skip+=1
                ) else (
                    REM 复制游戏目录到目标路径
                    echo [复制] !game_dir_name!
                    echo [源目录] !game_dir_path!
                    echo [目标目录] !target_game_path!
                    
                    REM 使用xcopy复制目录（/E: 包括子目录和空目录, /I: 假设目标是目录, /Y: 覆盖已存在文件）
                    xcopy "!game_dir_path!" "!target_game_path!\" /E /I /Y /Q >nul 2>&1
                    if !errorlevel! equ 0 (
                        echo [成功] 复制完成: !game_dir_name!
                        set /a copy_success+=1
                    ) else (
                        echo [失败] 复制失败: !game_dir_name!
                        set /a copy_fail+=1
                    )
                )
                echo.
            )
        )
    )
    
    echo [Step5完成] 成功: !copy_success! 个, 跳过: !copy_skip! 个, 失败: !copy_fail! 个
) else (
    echo [Step5] 未识别出游戏目录，跳过复制操作
)

:step5_done
REM 清理临时文件
if exist "!game_dir_list!" del "!game_dir_list!" >nul 2>&1
echo.

REM ============================================
REM 总结
REM ============================================
echo ============================================
echo 处理完成！
echo ============================================
echo RAR文件: 找到 !rar_count! 个，成功 !rar_processed! 个
if defined jpg_count (
    echo JPG文件: 找到 !jpg_count! 个，转换为zip !zip_count! 个，成功解压 !zip_processed! 个
)
if defined zip_total_count (
    echo ZIP文件: 找到 !zip_total_count! 个，成功解压 !zip_total_processed! 个
)
echo 游戏目录: 识别出 !game_dir_count! 个
if !game_dir_count! gtr 0 (
    if defined copy_success (
        echo 复制状态: 成功 !copy_success! 个, 跳过 !copy_skip! 个, 失败 !copy_fail! 个
    )
) else (
    echo 游戏目录: 未识别出
)
echo ============================================

REM ============================================
REM 尝试多个密码解压文件
REM ============================================
:TryUnzipWithPasswords
set "ARCHIVE_FILE=%~1"
set "EXTRACT_DIR=%~2"
set "ARCHIVE_NAME=%~nx1"

REM 检查文件是否还存在
if not exist "!ARCHIVE_FILE!" exit /b 1

REM 尝试密码1（空密码）
if "!PASSWORD1!"=="" (
    echo [尝试] 解压 !ARCHIVE_NAME! 密码: 空
    "!WINRAR_PATH!" x -y -o+ -p- "!ARCHIVE_FILE!" "!EXTRACT_DIR!\" >nul 2>&1
) else (
    echo [尝试] 解压 !ARCHIVE_NAME! 密码: !PASSWORD1!
    "!WINRAR_PATH!" x -y -o+ -p"!PASSWORD1!" "!ARCHIVE_FILE!" "!EXTRACT_DIR!\" >nul 2>&1
)
if !errorlevel! equ 0 (
    REM 检查是否真的解压出了文件
    dir /b "!EXTRACT_DIR!" 2>nul | findstr /R "." >nul
    if !errorlevel! equ 0 (
        if "!PASSWORD1!"=="" (
            echo [成功] 解压完成: !ARCHIVE_NAME! 密码: 空
        ) else (
            echo [成功] 解压完成: !ARCHIVE_NAME! 密码: !PASSWORD1!
        )
        exit /b 0
    )
)

REM 尝试密码2
if not "!PASSWORD2!"=="" (
    echo [尝试] 解压 !ARCHIVE_NAME! 密码: !PASSWORD2!
    "!WINRAR_PATH!" x -y -o+ -p"!PASSWORD2!" "!ARCHIVE_FILE!" "!EXTRACT_DIR!\" >nul 2>&1
    if !errorlevel! equ 0 (
        dir /b "!EXTRACT_DIR!" 2>nul | findstr /R "." >nul
        if !errorlevel! equ 0 (
            echo [成功] 解压完成: !ARCHIVE_NAME! 密码: !PASSWORD2!
            exit /b 0
        )
    )
)

REM 尝试密码3
if not "!PASSWORD3!"=="" (
    echo [尝试] 解压 !ARCHIVE_NAME! 密码: !PASSWORD3!
    "!WINRAR_PATH!" x -y -o+ -p"!PASSWORD3!" "!ARCHIVE_FILE!" "!EXTRACT_DIR!\" >nul 2>&1
    if !errorlevel! equ 0 (
        dir /b "!EXTRACT_DIR!" 2>nul | findstr /R "." >nul
        if !errorlevel! equ 0 (
            echo [成功] 解压完成: !ARCHIVE_NAME! 密码: !PASSWORD3!
            exit /b 0
        )
    )
)

REM 所有密码都失败
echo [失败] 解压失败: !ARCHIVE_NAME! 所有密码都失败
exit /b 1

:end
echo.
echo ============================================
echo 脚本执行完成！
echo ============================================
echo 按任意键退出...
pause >nul
