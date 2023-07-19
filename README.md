# MxsPack

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/MxsPack)](https://github.com/imaoki/MxsPack/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/MxsPack)](https://github.com/imaoki/MxsPack/blob/main/LICENSE)

複数のスクリプトファイルを1ファイルに統合するためのメソッドを提供する。

## ライセンス

[MIT License](https://github.com/imaoki/MxsPack/blob/main/LICENSE)

## 要件

* [imaoki/Standard](https://github.com/imaoki/Standard)

* （任意）[imaoki/StartupLoader](https://github.com/imaoki/StartupLoader)
  導入済みの場合はインストール/アンインストールでスタートアップスクリプトの登録/解除が行われる。
  未使用の場合はスクリプトの評価のみ行われる。

## 開発環境

`3ds Max 2024`

## インストール

01. 依存スクリプトは予めインストールしておく。

02. `install.ms`を実行する。

## アンインストール

`uninstall.ms`を実行する。

## 単一ファイル版

### インストール

01. 依存スクリプトは予めインストールしておく。

02. `Distribution\MxsPack.min.ms`を実行する。

### アンインストール

```maxscript
::MxsPackStruct.Uninstall()
```

## 制限

* 改行コードを含んだ文字列リテラルには非対応。
