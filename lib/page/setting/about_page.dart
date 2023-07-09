import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("关于本软件")),
      body: ListView(
        children: [
          Image.asset("assets/Credit.jpg"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text("主页"),
                onPressed: () => launchUrl(
                  Uri.parse("https://legacy.superbart.xyz/xdyou.html"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextButton(
                child: const Text("代码"),
                onPressed: () => launchUrl(
                  Uri.parse("https://github.com/BenderBlog/watermeter"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextButton(
                child: const Text("给我捐款"),
                onPressed: () => launchUrl(
                  Uri.parse("https://afdian.net/a/benderblog"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text("电表主页"),
                onPressed: () => launchUrl(
                  Uri.parse("https://myxdu.moefactory.com/"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextButton(
                child: const Text("xidian-script"),
                onPressed: () => launchUrl(
                  Uri.parse("https://github.com/xdlinux/xidian-scripts"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextButton(
                child: const Text("西电目录"),
                onPressed: () => launchUrl(
                  Uri.parse("https://ncov.hawa130.com/about"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              TextButton(
                child: const Text("Ray"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Self-Portrait"),
                      content: Image.asset("assets/Ray.jpg"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("他写的文章和小说指引"),
                          onPressed: () => launchUrl(
                            Uri.parse("https://www.coolapk.com/feed/45104934"),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const Text(
            "Traintime PDA 软件许可协议",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const Text(
            "BenderBlog Rodriguez, 2023-07-09",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const Text(
            '''
一、定义
    1. 本软件产物：指 Traintime PDA，他也可以被称为 Watermeter，XDYou。
    2. 代码：指生成本软件的来源。
    3. 编译：指从代码生成本软件的步骤。
    4. 授权者：指本软件的作者(或作者团体)。
    5. 用户：指最终使用该软件编译成果的自然人。
    6. 开发者：指利用本程序代码的自然人，或企业。
    7. 使用者：指用户和开发者。

二、条款
    1. 授权者将本软件代码按照 Mozilla Public License Version 2.0，许可给使用者。条款附于附件一。
    2. 授权者免责条款
        a. 授权者仅对由授权者自行编译产生的产物负责。任何非授权者的产物，如果由使用者使用，后果由使用者自负。
        b. 本许可协议仅针对授权者自行编译产生的产物有效。
        c. 本软件所访问的服务器和网络服务，均和授权者无关。授权者不会对这些服务本身进行支持。
    3. 授权者无权了解使用者的信息，除非在授权者和使用者知情情况下，授权者明确请求后，获得使用者的明确同意。
    4. 如使用本软件，即表示使用者知晓授权者反对 996 等不合理竞争和劳动。他/她还反感官僚化的任何东西，包括无意义的会议，课程等。

附件一：Mozilla Public License Version 2.0
    请参阅 http://mozilla.org/MPL/2.0/''',
          ),
        ],
      ),
    );
  }
}
