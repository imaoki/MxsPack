/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  /* 初期化 */
  local mp = ::MxsPackStruct (getSourceFileName())
  /* 出力先ディレクトリ削除 */
  -- mp.DeleteDirectory @".\Distribution"

  /* コード切り出し */
  local MxsPackCode = mp.ClipFile @".\MxsPack.ms" 1 -1

  /* コード置換 */
  local code = MxsPackCode

  /* インストールコード追加 */
  code = mp.AppendText code "::MxsPackStruct.Install()\n::MxsPackStruct\n"
  /* インストーラーオプション削除 */
  code = mp.RemoveInstallerOption code
  /* バンドルファイルを保存 */
  -- mp.WriteAllText @".\Distribution\MxsPack.bundle.ms" code
  /* 最小化ファイルを保存 */
  code = mp.Minify code
  mp.WriteAllText @".\Distribution\MxsPack.min.ms" code
  ok
)
