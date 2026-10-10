import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';

import 'hands_free_state.dart';

/// 設定タブに出す「ながら学習モード」の欄。
class HandsFreeSection extends StatelessWidget {
  const HandsFreeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HandsFreeSettings>(
      valueListenable: appHandsFree,
      builder: (context, settings, _) => Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('ながら学習モード'),
            subtitle: const Text('選択式の問題を、大きなボタンと読み上げで解きます。'),
            value: settings.enabled,
            onChanged: (v) => updateHandsFree(settings.copyWith(enabled: v)),
          ),
          if (settings.enabled)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('問題と解説を読み上げる'),
              value: settings.speakQuestion,
              onChanged: (v) =>
                  updateHandsFree(settings.copyWith(speakQuestion: v, speakExplanation: v)),
            ),
        ],
      ),
    );
  }
}
