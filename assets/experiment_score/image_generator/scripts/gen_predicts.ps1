$compiler = ".\bin\ImageGenerator.exe"
# $predictItem = @("0.5","1","1.5","2","2.5","3","3.5","4","4.5","5","5.5","9.5","10")
$predictItem = @("0","0.5","1","1.5","2","2.5","3","3.5","4","4.5","5","5.5","6","6.5","7","7.5","8","8.5","9","9.5","10","已上传","未上传")

# 目标文件夹用于存放生成的图片（不删除原有内容）
$targetFolder = "..\scores"

# 确保目标文件夹存在（如果不存在则创建）
if (-Not (Test-Path $targetFolder)) {
    New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
    Write-Host "创建文件夹: $targetFolder" -ForegroundColor Green
} else {
    Write-Host "文件夹已存在，将在原有基础上追加/替换图片" -ForegroundColor Yellow
}

# 检查生成器是否存在
if (-Not (Test-Path $compiler)) {
    Write-Host "错误: 编译器不存在，请先运行 build_native.ps1 编译程序" -ForegroundColor Red
    Write-Host "运行命令: .\scripts\build_native.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "开始生成预测分数图片" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# 生成图片到预测文件夹
$successCount = 0
$failCount = 0
$replacedCount = 0
$newCount = 0

for ($i = 0; $i -lt $predictItem.Length; $i++) {
    $text = $predictItem[$i]
    # 将小数点转换为下划线作为文件名
    $filename = $text.Replace(".", "_") + ".predicted" + ".png"
    $outputPath = Join-Path $targetFolder $filename
    
    # 检查文件是否已存在
    $isReplacing = Test-Path $outputPath
    if ($isReplacing) {
        Write-Host "[$($i + 1)/$($predictItem.Length)] 替换文字: '$text' -> $filename" -ForegroundColor Cyan
    } else {
        Write-Host "[$($i + 1)/$($predictItem.Length)] 新增文字: '$text' -> $filename" -ForegroundColor Yellow
    }
    
    # 调用图片生成器，使用相同的参数
    & $compiler -t $text -f "Microsoft YaHei" -s 9 -st regular -w 50 -h 20 -x 1 -y -1 -fg "#000000" -bg "#00FFFFFF" -r cleartype -scale 1 -o $outputPath
    
    if ($LASTEXITCODE -eq 0) {
        if ($isReplacing) {
            Write-Host "  ✓ 成功替换: $outputPath" -ForegroundColor Green
            $replacedCount++
        } else {
            Write-Host "  ✓ 成功新增: $outputPath" -ForegroundColor Green
            $newCount++
        }
        $successCount++
    } else {
        Write-Host "  ✗ 生成失败" -ForegroundColor Red
        $failCount++
    }
    Write-Host ""
}

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "生成完成！" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "统计信息:" -ForegroundColor White
Write-Host "  总数: $($predictItem.Length)" -ForegroundColor White
Write-Host "  成功: $successCount" -ForegroundColor Green
Write-Host "    - 新增: $newCount" -ForegroundColor Green
Write-Host "    - 替换: $replacedCount" -ForegroundColor Cyan
Write-Host "  失败: $failCount" -ForegroundColor Red
Write-Host "  输出文件夹: $targetFolder" -ForegroundColor Yellow
Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "全部任务完成！" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan

