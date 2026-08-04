# WearOS companion sync integration

XDYou Wear is a companion-only app. Pairing and subsequent synchronization use
the Wear OS Data Layer; camera/QR pairing is intentionally not used.

The phone app lives at the repository root and the standalone Wear OS Flutter
target lives in `wearos/`. Both targets use the root `.flutter` submodule.

## Direct pairing

1. Open `配对手机` on the watch. The watch accepts a first pairing for five
   minutes.
2. Open `设置 > XDYou Wear` on the Android phone.
3. The phone obtains connected watches from `NodeClient.connectedNodes`.
4. Select a watch and tap `配对`.
5. The phone sends the cached credential/schedule envelope through
   `MessageClient` to `/traintime_pda_wear_os/sync/v1`.
6. After a successful import, the watch remembers the source phone node.

Wear OS Data Layer only transports messages between applications with the same
package name and signing identity. The explicit five-minute window prevents an
unexpected first import even from another matching development installation.

## Later synchronization

The watch sends `/traintime_pda_wear_os/request/v1` to its remembered phone.
The phone's `WearCompanionListenerService` responds with the last snapshot even
when the Flutter activity is not running. A normal phone homepage refresh
updates that native snapshot.

For a payment QR, the watch first asks the foreground phone app to use the
phone's current IDS session. The user can immediately choose `改用手表认证`;
the watch then uses the synchronized account/password and its own persistent
cookie store. Automatic slider verification and an on-watch SMS MFA page are
supported.

If the phone is disconnected, the watch continues to use its local class-table
and experiment caches. A successfully fetched payment QR is also cached on the
watch; an offline copy is marked below the QR with its fetch time because it
may have expired.

## Envelope

The JSON envelope uses schema version `1` and contains:

- `sessionId`: `direct-pairing` for first pairing or `background-sync` later.
- `directPairing`: `true` only for the first direct-pairing message.
- `credentials`: IDS account/password, role and semester. On the watch these
  credentials are retained only for the payment-code exception.
- `schedule.classTable`: the phone's cached `ClassTableData.toJson()` value.
- `schedule.otherExperiments`: optional cached experiment list.
- `paymentQr`: optional phone-fetched PNG and fetch time.
- `generatedAtEpochMs`: phone snapshot creation time.

The watch decodes the complete envelope before replacing local caches. A
failed or missing synchronization therefore does not remove usable offline
data.
