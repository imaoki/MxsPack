/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  -- clearListener()

  local nowTime = (DotNetClass "System.DateTime").Now.ToString "HH:mm:ss"
  local sw = DotNetObject "System.Diagnostics.Stopwatch"

  local currentFile = getSourceFileName()
  local pathUtility = ::PathUtilityStruct currentFile

  local actual
  local expected
  local testDef
  local testObj

  format "[run %]@\"%\"\n" nowTime currentFile
  /* Setup Start ------------------------------------------------------------ */
  local destPresetDir = pathUtility.GetFullPath @".\Data\Distribution\Preset"
  local destPresetFile = pathUtility.GetFullPath @".\Data\Distribution\Preset\A.ms"
  local distributionDir = pathUtility.GetFullPath @".\Data\Distribution"
  local minFile = pathUtility.GetFullPath @".\Data\Distribution\Main.min.ms"

  testDef = fileIn (pathUtility.GetFullPath @"..\MxsPack.ms")
  /* Setup End -------------------------------------------------------------- */
  sw.Start()
  /* Test Start ------------------------------------------------------------- */
  /* 既定値でインスタンス作成 */
  testObj = testDef()

  /* AppendText */
  -- 無効な値（文字列以外の入力）
  actual = ::TestValueStruct (testObj.AppendText #Foo "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列以外の入力）
  actual = ::TestValueStruct (testObj.AppendText "foobar" 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.AppendText "foobar" "-")
  expected = ::TestValueStruct "foobar-"
  assert (actual.Equals expected == true)

  /* ClipFile */
  -- 基準となるディレクトリが未指定なので失敗
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Sub.ms" 75 38)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)

  /* ClipText */
  -- 無効な値（文字列以外の入力）
  actual = ::TestValueStruct (testObj.ClipText #Foo 1 1)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（開始位置が`0`）
  actual = ::TestValueStruct (testObj.ClipText "foobar" 0 3)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列の長さが`0`）
  actual = ::TestValueStruct (testObj.ClipText "foobar" 1 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列の長さが超過）
  actual = ::TestValueStruct (testObj.ClipText "foobar" 1 7)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.ClipText "foobar" 2 3)
  expected = ::TestValueStruct "oob"
  assert (actual.Equals expected == true)
  -- 成功（文字列の長さに負の値を指定）
  actual = ::TestValueStruct (testObj.ClipText "foobar" 2 -1)
  expected = ::TestValueStruct "oobar"
  assert (actual.Equals expected == true)

  /* CopyDirectory */
  -- 基準となるディレクトリが未指定なので失敗
  actual = ::TestValueStruct (testObj.CopyDirectory @".\Data\Preset" @".\Data\Distribution")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- コピー先ディレクトリを確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists destPresetDir)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* DeleteDirectory */
  -- テスト用ディレクトリ作成
  ::std.FileUtility.CreateDirectory distributionDir
  -- 確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 基準となるディレクトリが未指定なので失敗
  actual = ::TestValueStruct (testObj.DeleteDirectory @".\Data\Distribution")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- テスト用ディレクトリ削除
  ::std.FileUtility.DeleteDirectory distributionDir recursive:true
  -- 確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* InsertText */
  -- 無効な値（文字列以外の入力）
  actual = ::TestValueStruct (testObj.InsertText #Foo 1 "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（開始位置が`0`）
  actual = ::TestValueStruct (testObj.InsertText "foobar" 0 "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功（先頭）
  actual = ::TestValueStruct (testObj.InsertText "foobar" 1 "-")
  expected = ::TestValueStruct "-foobar"
  assert (actual.Equals expected == true)
  -- 成功（中間）
  actual = ::TestValueStruct (testObj.InsertText "foobar" 4 "-")
  expected = ::TestValueStruct "foo-bar"
  assert (actual.Equals expected == true)
  -- 成功（末尾）
  actual = ::TestValueStruct (testObj.InsertText "foobar" 7 "-")
  expected = ::TestValueStruct "foobar-"
  assert (actual.Equals expected == true)

  /* Install */

  /* Minify */
  -- 継続行
  actual = ::TestValueStruct (testObj.Minify "foo \\\n      and bar\n")
  expected = ::TestValueStruct "foo and bar;"
  assert (actual.Equals expected == true)
  -- ブロックコメント
  actual = ::TestValueStruct (testObj.Minify "/*\nfoo\n*/\nlocal foo\n")
  expected = ::TestValueStruct "local foo;"
  assert (actual.Equals expected == true)
  -- 行コメント
  actual = ::TestValueStruct (testObj.Minify "-- コメント\nlocal foo\n")
  expected = ::TestValueStruct "local foo;"
  assert (actual.Equals expected == true)
  -- 空白行
  actual = ::TestValueStruct (testObj.Minify "local foo\n\nlocal bar\n")
  expected = ::TestValueStruct "local foo;local bar;"
  assert (actual.Equals expected == true)
  -- インデント
  actual = ::TestValueStruct (testObj.Minify "  if foo do (\n    bar\n  )\n")
  expected = ::TestValueStruct "if foo do (bar;);"
  assert (actual.Equals expected == true)

  /* RemoveInstallerOption */
  actual = ::TestValueStruct (testObj.RemoveInstallerOption "  ::startupLoader.RegisterFile (getSourceFileName()) installer:true\n")
  expected = ::TestValueStruct "  ::startupLoader.RegisterFile (getSourceFileName())\n"
  assert (actual.Equals expected == true)

  /* ReplaceText */
  -- 無効な値（文字列以外の入力）
  actual = ::TestValueStruct (testObj.ReplaceText #Foo 1 1 "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（開始位置が`0`）
  actual = ::TestValueStruct (testObj.ReplaceText "foobar" 0 3 "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列の長さが`0`）
  actual = ::TestValueStruct (testObj.ReplaceText "foobar" 1 0 "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列の長さが超過）
  actual = ::TestValueStruct (testObj.ReplaceText "foobar" 1 7 "-")
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.ReplaceText "foobar" 2 3 "-")
  expected = ::TestValueStruct "f-ar"
  assert (actual.Equals expected == true)
  -- 成功（文字列の長さに負の値を指定）
  actual = ::TestValueStruct (testObj.ReplaceText "foobar" 2 -1 "-")
  expected = ::TestValueStruct "f-"
  assert (actual.Equals expected == true)

  /* Uninstall */

  /* WriteAllText */
  -- 基準となるディレクトリが未指定なので失敗
  actual = ::TestValueStruct (testObj.WriteAllText @".\Data\Distribution\Main.min.ms" "0")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ファイル確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists minFile)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  -- ディレクトリ確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* 作成パラメータ */
  testObj = testDef currentFile

  /* ClipFile */
  -- 無効な値（存在しないファイル）
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Foo.ms" 1 10)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（開始位置が`0`）
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Sub.ms" 0 3)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列の長さが`0`）
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Sub.ms" 1 0)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 無効な値（文字列の長さが超過）
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Sub.ms" 1 200)
  expected = ::TestValueStruct undefined
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Sub.ms" 75 38)
  expected = ::TestValueStruct "struct SubStruct (\n  on Create do ()\n)"
  assert (actual.Equals expected == true)
  -- 成功（文字列の長さに負の値を指定）
  actual = ::TestValueStruct (testObj.ClipFile @".\Data\Model\Sub.ms" 75 -1)
  expected = ::TestValueStruct "struct SubStruct (\n  on Create do ()\n)\n"
  assert (actual.Equals expected == true)

  /* CopyDirectory */
  -- 成功
  actual = ::TestValueStruct (testObj.CopyDirectory @".\Data\Preset" @".\Data\Distribution\Preset")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- コピー先ディレクトリを確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists destPresetDir)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイルを確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists destPresetFile)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)

  /* DeleteDirectory */
  -- 確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- 成功
  actual = ::TestValueStruct (testObj.DeleteDirectory @".\Data\Distribution")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- 確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  /* WriteAllText */
  -- 成功
  actual = ::TestValueStruct (testObj.WriteAllText @".\Data\Distribution\Main.min.ms" "0")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ディレクトリ確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイル確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists minFile)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイル内容確認
  actual = ::TestValueStruct (::std.FileUtility.ReadAllText minFile)
  expected = ::TestValueStruct "0"
  assert (actual.Equals expected == true)
  -- ディレクトリ削除
  actual = ::TestValueStruct (testObj.DeleteDirectory @".\Data\Distribution")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ディレクトリ確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)

  -- testObj.Dump()

  /* ビルドサンプル */
  local subCode = testObj.ClipFile @".\Data\Model\Sub.ms" 75 38
  local poolCode = testObj.ClipFile @".\Data\definitionPool.ms" 1 -1
  poolCode = testObj.ReplaceText poolCode 162 22 subCode
  poolCode = testObj.ClipText poolCode 64 -1
  local mainCode = testObj.ClipFile @".\Data\Main.ms" 1 -1
  mainCode = testObj.ReplaceText mainCode 64 27 poolCode
  mainCode = testObj.AppendText mainCode "::MainStruct.Install()\n::MainStruct\n"
  mainCode = testObj.RemoveInstallerOption mainCode
  testObj.WriteAllText @".\Data\Distribution\Main.bundle.ms" mainCode
  mainCode = testObj.Minify mainCode
  testObj.WriteAllText @".\Data\Distribution\Main.min.ms" mainCode
  -- ディレクトリ確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイル確認
  actual = ::TestValueStruct (::std.FileUtility.FileExists minFile)
  expected = ::TestValueStruct true
  assert (actual.Equals expected == true)
  -- ファイル内容確認
  actual = ::TestValueStruct (::std.FileUtility.ReadAllText minFile)
  expected = ::TestValueStruct "/*! © 2022 imaoki | MIT License | https://github.com/imaoki */;global testDefinitionPool = Dictionary #String;::testDefinitionPool[@\"Model\\Sub.ms\"] = struct SubStruct (on Create do (););struct MainStruct (public fn Install = (::startupLoader.RegisterFile (getSourceFileName());ok;),on Create do (););::MainStruct.Install();::MainStruct;"
  assert (actual.Equals expected == true)
  -- ディレクトリ削除
  actual = ::TestValueStruct (testObj.DeleteDirectory @".\Data\Distribution")
  expected = ::TestValueStruct ok
  assert (actual.Equals expected == true)
  -- ディレクトリ確認
  actual = ::TestValueStruct (::std.FileUtility.DirectoryExists distributionDir)
  expected = ::TestValueStruct false
  assert (actual.Equals expected == true)
  /* Test End --------------------------------------------------------------- */
  sw.Stop()
  /* Teardown Start --------------------------------------------------------- */
  /* Teardown End ----------------------------------------------------------- */
  format "[end %]%ms\n" nowTime (sw.ElapsedMilliseconds as Integer)
  ok
)
