import 'package:flutter/widgets.dart';

extension SafeScrollPadding on EdgeInsets {
  EdgeInsets withSafeBottom(BuildContext context, {bool enabled = true}) {
    if (!enabled) return this;

    return copyWith(bottom: bottom + MediaQuery.paddingOf(context).bottom);
  }
}
