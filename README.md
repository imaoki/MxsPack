# MxsPack

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/MxsPack)](https://github.com/imaoki/MxsPack/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/MxsPack)](https://github.com/imaoki/MxsPack/blob/main/LICENSE)

複数のスクリプトファイルを1ファイルに統合するためのメソッドを提供する。
<!-- Provides a method to merge multiple script files into one file. -->

## ライセンス
<!-- ## License -->

[MIT License](https://github.com/imaoki/MxsPack/blob/main/LICENSE)

## 要件
<!-- ## Requirements -->

* [imaoki/Standard](https://github.com/imaoki/Standard)

## 開発環境
<!-- ## Development Environment -->

`3ds Max 2024`

## インストール
<!-- ## Install -->

01. 依存スクリプトは予めインストールしておく。
    <!-- 01. Dependent scripts should be installed beforehand. -->

02. `install.ms`を実行する。
    <!-- 02. Execute `install.ms`. -->

## アンインストール
<!-- ## Uninstall -->

`uninstall.ms`を実行する。
<!-- Execute `uninstall.ms`. -->

## 単一ファイル版
<!-- ## Single File Version -->

### インストール
<!-- ### Install -->

01. 依存スクリプトは予めインストールしておく。
    <!-- 01. Dependent scripts should be installed beforehand. -->

02. `Distribution\MxsPack.min.ms`を実行する。
    <!-- 02. Execute `Distribution\MxsPack.min.ms`. -->

### アンインストール
<!-- ### Uninstall -->

```maxscript
::MxsPackStruct.Uninstall()
```

## 制限
<!-- ## Limitations -->

* 改行コードを含んだ文字列リテラルには非対応。
  <!-- * String Literals containing newline codes are not supported. -->
