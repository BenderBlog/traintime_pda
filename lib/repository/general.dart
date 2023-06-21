/*
Cookie Jar Database.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:cookie_jar/cookie_jar.dart';
import 'package:alice_lightweight/alice.dart';

Alice alice = Alice();

/// Will be initialized at the beginning of the program.
late PersistCookieJar SportCookieJar;
late PersistCookieJar IDSCookieJar;
