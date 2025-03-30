## TODOアプリ作成

### パッケージ追加
https://anveloper.com/2020/10/28/flutter-intl/

### モーダル <showModalBottomSheet>
https://isub.co.jp/flutter/memo-show-modal-bottom-sheet/

### 実機デバッグ
https://zenn.dev/nanase/articles/e326ae90e3380a
- デバイス名(ID)には「Pixel 6a • 23181JEGR****」のような、英数字文字列を入れる

### ADBインストール
https://jp.minitool.com/news/adb-install-windows-10-mac.html
- 環境変数に追加

### 実機にインストール
https://dev.classmethod.jp/articles/android-flutter-apk/
- ```flutter build apk```
- ```adb -s <deviceID> install ./build/app/outputs/flutter-apk/app-release.apk```

## Hiveによるデータ永続化

### Hiveパッケージ追加
https://zenn.dev/adjaper/articles/7bc1934c938518
```sh
$ flutter pub add hive
$ flutter pub add hive_flutter
$ flutter pub add hive_generator --dev
$ flutter pub add build_runner --dev
```

### TODOモデルをmodule化
https://zenn.dev/adjaper/articles/7bc1934c938518
- lib/modules フォルダを作成
- lib/modules/todo.dart を作成
- todo.dart に、```part 'todo.g.dart';``` を追記
- ```flutter packages pub run build_runner build``` を実行
→ lib/modules/todo.g.dart が生成される
- 成功