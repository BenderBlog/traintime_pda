// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Python script by arttnba3

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class EasterEggPage extends StatefulWidget {
  const EasterEggPage({super.key});

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  final String urlApple = "https://www.bilibili.com/video/BV1as411f7ks/";

  final String urlOthers = "https://www.bilibili.com/video/BV13T41177zn/";

  String eastereggProduct = '''
Easter egg page under constrction...

"Within the Autumn of Conscious" -> 不思議なお祓い棒, Gensokyo Band, Double Dealing Character, 2013
"Across the Universe" -> Across the Universe, The Beatles, Let It Be, 1970

Book of PDA

==== Main Charater ====

Once upon a time, there's a 'Hard Lovin' Man called Ray, whose understand the power of the Railgun called 'Flight of the Rat. 

Once after a battle with a 'Bloodsucker, he was tired as a high school student. He discovered a Purple Rat in the Square Forest.

Unknown her name, "She like a sweet potato, like my Rat gun. Just call her Sweet Purple Potato Ball, idk...", he thought. And he brought her to his home(maybe?)

The rat is clever, actually she is a angel named Elliot. We don't know why her soul inside a rat. Forgive me, I am drunked.

She knows he is the 'Child of the Time. They may argue, may laugh. In my opinion, she lighten Ray's seemly colorless life.

Don't know how time flies, she made he faster in running, attacking. With the power of the 'Rat gun', he become the threating 'Speed King.

==== Another Main Charater ====

Another time, in the midland of Orestreich, a lonely bard named Reggirt, found a Knight (Contributer To Be Decided) shooting at the Sun.

"Just another 'Firefall, it soon become mime.", the Knight said.

"What's your purpose, sir? You may get your head kicked by a 'Mule", Reggrit asked.

Knight smiled, "It's not the Sun, 'no no no, it's the 'Demon's Eye. The source of mystery, of pain, of all struggle..."

"Wait! It's the source of all living thing, we're all hers 'Daughter..."

"... and that's our parents, 'Fools!" Knight signed, "What a complex feeling, 'No one came to realize this felling like me..."

==== The Evil ====

So the time files, the world became colorless, the 'Night Prowler born from the shadow of the sun.

With the uncertain of the humanity and the grease of the relationship, it became more powerful. 

Soon, it took away the joy, trust, and all stuff we could remains years of years. He named himself Bender, who realized his goal is to bent everything entertains us.

Night Prowler itself evolued into a sliver chrome machinery, with laser eyes which absorb the happiness and sweetie from air and earth.

Itself found that a band, 'Sgt. Pepper Lonely Hearted Band, is the source of the bright things of the world.

He deside to let them 'bite his shiny metal ass, and seal them with 'The Devil's Triangle...

''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "setting.easter_egg_page.title",
          ),
        ),
      ),
      body: [
        [
          IconButton.filled(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlApple : urlOthers,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
          IconButton.filledTonal(
            onPressed: () => launchUrl(
              Uri.parse(
                Platform.isIOS || Platform.isMacOS ? urlOthers : urlApple,
              ),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.headphones),
          ),
        ]
            .toRow(mainAxisAlignment: MainAxisAlignment.center)
            .padding(bottom: 16.0),
        Text(eastereggProduct),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.center)
          .scrollable()
          .center()
          .padding(horizontal: 16)
          .safeArea(),
    );
  }
}
