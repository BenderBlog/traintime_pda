# 定义要生成的文本和对应的目标文件路径（用于比较）
$test = @("已上传", "未上传", "0", "6.5", "6", "7", "7.5", "8", "8.5", "9")
$testPath = @("..\scores\updated.png", "..\scores\not_update.png", "..\scores\0.png", "..\scores\6_5.png", "..\scores\6.png", "..\scores\7.png", "..\scores\7_5.png", "..\scores\8.png", "..\scores\8_5.png", "..\scores\9.png")

# 编译器路径
$compiler = ".\bin\ImageGenerator.exe"

# 创建临时文件夹用于存放生成的图片
$tempFolder = ".\temp_generated"
if (Test-Path $tempFolder) {
    Remove-Item $tempFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null

# 检查编译器是否存在
if (-Not (Test-Path $compiler)) {
    Write-Host "错误: 编译器不存在，请先运行 build_native.ps1 编译程序" -ForegroundColor Red
    Write-Host "运行命令: .\build_native.ps1" -ForegroundColor Yellow
    exit 1
}

# 检查目标文件是否存在
$missingFiles = @()
for ($i = 0; $i -lt $testPath.Length; $i++) {
    if (-Not (Test-Path $testPath[$i])) {
        $missingFiles += $testPath[$i]
    }
}

if ($missingFiles.Length -gt 0) {
    Write-Host "警告: 以下目标文件不存在:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "开始生成实验分数图片（用于测试比较）" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# 存储生成的图片路径
$generatedFiles = @()

# 生成图片到临时文件夹
for ($i = 0; $i -lt $test.Length; $i++) {
    $text = $test[$i]
    $filename = Split-Path $testPath[$i] -Leaf
    $outputPath = Join-Path $tempFolder $filename
    
    Write-Host "[$($i + 1)/$($test.Length)] 生成文字: '$text' -> $filename" -ForegroundColor Yellow
    
    # 调用图片生成器，使用与目标文件相同的参数
    & $compiler -t $text -f "Microsoft YaHei" -s 9 -fs regular -w 50 -h 20 -x 1 -y -1 -fg "#000000" -bg "#00FFFFFF" -r cleartype -scale 1 -o $outputPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ 成功生成到临时文件夹" -ForegroundColor Green
        $generatedFiles += $outputPath
    } else {
        Write-Host "  ✗ 生成失败" -ForegroundColor Red
        $generatedFiles += $null
    }
    Write-Host ""
}

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "图片生成完成！开始相似度测试" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# 运行相似度测试 - 比较生成的图片与目标文件
$successCount = 0
$failCount = 0

for ($i = 0; $i -lt $test.Length; $i++) {
    if ($null -eq $generatedFiles[$i]) {
        Write-Host "跳过测试 [$($i + 1)/$($test.Length)]: $($test[$i]) (生成失败)" -ForegroundColor Yellow
        $failCount++
        continue
    }
    
    if (-Not (Test-Path $testPath[$i])) {
        Write-Host "跳过测试 [$($i + 1)/$($test.Length)]: $($test[$i]) (目标文件不存在)" -ForegroundColor Yellow
        $failCount++
        continue
    }
    
    Write-Host "-" * 60 -ForegroundColor DarkGray
    Write-Host "测试 [$($i + 1)/$($test.Length)]: $($test[$i])" -ForegroundColor Cyan
    Write-Host "  生成的: $($generatedFiles[$i])" -ForegroundColor Gray
    Write-Host "  目标的: $($testPath[$i])" -ForegroundColor Gray
    Write-Host "-" * 60 -ForegroundColor DarkGray
    
    dart run .\image_similarity_standalone.dart $generatedFiles[$i] $testPath[$i]
    
    if ($LASTEXITCODE -eq 0) {
        $successCount++
    } else {
        $failCount++
    }
    
    Write-Host ""
}

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "测试统计" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "总测试数: $($test.Length)" -ForegroundColor White
Write-Host "成功: $successCount" -ForegroundColor Green
Write-Host "失败: $failCount" -ForegroundColor Red
Write-Host ""

# 询问是否保留临时文件
Write-Host "临时生成的图片保存在: $tempFolder" -ForegroundColor Yellow
$response = Read-Host "是否删除临时文件？(Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Remove-Item $tempFolder -Recurse -Force
    Write-Host "临时文件已删除" -ForegroundColor Green
} else {
    Write-Host "临时文件已保留，可手动查看: $tempFolder" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "全部任务完成！" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
