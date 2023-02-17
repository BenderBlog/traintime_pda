# watermeter 水表
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FBenderBlog%2Fwatermeter.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FBenderBlog%2Fwatermeter?ref=badge_shield)


(watermeter 是核心代号，项目最终成品将会是 Traintime PDA)

先说个事，eMule 是 eDockey 2000 的开源重写版。那么说，我这个程序就是[这个](https://myxdu.moefactory.com/)的开源重写版咯。  
(感觉我这名字挺能暗示的)

本软件的目标是利用[xidian-script](https://github.com/xdlinux/xidian-scripts)所提供的信息，加上我能力范围内能扩充的一些功能，来写一个纯本地的西电学子日常信息查看应用。

还在开发中，也没有终点。

# 我想要实现什么

1. 西电目录，毕竟是我头一回参与的有用项目，也是我入手 Flutter 的第一站。目前差上报功能。
2. 体育查询，这应该是公网上能用的最简单的项目了，我拿这玩意入门了 Flutter 的动态加载和 Dio 网络库。
3. 一站式相关，我用这个东西来入门了 Wireshark，Cookie 和缓存，可能还预习了计网？
4. 一站式包括成绩查询，课表，个人信息，考试时间查询。(Pre-Alpha 0.0.1 只有成绩查询)
5. 还有电费查询，校园网查询等 xidian-script 里面有的功能。
6. 兴许我还能把物理计算器给抄过来(有点异想天开了)

# 目前进展

1. 课程表基本可以使用
2. 体育查询打卡次数和体测成绩
3. 查询成绩，手动计算均分
4. 西电目录，查询学校内的各种服务

# 授权协议

本软件大部分代码的授权是[Mozilla Public License Version 2.0](http://mozilla.org/MPL/2.0/)，具体条款，请看各个文件上面的标识。

本软件修改了由 Aydın Emre Esen 编写的 [sn_progress_dialog](https://github.com/emreesen27/Flutter-Progress-Dialog)，授权是 MIT 协议。代码在 `lib/modified_lib/sprt_sn_progress_dialog` 下面。

请注意以下附加条款：

1. 如使用本软件，即表示您知晓 (acknowledge) 软件作者反对 996 等不合理竞争和劳动。他/她还反感官僚化的任何东西，包括无意义的会议，课程等。
2. 本附带条款不具有强制性，无论是法律上的，还是其他方面。你无需为了使用该软件而赞同附加条款的内容。只要你遵守上述非附加条款，你在使用时可以删除附带条款。

# 名字由来

请搜索这两段文字

> See the old train go down the track
> Hear the wheels go clicketty-clack
> It's comin' home, comin' home
> Leavin' town, baby, ain't comin' home no more.
> Get the train, you know that's why I'm leavin'
> Ain't no use to greavin', well, I guess I'm leavin'
> Well, I'm leavin' town' well, I'm leavin' town
> Leave town, baby, ain't comin' home no more.
> Traintime, baby, traintime's almost here
> Traintime, baby, traintime's almost here
> So give me one more time so now, do-dah-yeah.
> Traintime, baby.

> The PDA (personal digital assistant) is one of the most useful items. It acts as a media player, email reader and access key for restricted areas.
>
> Besides the player's personal PDA, other PDAs can be picked up and scanned to read helpful hints (including backstory, hints to monster types ahead, and combination codes for lockers).


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FBenderBlog%2Fwatermeter.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FBenderBlog%2Fwatermeter?ref=badge_large)