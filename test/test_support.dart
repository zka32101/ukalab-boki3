import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ui.dart';

/// ブックマーク・タグ・メモのサービス（端末内保存。読み込み前は空）を差し込む override。
/// 演習画面（`PracticePage`）がブックマークボタンとメモ欄を出すので、画面を組むテストに入れる。
List<Override> studyNotesTestOverrides() => [
      bookmarkServiceProvider.overrideWithValue(
          BookmarkService(store: SharedPreferencesBookmarkStore('test'))),
      bookmarkTagServiceProvider.overrideWithValue(
          BookmarkTagService(store: SharedPreferencesBookmarkTagStore('test'))),
      questionMemoServiceProvider.overrideWithValue(
          QuestionMemoService(store: SharedPreferencesQuestionMemoStore('test'))),
    ];
