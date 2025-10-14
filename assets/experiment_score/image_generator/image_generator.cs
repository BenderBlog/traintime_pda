using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Drawing.Text;

namespace ClearTypeImageGenerator
{
    /// <summary>
    /// ClearType文字图片生成器 - 命令行工具
    /// </summary>
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                // 解析命令行参数
                ImageConfig config = ParseArguments(args);
                
                if (config == null)
                {
                    ShowHelp();
                    return;
                }

                // 生成图片
                GenerateImage(config);
                
                Console.WriteLine("图片已成功生成: " + config.OutputPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine("错误: " + ex.Message);
                Environment.Exit(1);
            }
        }

        /// <summary>
        /// 图片配置类
        /// </summary>
        class ImageConfig
        {
            public ImageConfig()
            {
                Text = "Sample Text";
                FontFamily = "Microsoft YaHei";
                FontSize = 24;
                FontStyle = FontStyle.Regular;
                LetterSpacing = 0;
                X = 10;
                Y = 10;
                Width = 800;
                Height = 200;
                ForeColor = Color.Black;
                BackColor = Color.White;
                OutputPath = "output.png";
                Dpi = 96;
                RenderingHint = TextRenderingHint.ClearTypeGridFit;
                Scale = 1;
            }
            
            public string Text { get; set; }
            public string FontFamily { get; set; }
            public float FontSize { get; set; }
            public FontStyle FontStyle { get; set; }
            public float LetterSpacing { get; set; }
            public int X { get; set; }
            public int Y { get; set; }
            public int Width { get; set; }
            public int Height { get; set; }
            public Color ForeColor { get; set; }
            public Color BackColor { get; set; }
            public string OutputPath { get; set; }
            public int Dpi { get; set; }
            public TextRenderingHint RenderingHint { get; set; }
            public int Scale { get; set; }
        }

        /// <summary>
        /// 解析命令行参数
        /// </summary>
        static ImageConfig ParseArguments(string[] args)
        {
            if (args.Length == 0 || args[0] == "-h" || args[0] == "--help" || args[0] == "/?")
            {
                return null;
            }

            ImageConfig config = new ImageConfig();

            for (int i = 0; i < args.Length; i++)
            {
                string arg = args[i].ToLower();
                
                if (arg == "-t" || arg == "--text")
                {
                    if (i + 1 < args.Length) config.Text = args[++i];
                }
                else if (arg == "-f" || arg == "--font")
                {
                    if (i + 1 < args.Length) config.FontFamily = args[++i];
                }
                else if (arg == "-s" || arg == "--size")
                {
                    if (i + 1 < args.Length) config.FontSize = float.Parse(args[++i]);
                }
                else if (arg == "-st" || arg == "--style")
                {
                    if (i + 1 < args.Length)
                    {
                        string style = args[++i].ToLower();
                        if (style == "bold")
                            config.FontStyle = FontStyle.Bold;
                        else if (style == "italic")
                            config.FontStyle = FontStyle.Italic;
                        else if (style == "bolditalic")
                            config.FontStyle = FontStyle.Bold | FontStyle.Italic;
                        else if (style == "underline")
                            config.FontStyle = FontStyle.Underline;
                        else if (style == "strikeout")
                            config.FontStyle = FontStyle.Strikeout;
                        else
                            config.FontStyle = FontStyle.Regular;
                    }
                }
                else if (arg == "-ls" || arg == "--letterspacing")
                {
                    if (i + 1 < args.Length) config.LetterSpacing = float.Parse(args[++i]);
                }
                else if (arg == "-x")
                {
                    if (i + 1 < args.Length) config.X = int.Parse(args[++i]);
                }
                else if (arg == "-y")
                {
                    if (i + 1 < args.Length) config.Y = int.Parse(args[++i]);
                }
                else if (arg == "-w" || arg == "--width")
                {
                    if (i + 1 < args.Length) config.Width = int.Parse(args[++i]);
                }
                else if (arg == "-h" || arg == "--height")
                {
                    if (i + 1 < args.Length) config.Height = int.Parse(args[++i]);
                }
                else if (arg == "-fg" || arg == "--forecolor")
                {
                    if (i + 1 < args.Length) config.ForeColor = ParseColor(args[++i]);
                }
                else if (arg == "-bg" || arg == "--backcolor")
                {
                    if (i + 1 < args.Length) config.BackColor = ParseColor(args[++i]);
                }
                else if (arg == "-o" || arg == "--output")
                {
                    if (i + 1 < args.Length) config.OutputPath = args[++i];
                }
                else if (arg == "-dpi")
                {
                    if (i + 1 < args.Length) config.Dpi = int.Parse(args[++i]);
                }
                else if (arg == "-r" || arg == "--rendering")
                {
                    if (i + 1 < args.Length)
                    {
                        string hint = args[++i].ToLower();
                        if (hint == "aliased")
                            config.RenderingHint = TextRenderingHint.SingleBitPerPixelGridFit;
                        else if (hint == "antialias")
                            config.RenderingHint = TextRenderingHint.AntiAlias;
                        else if (hint == "antialiasgridifit")
                            config.RenderingHint = TextRenderingHint.AntiAliasGridFit;
                        else if (hint == "cleartype")
                            config.RenderingHint = TextRenderingHint.ClearTypeGridFit;
                        else if (hint == "system")
                            config.RenderingHint = TextRenderingHint.SystemDefault;
                        else
                            config.RenderingHint = TextRenderingHint.ClearTypeGridFit;
                    }
                }
                else if (arg == "-scale" || arg == "--scale")
                {
                    if (i + 1 < args.Length) config.Scale = int.Parse(args[++i]);
                }
            }

            return config;
        }

        /// <summary>
        /// 解析颜色字符串 (支持 #RRGGBB, #AARRGGBB 或颜色名称)
        /// </summary>
        static Color ParseColor(string colorStr)
        {
            if (colorStr.StartsWith("#"))
            {
                if (colorStr.Length == 7) // #RRGGBB
                {
                    return ColorTranslator.FromHtml(colorStr);
                }
                else if (colorStr.Length == 9) // #AARRGGBB
                {
                    int argb = Convert.ToInt32(colorStr.Substring(1), 16);
                    return Color.FromArgb(argb);
                }
            }
            
            // 尝试作为颜色名称解析
            return Color.FromName(colorStr);
        }

        /// <summary>
        /// 生成ClearType文字图片
        /// </summary>
        static void GenerateImage(ImageConfig config)
        {
            int scale = config.Scale;
            if (scale < 1) scale = 1;
            if (scale > 8) scale = 8;
            
            // 如果使用超采样，先创建放大的图片
            int renderWidth = config.Width * scale;
            int renderHeight = config.Height * scale;
            float renderFontSize = config.FontSize * scale;
            int renderX = config.X * scale;
            int renderY = config.Y * scale;
            float renderLetterSpacing = config.LetterSpacing * scale;
            
            // 检测是否需要透明背景的 ClearType 特殊处理
            bool needTransparentClearType = config.BackColor.A < 255 && 
                                           config.RenderingHint == TextRenderingHint.ClearTypeGridFit;
            
            // ClearType 需要实心背景，如果背景透明则先用白色渲染
            Color renderBackColor = needTransparentClearType ? Color.White : config.BackColor;
            
            // 创建渲染位图，支持透明度
            Bitmap renderBmp = new Bitmap(renderWidth, renderHeight, PixelFormat.Format32bppArgb);
            renderBmp.SetResolution(config.Dpi, config.Dpi);

            using (Graphics g = Graphics.FromImage(renderBmp))
            {
                // 设置高质量渲染
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                g.TextRenderingHint = config.RenderingHint;

                // 填充背景
                g.Clear(renderBackColor);

                // 创建字体（使用放大的尺寸）
                using (Font font = new Font(config.FontFamily, renderFontSize, config.FontStyle, GraphicsUnit.Point))
                {
                    // 如果需要字间距，手动绘制每个字符
                    if (config.LetterSpacing != 0)
                    {
                        DrawTextWithLetterSpacing(g, config.Text, font, config.ForeColor, 
                            renderX, renderY, renderLetterSpacing);
                    }
                    else
                    {
                        // 直接绘制文字
                        using (SolidBrush brush = new SolidBrush(config.ForeColor))
                        {
                            g.DrawString(config.Text, font, brush, renderX, renderY);
                        }
                    }
                }
            }

            // 如果需要透明背景的 ClearType，将白色背景替换为透明
            if (needTransparentClearType)
            {
                MakeBackgroundTransparent(renderBmp, Color.White, config.BackColor);
            }

            Bitmap finalBmp;
            
            // 如果使用了超采样，需要缩小到目标尺寸
            if (scale > 1)
            {
                finalBmp = new Bitmap(config.Width, config.Height, PixelFormat.Format32bppArgb);
                finalBmp.SetResolution(config.Dpi, config.Dpi);
                
                using (Graphics g = Graphics.FromImage(finalBmp))
                {
                    // 使用高质量插值缩小图片，保留 ClearType 的亚像素细节
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                    g.CompositingQuality = CompositingQuality.HighQuality;
                    
                    g.DrawImage(renderBmp, 0, 0, config.Width, config.Height);
                }
                
                renderBmp.Dispose();
            }
            else
            {
                finalBmp = renderBmp;
            }

            // 保存图片
            ImageFormat format = GetImageFormat(config.OutputPath);
            finalBmp.Save(config.OutputPath, format);
            finalBmp.Dispose();
        }
        
        /// <summary>
        /// 将指定颜色的背景替换为透明（保留 ClearType 的边缘效果）
        /// </summary>
        static void MakeBackgroundTransparent(Bitmap bmp, Color oldBackground, Color newBackground)
        {
            // 锁定位图以直接访问像素
            Rectangle rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
            System.Drawing.Imaging.BitmapData bmpData = 
                bmp.LockBits(rect, System.Drawing.Imaging.ImageLockMode.ReadWrite, bmp.PixelFormat);
            
            IntPtr ptr = bmpData.Scan0;
            int bytes = Math.Abs(bmpData.Stride) * bmp.Height;
            byte[] rgbValues = new byte[bytes];
            
            // 复制像素数据到数组
            System.Runtime.InteropServices.Marshal.Copy(ptr, rgbValues, 0, bytes);
            
            // 遍历每个像素
            for (int i = 0; i < rgbValues.Length; i += 4)
            {
                byte b = rgbValues[i];
                byte g = rgbValues[i + 1];
                byte r = rgbValues[i + 2];
                byte a = rgbValues[i + 3];
                
                // 检测是否为背景色（允许一定容差，因为 ClearType 可能略微改变边缘颜色）
                int diffR = Math.Abs(r - oldBackground.R);
                int diffG = Math.Abs(g - oldBackground.G);
                int diffB = Math.Abs(b - oldBackground.B);
                
                // 如果是纯背景色，替换为目标背景色（通常是透明）
                if (diffR < 3 && diffG < 3 && diffB < 3)
                {
                    rgbValues[i] = newBackground.B;
                    rgbValues[i + 1] = newBackground.G;
                    rgbValues[i + 2] = newBackground.R;
                    rgbValues[i + 3] = newBackground.A;
                }
                // 如果是文字边缘（ClearType 产生的颜色混合），保持原样或调整透明度
                else if (diffR > 0 || diffG > 0 || diffB > 0)
                {
                    // 保持 ClearType 边缘效果，但如果背景是透明的，可能需要调整
                    // 这里保持原样以保留 ClearType 的 RGB 亚像素效果
                }
            }
            
            // 将修改后的数据复制回位图
            System.Runtime.InteropServices.Marshal.Copy(rgbValues, 0, ptr, bytes);
            bmp.UnlockBits(bmpData);
        }

        /// <summary>
        /// 绘制带字间距的文字
        /// </summary>
        static void DrawTextWithLetterSpacing(Graphics g, string text, Font font, 
            Color color, float x, float y, float letterSpacing)
        {
            using (SolidBrush brush = new SolidBrush(color))
            {
                float currentX = x;
                foreach (char c in text)
                {
                    string charStr = c.ToString();
                    SizeF charSize = g.MeasureString(charStr, font);
                    g.DrawString(charStr, font, brush, currentX, y);
                    currentX += charSize.Width + letterSpacing;
                }
            }
        }

        /// <summary>
        /// 根据文件扩展名获取图片格式
        /// </summary>
        static ImageFormat GetImageFormat(string filePath)
        {
            string ext = System.IO.Path.GetExtension(filePath).ToLower();
            
            if (ext == ".png")
                return ImageFormat.Png;
            else if (ext == ".jpg" || ext == ".jpeg")
                return ImageFormat.Jpeg;
            else if (ext == ".bmp")
                return ImageFormat.Bmp;
            else if (ext == ".gif")
                return ImageFormat.Gif;
            else if (ext == ".tiff" || ext == ".tif")
                return ImageFormat.Tiff;
            else
                return ImageFormat.Png;
        }

        /// <summary>
        /// 显示帮助信息
        /// </summary>
        static void ShowHelp()
        {
            Console.WriteLine(@"
ClearType文字图片生成器 v1.0
====================================

用法: ImageGenerator [选项]

选项:
  -t,  --text <文本>           要渲染的文字 (默认: ""Sample Text"")
  -f,  --font <字体名>         字体名称 (默认: ""Microsoft YaHei"")
  -s,  --size <大小>           字体大小 (默认: 24)
  -st, --style <样式>          字体样式: regular, bold, italic, bolditalic, underline, strikeout (默认: regular)
  -ls, --letterspacing <间距>  字间距，单位像素 (默认: 0)
  -x   <位置>                  文字X坐标 (默认: 10)
  -y   <位置>                  文字Y坐标 (默认: 10)
  -w,  --width <宽度>          图片宽度 (默认: 800)
  -h,  --height <高度>         图片高度 (默认: 200)
  -fg, --forecolor <颜色>      前景色 (默认: Black)，支持 #RRGGBB 或颜色名称
  -bg, --backcolor <颜色>      背景色 (默认: White)，支持 #RRGGBB 或颜色名称
  -o,  --output <文件路径>     输出文件路径 (默认: ""output.png"")
  -dpi <分辨率>                DPI分辨率 (默认: 96)
  -r,  --rendering <模式>      渲染模式: cleartype, antialias, antialiasgridifit, aliased, system (默认: cleartype)
  -scale, --scale <倍数>       超采样倍数: 1-8，放大渲染后缩小，增强ClearType效果 (默认: 1)
  -h,  --help                  显示此帮助信息

透明背景:
  使用 #AARRGGBB 格式设置透明度，AA=00 完全透明，AA=FF 完全不透明
  示例: -bg ""#00FFFFFF"" (透明背景) 或 -fg ""#80000000"" (半透明黑色文字)

超采样说明:
  -scale 参数用于增强小图片的 ClearType 效果
  原理: 先按 scale 倍数放大渲染，再缩小到目标尺寸，保留亚像素细节
  推荐值: 小图片(<200px)使用 2-4，大图片使用 1（默认）
  注意: scale 越大，渲染时间越长，但 ClearType 效果越明显

示例:
  ImageGenerator -t ""Hello World"" -f ""Arial"" -s 32 -o output.png
  ImageGenerator -t ""测试文本"" -f ""微软雅黑"" -s 48 -st bold -fg ""#FF0000"" -bg ""#FFFFFF"" -w 1000 -h 300
  ImageGenerator -t ""Spacing Test"" -ls 5 -dpi 144 -r cleartype
  ImageGenerator -t ""小图标"" -s 16 -w 100 -h 40 -scale 3 -o small_icon.png
  ImageGenerator -t ""透明Logo"" -bg ""#00FFFFFF"" -scale 2 -o logo.png
");
        }
    }
}