import 'package:flutter/material.dart';
import 'package:watermeter/page/widget.dart';

class BothSideSheet extends StatefulWidget {
  final Widget child;
  final String title;

  const BothSideSheet({
    super.key,
    required this.child,
    required this.title,
  });

  static void show({
    required BuildContext context,
    required Widget child,
    required String title,
  }) =>
      showGeneralDialog(
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return BothSideSheet(
            title: title,
            child: child,
          );
        },
        barrierDismissible: true,
        barrierLabel: title,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: isPhone(context)
                  ? const Offset(0.0, 1.0)
                  : const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
            child: child,
          );
        },
      );

  @override
  State<BothSideSheet> createState() => _BothSideSheetState();
}

class _BothSideSheetState extends State<BothSideSheet> {
  /// We only change the height, to simulate showModalBottomSheet
  late double heightForVertical;

  @override
  void didChangeDependencies() {
    heightForVertical = MediaQuery.of(context).size.height * 0.8;
    super.didChangeDependencies();
  }

  BorderRadius radius(context) => BorderRadius.only(
        topLeft: const Radius.circular(16),
        bottomLeft: !isPhone(context) ? const Radius.circular(16) : Radius.zero,
        topRight: isPhone(context) ? const Radius.circular(16) : Radius.zero,
        bottomRight: Radius.zero,
      );

  double get width => isPhone(context)
      ? MediaQuery.of(context).size.width
      : MediaQuery.of(context).size.width * 0.4 < 360
          ? 360
          : MediaQuery.of(context).size.width * 0.4;

  Widget get onTop => isPhone(context)
      ? GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              heightForVertical = MediaQuery.of(context).size.height -
                  details.globalPosition.dy;
              if (heightForVertical <
                  MediaQuery.of(context).size.height * 0.4) {
                Navigator.pop(context);
              }
            });
          },
          child: SizedBox(
            height: 30,
            width: double.infinity,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                ),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                  ),
                )
              ],
            ),
          ),
        )
      : Text(widget.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isPhone(context) ? Alignment.bottomCenter : Alignment.centerRight,
      child: Material(
        elevation: 15,
        color: Colors.transparent,
        borderRadius: radius(context),
        child: Container(
          width: width,
          height: isPhone(context) ? heightForVertical : double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: radius(context),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPhone(context) ? 15 : 10,
              vertical: isPhone(context) ? 0 : 10,
            ),
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: !isPhone(context),
                toolbarHeight: isPhone(context) ? 20 : kToolbarHeight,
                title: onTop,
              ),
              body: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
