import 'package:flutter/foundation.dart';

/// 解答記録が追加されるたびに増える「版数」。
///
/// 下部タブは `IndexedStack`（`app_common_kit` の `UkalabShell`）で管理されており、
/// 一度ビルドされたタブはオフスクリーンになっても破棄・再ビルドされない。
/// そのため [ProgressStore] に新しい記録を追加しても、既にマウント済みの
/// `RecordsPage`・`ProgressSummaryCard` は起動時に読み込んだ古いデータを
/// 表示し続けてしまう。記録を追加した側がこの値をインクリメントし、
/// 表示側はこれをリッスンして明示的に読み直すことで最新の状態に追従する。
final ValueNotifier<int> progressRevision = ValueNotifier<int>(0);
