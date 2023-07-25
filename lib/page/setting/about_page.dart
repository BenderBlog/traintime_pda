import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static const license = '''
  <h1 style="text-align: center">Traintime PDA 软件最终用户许可协议</h1>
  <p style="text-align: center"><i>BenderBlog Rodriguez, 2023-07-24</i></p>

  <h2>一、定义</h2>
    <ol>
      <li>本软件产物：指 Traintime PDA ，他也可以被称为 Watermeter 或 XDYou。</li>
      <li>代码：指生成本软件的来源，地址列于附件二。</li>
      <li>编译：指从代码生成本软件的步骤。</li>
      <li>授权者：指本软件的作者(或作者团体)。</li>
      <li>用户：指最终使用该软件编译成果的自然人。</li>
      <li>开发者：指利用本程序代码的自然人，或法人，或法律实体。</li>
      <li>使用者：指用户和开发者。</li>
    </ol>
      

  <h2>二、条款</h2>
    <ol>
      <li>授权者将本软件代码按照 Mozilla Public License Version 2.0 协议之规定，授权给使用者。条款附于附件一。</li>
      <li>本许可协议仅针对授权者编译产生的产物有效。如使用者使用代码自行编译，不受该协议约束。授权者有权使用技术手段，标示授权者编译产生的产物。</li>
      <li>本软件仅供学习交流使用，使用者需要对使用本软件一切行为承担一切责任。</li>
      <li>本软件所访问的服务器和网络服务，除附件三声明外，均和授权者无关，授权者不会对这些服务本身进行支持。如果遇到问题，请面向服务提供商请求支持。</li>
      <li>授权者无权了解使用者的个人信息，除非在授权者和使用者均知情情况下，授权者明确请求后，获得使用者的明确同意。</li>
      <li>如使用本软件，即表示使用者知晓授权者反对 996 等不合理竞争和劳动。授权者还反感任何官僚化的东西，包括无意义的会议，课程等。</li>
    </ol>

  <h2>附件一： Mozilla Public License Version 2.0</h2>
      请参阅：<a href="http://mozilla.org/MPL/2.0/">http://mozilla.org/MPL/2.0/</a>

  <h2>附件二： 本软件代码</h2>
      请参阅：<a href="https://github.com/BenderBlog/watermeter/">https://github.com/BenderBlog/watermeter/</a>

  <h2>附件三： 条款三实施细则</h2>
      本软件所涉及的服务中，除 XDU Planet 是授权者以服务器-客户端单向信息传递方式提供外，其他服务均与授权者无关。
''';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("关于本软件")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: ListView(
            children: [
              Image.asset(
                "assets/Credit.jpg",
                fit: BoxFit.fitWidth,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
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
                          Uri.parse(
                              "https://github.com/xdlinux/xidian-scripts"),
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
                                    Uri.parse(
                                        "https://www.coolapk.com/feed/45104934"),
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: HtmlWidget(
                  license,
                  onTapUrl: (url) => launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
