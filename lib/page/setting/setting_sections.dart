// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:restart_app/restart_app.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/setting_actions_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/dialogs/change_color_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_localization_dialog.dart';
import 'package:watermeter/page/setting/dialogs/change_swift_dialog.dart';
import 'package:watermeter/page/setting/dialogs/experiment_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/semester_switch_dialog.dart';
import 'package:watermeter/page/setting/dialogs/sport_password_dialog.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/page/setting/notification_page/notification_debug_page.dart';
import 'package:watermeter/page/setting/notification_page/notification_page.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pick_file.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/routing/routes.dart';
import 'package:watermeter/themes/color_seed.dart';

part 'sections/shared.dart';
part 'sections/header_section.dart';
part 'sections/about_section.dart';
part 'sections/ui_section.dart';
part 'sections/account_section.dart';
part 'sections/notification_section.dart';
part 'sections/classtable_section.dart';
part 'sections/core_section.dart';
part 'sections/cancel_button.dart';
