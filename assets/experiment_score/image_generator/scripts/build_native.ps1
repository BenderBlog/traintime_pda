# ClearType 图片生成器 - 使用原生 C# 编译器构建

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  ClearType 图片生成器 - 原生构建  " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 查找 csc.exe
Write-Host "正在查找 C# 编译器..." -ForegroundColor Yellow

$cscPath = $null

# 查找最新版本的 .NET Framework 编译器
$frameworkPaths = @(
    "C:\Windows\Microsoft.NET\Framework64\v4.0.30319",
    "C:\Windows\Microsoft.NET\Framework\v4.0.30319"
)

foreach ($path in $frameworkPaths) {
    $testPath = Join-Path $path "csc.exe"
    if (Test-Path $testPath) {
        $cscPath = $testPath
        break
    }
}

# 如果没找到，尝试递归搜索
if (-not $cscPath) {
    $found = Get-ChildItem -Path "C:\Windows\Microsoft.NET\Framework*" -Recurse -Filter "csc.exe" -ErrorAction SilentlyContinue | 
             Sort-Object FullName -Descending | 
             Select-Object -First 1
    
    if ($found) {
        $cscPath = $found.FullName
    }
}

if (-not $cscPath) {
    Write-Host "✗ 未找到 C# 编译器 (csc.exe)" -ForegroundColor Red
    Write-Host ""
    Write-Host "解决方案：" -ForegroundColor Yellow
    Write-Host "1. 安装 .NET Framework 4.0 或更高版本" -ForegroundColor Gray
    Write-Host "2. 安装 Visual Studio (包含 C# 编译器)" -ForegroundColor Gray
    Write-Host "3. 安装 .NET SDK: https://dotnet.microsoft.com/download" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "✓ 找到编译器: $cscPath" -ForegroundColor Green
Write-Host ""

# 创建输出目录
if (-not (Test-Path ".\bin")) {
    New-Item -ItemType Directory -Path ".\bin" | Out-Null
}

Write-Host "开始编译..." -ForegroundColor Yellow
Write-Host ""

# 编译参数
$compileArgs = @(
    "/target:exe",
    "/out:bin\ImageGenerator.exe",
    "/platform:anycpu",
    "/optimize+",
    "/r:System.Drawing.dll",
    "/r:System.Windows.Forms.dll",
    "/nowarn:CS8632,CS8600,CS8602,CS8604",
    "image_generator.cs"
)

# 执行编译
& $cscPath $compileArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "  编译成功！" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    
    $exePath = ".\bin\ImageGenerator.exe"
    Write-Host "可执行文件: $exePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "使用方法:" -ForegroundColor Yellow
    Write-Host "  .\bin\ImageGenerator.exe -t ""你的文字"" -o output.png" -ForegroundColor Gray
    Write-Host "  .\bin\ImageGenerator.exe --help  (查看所有选项)" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host "  编译失败！" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "请检查错误信息并修复代码。" -ForegroundColor Yellow
    exit 1
}
