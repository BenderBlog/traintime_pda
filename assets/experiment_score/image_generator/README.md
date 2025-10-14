# ClearType 文字图片生成器

Windows 原生 GDI+ ClearType 文字渲染工具，支持透明背景和超采样增强，适用于PDA项目生成物理实验分数图片的预测图片。

## ✨ 主要功能

- ✅ **ClearType 渲染** - Windows 高质量亚像素字体渲染
- ✅ **透明背景** - 完全支持 Alpha 通道透明度
- ✅ **超采样技术** - 增强小图片的 ClearType 效果
- ✅ **丰富参数** - 字体、大小、颜色、位置、字间距等
- ✅ **命令行友好** - 易于集成自动化脚本
- ✅ **无需依赖** - 仅需 Windows 自带 .NET Framework

## 🚀 编译程序

```powershell
.\scripts\build_native.ps1
```

## 📋 完整参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-t`, `--text` | 文字内容 | "Sample Text" |
| `-f`, `--font` | 字体名称 | "Microsoft YaHei" |
| `-s`, `--size` | 字体大小 | 24 |
| `-fs`, `--fontstyle` | 字体样式 | regular |
| `-ls`, `--letterspacing` | 字间距（像素） | 0 |
| `-x` | X坐标 | 10 |
| `-y` | Y坐标 | 10 |
| `-w`, `--width` | 图片宽度 | 800 |
| `-h`, `--height` | 图片高度 | 200 |
| `-fg`, `--forecolor` | 前景色 | Black |
| `-bg`, `--backcolor` | 背景色 | White |
| `-o`, `--output` | 输出文件 | output.png |
| `-dpi` | 分辨率 | 96 |
| `-r`, `--rendering` | 渲染模式 | cleartype |
| `-scale`, `--scale` | 超采样倍数 (1-8) | 1 |

### 项目中的推荐样式参数

~~~powershell
.\bin\ImageGenerator.exe -t "文字" -f "Microsoft YaHei" -s 9 -w 50 -h 20 -x 1 -y -1 -fg "#000000" -bg "#00FFFFFF" -st regular -r cleartype -scale 1 -o "文字.png"  
~~~

## 📄 查看帮助

```powershell
.\bin\ImageGenerator.exe --help
```

## 📄 脚本

~~~powershell
.\scripts\build_native.ps1  # 使用csc构建image_generator.cs
.\scripts\gen_predict.ps1   # 生成预测图片文件
.\scripts\test_scores.ps1   # 使用已有图片文件进行测试
~~~

## 📦 文件结构

~~~plaintext
image_generator/
├── bin/ImageGenerator.exe          # 编译后的可执行文件
├── README.md                       # README 文件
├── scripts           
│   ├── build_native.ps1            # 使用csc构建image_generator.cs
│   ├── gen_predict.ps1             # 生成预测图片文件
│   └── test_scores.ps1             # 使用已有图片文件进行测试
├── .gitignore
├── image_generator.cs              # 图片生成器的源代码
├── image_similarity_standalone.cs  # 相似度计算代码
├── ImageGenerator.csproj           # 编译配置文件
└── README.md
~~~

## 系统要求

- Windows 7 或更高版本
- .NET Framework 4.0 或更高版本（Windows 自带）
