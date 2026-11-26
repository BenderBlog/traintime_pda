// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';

/// The store ability for cookie. Use record type rather than abstract interface.
typedef IdsSessionStore = ({
  Future<String?> Function(String key) read,
  Future<void> Function(String key, String value) write,
  Future<void> Function(String key) delete,
});

/// The type for two-factor authentication
enum IdsCodeType { sms, enterpriseWechat }

/// Delivery metadata and the server's last code verification result.
final class IdsCodeDelivery {
  const IdsCodeDelivery(
    this.message,
    this.maskedRecipient,
    this.retryAfter, {
    this.codeRejected = false,
    this.sent = true,
    this.codeType = IdsCodeType.sms,
    this.sendCode,
  });

  final String? message;
  final String? maskedRecipient;
  final Duration retryAfter;
  final bool codeRejected;
  final bool sent;
  final IdsCodeType codeType;
  final Future<IdsCodeDelivery> Function(IdsCodeType type)? sendCode;
}

typedef IdsSliderPoint = ({int x, int y, int milliseconds});

/// Slider solver returns the user's recorded movement, or null on cancellation.
typedef IdsSliderSolver = Future<List<IdsSliderPoint>?> Function(
  Uint8List background,
  Uint8List piece,
  bool retry,
);

/// IdsCodeEntry is used for popup a dialog.
///
/// [IdsCodeDelivery] is used for UI rendering.
/// [IdsCodeSubmission] is the result from user input.
typedef IdsCodeSubmission = ({String code, bool trustDevice});
typedef IdsCodeEntry = Future<IdsCodeSubmission?> Function(
  IdsCodeDelivery delivery,
);

/// The entity of single interaction from server and client.
final class IdsInteraction {
  const IdsInteraction({this.solveSlider, this.enterCode});

  final IdsSliderSolver? solveSlider;
  final IdsCodeEntry? enterCode;
}

/// The whole repository of IDS.
abstract interface class IdsNetworkRepository {
  /// Used for get the session from server
  ///
  /// The cookie will be stored by network package. The upper layer can not access this.
  Future<void> login(
    String username,
    String password, {
    IdsInteraction interaction = const IdsInteraction(),
  });

  /// Used for authorize the subservice by using the current cookie.
  ///
  /// Throws [IdsSessionExpired] when a new login is required.
  /// Throws [FormatException] when the service is not a campus HTTPS URL.
  Future<void> authorize(
    Uri service, {
    IdsInteraction interaction = const IdsInteraction(),
  });

  /// Used for clear the session stored in the network.
  Future<void> clear();
}

class IdsLoginException implements Exception {
  const IdsLoginException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class IdsCredentialsRejected extends IdsLoginException {
  const IdsCredentialsRejected(super.message);
}

final class IdsSessionExpired extends IdsLoginException {
  const IdsSessionExpired(super.message);
}

final class IdsInteractionCancelled extends IdsLoginException {
  const IdsInteractionCancelled(super.message);
}

final class IdsInteractionRequired extends IdsLoginException {
  const IdsInteractionRequired(super.message);
}

final class IdsServiceUnavailable extends IdsLoginException {
  const IdsServiceUnavailable(super.message);
}
