// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'controller/ruisi_controller.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

class RuisiApp extends StatefulWidget {
  const RuisiApp({super.key});

  @override
  State<RuisiApp> createState() => _RuisiAppState();
}

class _RuisiAppState extends State<RuisiApp>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Watch((context) {
      return RuisiController.i.isLoggedIn
          ? const HomePage()
          : const LoginPage();
    });
  }
}
