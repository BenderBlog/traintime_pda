# ruisi_flutter

西电睿思客户端。

## 功能实现情况

 - [x] 新帖子和新回复帖子
 - [x] 发帖
 - [x] 看板面
 - [x] 发图片
 - [ ] 个人消息中心
 - [x] 签到

## 状态管理

get_it 配套的 ValueNotifier 处理登录状态、版面信息。

## 本程序开发流程

[Ruisi_iOS](https://github.com/freedom10086/Ruisi_Ios) 作为模板，使用 [MiMo-V2.5-Pro
](https://platform.xiaomimimo.com/docs/zh-CN/welcome)大模型，依靠 Codex 工具进行开发、调试。

首先搭建一个 Flutter 模板，然后扔进去 Ruisi_iOS 的代码库，让 AI 重写。重写后运行，根据功能测试结果让 AI 继续改代码。AI 代码中，业务代码必须审核，**要求尽量和 Ruisi 的桌面版获取数据相符**，UI 代码在最后理顺状态管理。

感谢 [Xiaomi MiMo Orbit 百万亿 Token 创造者激励计划](https://100t.xiaomimimo.com/)赞助 Token 让我得以完成该计划。