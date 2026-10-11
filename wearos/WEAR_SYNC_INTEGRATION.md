# WearOS companion sync integration

XDYou Wear is a companion-only native Wear OS app (Jetpack Compose for Wear OS).
Pairing and subsequent synchronization use the Wear OS Data Layer; camera/QR
pairing is intentionally not used.

The phone app lives at the repository root. The Wear OS target lives in
`wearos/android/` as a standalone Gradle project (no Flutter embedding).

## Direct pairing

1. Open the watch app while unpaired. The watch accepts a first pairing while
   the pairing page is in the foreground.
2. Open `设置 > XDYou Wear` on the Android phone.
3. The phone obtains connected watches from `NodeClient.connectedNodes`.
4. Select a watch and tap `配对`.
5. The phone sends the cached schedule/payment envelope through
   `MessageClient` to `/traintime_pda_wear_os/sync/v1`.
6. After a successful import, the watch remembers the source phone node and
   acknowledges the matching session on
   `/traintime_pda_wear_os/sync/ack/v1`.
7. The phone records the watch as paired only after receiving that
   acknowledgement. A Data Layer enqueue alone is not treated as success.

Wear OS Data Layer only transports messages between applications with the same
package name and signing identity. Requiring the unpaired watch app to be open
prevents an unexpected first import from a background installation.

The watch registers its `MessageClient` listener only while the activity is in
the foreground (no resident / background polling service).

## Later synchronization

The watch sends `/traintime_pda_wear_os/request/v1` to its remembered phone.
The phone's `WearCompanionListenerService` responds with the last snapshot even
when the Flutter activity is not running. A normal phone homepage refresh
updates that native snapshot.

For a payment QR, a normal page open immediately displays the last local copy
without networking. Pulling down asks the connected paired phone through the
system Wear OS Data Layer. Phone discovery and response together have a
10-second limit. The phone payment proxy requires XDYou to be in the foreground;
its background listener reports `phone_app_required` when unavailable. A failed
response or timeout retains the local copy and asks the user to retry on the
phone. Authentication runs only on the phone.

Manual sync waits and unfinished payment requests are cancelled when the watch
activity leaves the foreground. Data Layer sends and listeners operate only
while the watch activity is resumed. Cancelled sessions cannot resume later.
A displayed payment QR keeps the
screen on only while resumed, for at most 60 seconds (15 seconds when Android's
`PowerManager` reports power-save mode). Other pages follow the system screen
timeout. No periodic jobs, foreground services or manual wake locks are added.

If the phone is disconnected, the watch continues to use its local class-table
and experiment caches. A successfully fetched payment QR is also cached on the
watch; an offline copy is marked below the QR with its fetch time because it
may have expired. Fetch times appear briefly in a bubble below the code.

## Agenda tile

After installing the watch app, add **XDYou 课表** from the watch's tile picker.
The tile shares the app's class-table and experiment caches. It shows the
current event, or the next event from today and tomorrow, with its name, time
and location. Tapping the tile opens the full agenda, including when the app
was previously displaying a payment code.

Course start/end transitions are supplied as Wear OS timeline validity periods;
the system switches the displayed entry without a polling loop. The system
may request a new local timeline after its 24-hour freshness interval. All tile
requests read local files on an IO coroutine and never create HTTP or Data Layer
clients. Importing a new phone snapshot or logging out requests a tile update.
If there is no usable cache, the tile asks the user to open the app and sync.
If the system has not refreshed an expired timeline, its fallback asks the user
to open the agenda rather than displaying a finished event as current.

Only the resumed watch app can receive a new phone snapshot. Local time-based
transitions continue while the app is closed, but school-side schedule changes
still require foreground synchronization. The tile uses the same device time
zone, semester filtering and agenda builder as the app.

## Envelope

The JSON envelope uses schema version `1` and contains:

- `sessionId`: `direct-pairing` for first pairing or `background-sync` later.
- `directPairing`: `true` only for the first direct-pairing message.
- `profileId`: random phone-generated cache scope; it carries no login credentials.
- `schedule.classTable`: the phone's cached `ClassTableData.toJson()` value.
- `schedule.otherExperiments`: optional cached experiment list.
- `paymentQr`: optional phone-fetched PNG and fetch time.
- `generatedAtEpochMs`: phone snapshot creation time.

The watch decodes the complete envelope before replacing local caches. A
failed or missing synchronization therefore does not remove usable offline
data.

## Build

```bash
cd wearos/android
./gradlew assembleDebug
```
