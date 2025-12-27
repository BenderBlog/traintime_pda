# 🤝 贡献指南 (Contributing Guide)

欢迎来到 **Traintime PDA（XDYou）** 项目的贡献者社区！🎉  
本项目是为 **西安电子科技大学（XDU）学生**开发的一款开源信息查询软件，使用 **Flutter** 构建，支持 **Android、iOS**，并有社区贡献的 **Windows/Linux** 版本。

我们非常欢迎每一位开发者、设计师、翻译者或普通用户参与到项目的改进中来，无论贡献大小！本指南将帮助你快速上手，安全、高效地提交你的代码或建议。

---

## 🧭 你可以贡献什么？

| 类型 | 说明 | 适合谁 |
|------|------|--------|
| 🐞 修复 Bug | 发现并修复 UI / 功能上的问题 | 所有人 |
| ✨ 新功能建议 / 实现 | 提出或实现新功能（如优化界面、新增小工具） | 开发者 |
| 🌍 翻译 / 国际化 | 帮助完善 繁体中文 / 英文 / 其他语言翻译 | 语言爱好者 |
| 📝 文档优化 | 改进 README、注释、使用说明 | 所有人 |
| 🎨 UI / UX 优化 | 调整布局、颜色、字体、空状态提示等 | 设计 / 前端爱好者 |
| 🛠️ 代码重构 / 优化 | 优化代码结构、注释、异常处理等 | 开发者 |
| 📦 打包 / 发布支持 | 帮助适配更多平台，如 Windows、Linux、MacOS | 进阶开发者 |
| 💡 提 issue / 反馈 | 提出问题、功能需求、使用建议 | 所有人 |

> 即使你只是修正了一个错别字、调整了一个按钮边距，也是非常有用的贡献！

---

## 🚀 快速开始：如何贡献代码？

### 1. Fork 项目

访问 [https://github.com/BenderBlog/traintime_pda](https://github.com/BenderBlog/traintime_pda)，点击右上角 **Fork** 按钮，将项目复制到你的 GitHub 账号下。

### 2. 克隆你的 Fork

git clone https://github.com/你的用户名/traintime_pda.git
cd traintime_pda

### 3. 创建开发分支

git checkout -b feat/your-feature-name  # 或 fix/bug-fix-name、docs/readme-improve 等

> 分支命名推荐：
> - `feat/xxx`：新功能
> - `fix/xxx`：Bug 修复
> - `docs/xxx`：文档更新
> - `ui/xxx`：UI 优化
> - `i18n/xxx`：国际化相关

### 4. 设置上游仓库（便于同步）

git remote add upstream https://github.com/BenderBlog/traintime_pda.git

之后可用 `git fetch upstream` 同步原项目最新代码。

---

## 🧪 测试与运行项目

项目使用 **Flutter** 开发，支持 Android 与 iOS。

### 环境要求

- Flutter 3.35.3+（推荐使用稳定版）
- Dart 3.9.2+
- 支持 Android SDK / Xcode（如需真机调试）

### 运行项目、

flutter pub get
flutter run

> 注意：部分功能（如校园网、一卡通、成绩等）可能需要登录或特定环境才能完整测试，但你仍可以参与 UI、文档、翻译等无需后端的贡献。

---

## 📌 贡献注意事项

### ✅ 代码风格

- 请尽量遵循项目现有的代码风格（Flutter 常用规范）。
- 代码要有适当注释，特别是你新增的函数或页面。
- 提交前确保代码能通过编译，并尽量测试过主要功能。

### ✅ 提交信息规范

推荐使用清晰简洁的提交信息，例如：
fix: 修正成绩页面的错别字
feat: 添加空课表时的提示信息
docs: 更新 README 中的编译说明
ui: 优化考试安排页面的排版
> 常用前缀：`feat:`、`fix:`、`docs:`、`chore:`、`ui:`、`i18n:`、`test:` 等。

### ✅ 提交 Pull Request（PR）

1. 推送你的分支到你的 Fork：

git add .
git commit -m "fix: 修正首页按钮文字错误"
git push origin 你的分支名
2. 前往你的 Fork 页面，点击 **Compare & pull request**。

3. 在 PR 中简要说明：
   - 你做了什么改动（简单说明就行）
   - 为什么要做这个改动
   - 如有截图、日志更佳

> 我们会尽快 Review 并反馈，感谢你的贡献！


## 📚 文档相关

- **README.md**：项目介绍、安装、功能总览，欢迎优化格式、补充内容。
- **代码注释**：改进复杂逻辑时建议添加清晰注释，方便他人理解。

## 👥 致谢

感谢所有已经为项目贡献力量的开发者、翻译者、测试者和用户！特别感谢原作者及团队提供的强大基础，以及社区众多贡献者的协作精神。

你可以在 `docs/contributors.md` 中查看当前的开发者名单，也欢迎你把自己的名字加入未来的贡献者列表！ 🌟

---

## 🔒 开源协议

本项目源代码以 **MPL 2.0** 为主开源协议，部分文件可能为 **MIT / Apache-2.0**，详见对应文件头部声明。

请在修改和分发时遵循相应的开源协议要求。

---

## 📬 联系方式

本软件反馈群：

反馈1群：902652582（本群可吹水）
反馈2群：912366449（本群不可吹水）
开发者联系方式：

邮箱：superbart_chen@qq.com
B站账号: SuperBart

---

## ❓常见问题

可在`main/docs/faq.md`中查看关于一系列功能的情况和遇到一些问题的解答QAQ