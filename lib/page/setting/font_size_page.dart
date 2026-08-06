// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Font size / weight setting page with a live class table preview.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/font_setting.dart';

class FontSizePage extends StatefulWidget {
  const FontSizePage({super.key});

  @override
  State<FontSizePage> createState() => _FontSizePageState();
}

class _FontSizePageState extends State<FontSizePage> {
  void _persist(double value, preference.Preference key) {
    preference.setDouble(key, value).then((_) {
      if (mounted) {
        ThemeController.i.updateTheme();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "setting.font_size_setting"),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          SignalBuilder(
            builder: (context) {
              double fontScale = ThemeController.i.fontScaleSignal.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ReXCard(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.font_size_page.size_title",
                    ),
                  ),
                  remaining: const [],
                  bottomRow: Column(
                    children: [
                      Text(
                        "${(fontScale * 100).round()}%",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Slider(
                        value: fontScale,
                        min: minFontScale,
                        max: maxFontScale,
                        divisions: 12,
                        onChanged: (value) {
                          ThemeController.i.fontScaleSignal.value = value;
                        },
                        onChangeEnd: (value) {
                          _persist(value, preference.Preference.fontScale);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SignalBuilder(
            builder: (context) {
              double fontWeight = ThemeController.i.fontWeightSignal.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ReXCard(
                  title: Text(
                    FlutterI18n.translate(
                      context,
                      "setting.font_size_page.weight_title",
                    ),
                  ),
                  remaining: const [],
                  bottomRow: Column(
                    children: [
                      Text(
                        FlutterI18n.translate(
                          context,
                          "setting.font_size_page.weight_"
                          "${fontWeightLabels[fontWeightLabelIndex(fontWeight)]}",
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Slider(
                        value: fontWeight,
                        min: minFontWeight,
                        max: maxFontWeight,
                        divisions: fontWeightSliderDivisions,
                        onChanged: (value) {
                          setState(() {
                            ThemeController.i.fontWeightSignal.value = value;
                          });
                        },
                        onChangeEnd: (value) {
                          _persist(value, preference.Preference.fontWeight);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              FlutterI18n.translate(
                context,
                "setting.font_size_page.preview_title",
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const _ClassTablePreview(),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('''下面的问题请你回答其在《潜伏》电视剧的出处：
1. 峨眉峰，还TM独照，颇具浪漫主义气质啊。走，去审讯室！
2. 这里有两根金条，你能告诉我哪根是高尚的，哪根是龌龊的？
3. 李队长，感谢你的黄金美元。我和许宝凤同志走了，临别之际，留词半阙，以为纪念：夏日消融，江河日溢。人，或为鱼～鳖。千秋功罪，谁人曾与评说？
4. 时间像一头野驴呀，跑起来就不停。也正如我的前列腺一样，老罢工啊。
5. 初夜比挖个菜窖还累啊，还行，不是一副无精打采的样子。
6. 天津这个地方，情况太复杂了。
7. 你就是不懂得录音的基本原理。睁开眼睛看看世界吧，就算你没跟录音带的女人说过话，这个录音带照样存在。这不是什么戏法，两个白俄的十八岁孩子就能做这盘录音带。
8. 先到咸阳为王上，后到咸阳……诶，你赶快问问你弟弟，一辆新的 斯 蒂 庞 克 牌轿车值多少钱？你这这个都不懂啊，就是陈纳德坐的那辆啊。
9. 刚截获的共党电文，想听吗？这也许是你最后一次听到“同志们熟悉的声音”啦：鲤鱼，峨眉峰已被捕，请指示，鹅卵石？
10. 拙劣的马奎啊，你不开口怎么行呢？通知李处长，弄刑。

下面的名言名句请说出其出处：
- 只要你有一颗少女心, 看什么都是少女漫。
- 不愿意接受指导的同学，不用来参加，你们不会受到任何处分!假如研究生还是保持本科生的态度，我们的教育确有问题! 
- 不可能，绝对不可能！车胄有八万精兵驻防徐州，八万呢！！！你就算是八万个馒头，刘备也要啃上半个月！
- 为了夫人，我才纳张绣之降，不然张氏灭族矣。今日遇见夫人，乃天幸也。不知夫人今宵愿与我同席共枕否？
- 公为坐上客，布为阶下囚，何不发一言而相宽乎？公不见丁原，董卓之事乎？
- 活关羽可怕，死关羽也可怕，死了还活更可怕！快快！快用沉香木刻其身躯，设牲醴祭祀，以王侯之礼葬于洛阳南门外，孤也要亲往送殡！关将军，孤赠你为荆王，并派官员为你守灵。
- 像你这般无情无义，飞扬浮躁，钱利熏心的蠢猪！居然也想当太子？还什么“社稷为重君为轻”？那你干脆一刀把朕这个君弑了！你马上可以登基！岂不更方便？
- 好啊，静极思动了啊。既然胤礽那么想和马呆在一起，要不然把他关在上驷院，跟马关在一起？
- 一路上，肖国兴不断地叫屈。（叫的啥屈）他说八爷说过，皇上答应过，只要他能供出太子，就能既往不咎。（该死，其心可诛！）奴才这就去杀了肖国兴。（谁让你杀肖国兴！）
- 以后任何人都不得提起江夏镇这个地方！
- 山西是个好地方啊，杏花村的酒、清徐的醋、还要漫山遍野的煤……
- 皇上不要怪他们，他们追随了我好久，只知军令不知旨意。
- 我坟头上挂了个屁帘，那也是一个旗子！坟头上挂了屁帘，到底是小了点。

请翻译这段英文：
I'm worried for you all, truly. Your people are good at one thing. Running all over the world faster than those major journalists. Nonetheless, you ask questions here and there are all too simple, sometimes naive. Understand?
          '''),
          ),
        ],
      ),
    );
  }
}

/// A static (non-interactive) preview of the real second-week class table.
class _ClassTablePreview extends StatelessWidget {
  const _ClassTablePreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: LayoutBuilder(
        builder: (context, constraint) => ClassTableState(
          constraints: constraint,
          controllers: _PreviewClassTableState(),
          child: IgnorePointer(
            child: ClassTableView(index: 1, constraint: constraint),
          ),
        ),
      ),
    );
  }
}

/// A class table state served from the real controller, without live marks.
class _PreviewClassTableState extends ClassTableWidgetState {
  _PreviewClassTableState();

  /// Show the second week directly, ignore the user's week offset.
  @override
  int get offset => 0;

  /// A fixed time in the past, hides the timeline and completion marks.
  @override
  DateTime get currentTime => DateTime(2000, 1, 1);
}
