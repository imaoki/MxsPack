/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  local hasMetRequirements
  fn hasMetRequirements = (
    isStruct ::std \
        and isProperty ::std #StructName \
        and classOf ::std.StructName == MAXScriptFunction \
        and ::std.StructName() == #StandardStruct
  )
  if not hasMetRequirements() do (
    local fileClass = DotNetClass "System.IO.File"
    local pathClass = DotNetClass "System.IO.Path"
    local currentDir = pathClass.GetDirectoryName (getSourceFileName())
    local standardFile = currentDir + @"\Standard.min.ms"
    if fileClass.Exists standardFile do fileIn standardFile
  )
  if not hasMetRequirements() do (
    format "[error]Requirement not met.\n"
  )
)
/*-
複数のスクリプトファイルを1ファイルに統合するためのメソッドを提供する。
@remarks スクリプトファイルは以下の条件を満たしていることが前提となる。

| 項目       | 状態               |
| ---------- | ------------------ |
| エンコード | `utf-8`（BOM無し） |
| 改行コード | `LF`               |
*/
struct MxsPackStruct (
  /*- @prop <String> 作成パラメータ1。相対パスの基準となるディレクトリのパス。必須。既定値は`undefined`。 */
  public _CP1_,

  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `^ *?\n`に一致する正規表現オブジェクト。 */
  private blankLineRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `^ ＊/\*(?!!)(.|\n)*?\＊/\n?`に一致する正規表現オブジェクト。`＊`は`*`に読み替える。 */
  private blockCommentRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `(?<=\(|,)\n`に一致する正規表現オブジェクト。 */
  private commaBreakRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> ` *\\ *\n *`に一致する正規表現オブジェクト。 */
  private continuationLineRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `^ +`に一致する正規表現オブジェクト。 */
  private indentationRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `(?<=\.RegisterFile \(getSourceFileName\(\)\)) installer:true`に一致する正規表現オブジェクト。 */
  private installerRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `\n`に一致する正規表現オブジェクト。 */
  private lfRegex,
  /*- @prop <DotNetObject:System.Text.RegularExpressions.Regex> `^ *--.*?\n`に一致する正規表現オブジェクト。 */
  private lineCommentRegex,
  /*- @prop <Struct:PathUtilityStruct> */
  private pathUtility,

  /*
  public fn AppendText source input = (),
  public fn ClipFile path fromPos stringLength = (),
  public fn ClipText source fromPos stringLength = (),
  public fn CopyDirectory source destination = (),
  public fn DeleteDirectory path = (),
  public fn InsertText source insertPos input = (),
  public fn Install = (),
  public fn Minify input = (),
  public fn RemoveInstallerOption input = (),
  public fn ReplaceText source fromPos stringLength input = (),
  public fn Uninstall = (),
  public fn WriteAllText path contents = (),

  private fn isValidPathUtility obj = (),
  */

  /*-
  末尾に文字列を追加する。
  @param source <String> 元の文字列。
  @param input <String> 追加する文字列。
  @returns <String|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn AppendText source input = (
    local result = undefined
    if classOf source == String and classOf input == String do (
      result = source + input
    )
    result
  ),

  /*-
  ファイルから指定された範囲の部分文字列を切り出す。
  @param path <String> ファイルパス。相対パスも可。
  @param fromPos <Integer> 開始位置。
  @param stringLength <Integer> 文字列の長さ。負の値を指定した場合は文字列の末尾までが範囲になる。
  @returns <String|UndefinedClass>
  @remarks 基準となるディレクトリが未指定の場合、ファイルが存在しない場合、または範囲指定が正しくない場合は`undefined`を返す。
  */
  public fn ClipFile path fromPos stringLength = (
    local result = undefined
    if this.isValidPathUtility this.pathUtility \
        and classOf fromPos == Integer and classOf stringLength == Integer \
        and fromPos > 0 and stringLength != 0 do (
      local fullPath = this.pathUtility.GetFullPath path
      local code = ::std.FileUtility.ReadAllText fullPath
      if classOf code == String do (
        if stringLength < 0 do (
          stringLength = code.Count - fromPos + 1
        )
        if code.Count >= fromPos + stringLength - 1 do (
          result = substring code fromPos stringLength
        )
      )
    )
    result
  ),

  /*-
  文字列から指定された範囲の部分文字列を切り出す。
  @param source <String> 元の文字列。
  @param fromPos <Integer> 開始位置。
  @param stringLength <Integer> 文字列の長さ。負の値を指定した場合は文字列の末尾までが範囲になる。
  @returns <String|UndefinedClass>
  @remarks 範囲指定が正しくない場合は`undefined`を返す。
  */
  public fn ClipText source fromPos stringLength = (
    local result = undefined
    if classOf source == String \
        and classOf fromPos == Integer and classOf stringLength == Integer \
        and fromPos > 0 and stringLength != 0 do (
      if stringLength < 0 do (
        stringLength = source.Count - fromPos + 1
      )
      if source.Count >= fromPos + stringLength - 1 do (
        result = substring source fromPos stringLength
      )
    )
    result
  ),

  /*-
  `::std.FileUtility.CopyDirectory`メソッドをラップする。
  @param source <String> コピーするディレクトリのパス。相対パスも可。
  @param destination <String> コピー先のパス。相対パスも可。
  @returns <OkClass>
  @remarks 常に上書きする。
  基準となるディレクトリが未指定の場合は何もしない。
  */
  public fn CopyDirectory source destination = (
    if this.isValidPathUtility this.pathUtility do (
      local srcFullPath = this.pathUtility.GetFullPath source
      local destFullPath = this.pathUtility.GetFullPath destination
      ::std.FileUtility.CopyDirectory srcFullPath destFullPath overwrite:true
      format "[copy]@\"%\"\n" destFullPath
    )
    ok
  ),

  /*-
  `::std.FileUtility.DeleteDirectory`メソッドをラップする。
  @param path <String> 相対パスも可。
  @returns <OkClass>
  @remarks 常に再帰的に削除する。
  基準となるディレクトリが未指定の場合は何もしない。
  */
  public fn DeleteDirectory path = (
    if this.isValidPathUtility this.pathUtility do (
      local fullPath = this.pathUtility.GetFullPath path
      ::std.FileUtility.DeleteDirectory fullPath recursive:true
      format "[delete]@\"%\"\n" fullPath
    )
    ok
  ),

  /*-
  指定した位置に文字列を挿入する。
  @param source <String> 元の文字列。
  @param insertPos <Integer> 挿入位置。
  @param input <String> 挿入文字列。
  @returns <String|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn InsertText source insertPos input = (
    local result = undefined
    if classOf source == String \
        and classOf insertPos == Integer and insertPos > 0 \
        and classOf input == String do (
      if insertPos > source.Count then (
        result = this.AppendText source input
      )
      else (
        if insertPos == 1 then (
          result = input + source
        )
        else (
          result = replace source insertPos 0 input
        )
      )
    )
    result
  ),

  /*-
  インストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Install = (
    if isProperty ::startupLoader #RegisterFile do (
      ::startupLoader.RegisterFile (getSourceFileName()) installer:true
    )
    format "[install]::MxsPackStruct\n"
    ok
  ),

  /*-
  コードを最小化する。
  @param input <String>
  @returns <String|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn Minify input = (
    local result = undefined
    if classOf input == String do (
      result = copy input
      if this.continuationLineRegex.IsMatch result do (
        result = this.continuationLineRegex.Replace result " "
      )
      if this.blockCommentRegex.IsMatch result do (
        result = this.blockCommentRegex.Replace result ""
      )
      if this.lineCommentRegex.IsMatch result do (
        result = this.lineCommentRegex.Replace result ""
      )
      if this.blankLineRegex.IsMatch result do (
        result = this.blankLineRegex.Replace result ""
      )
      if this.indentationRegex.IsMatch result do (
        result = this.indentationRegex.Replace result ""
      )
      if this.commaBreakRegex.IsMatch result do (
        result = this.commaBreakRegex.Replace result ""
      )
      if this.lfRegex.IsMatch result do (
        result = this.lfRegex.Replace result ";"
      )
    )
    result
  ),

  /*-
  `Install`メソッドのインストーラオプションを除去する。
  @param input <String>
  @returns <String|UndefinedClass>
  @remarks 無効な値の場合は`undefined`を返す。
  */
  public fn RemoveInstallerOption input = (
    local result = undefined
    if classOf input == String and this.installerRegex.IsMatch input do (
      result = this.installerRegex.Replace input ""
    )
    result
  ),

  /*-
  指定された範囲の文字列を置換した新たな文字列を返す。
  @param source <String> 元の文字列。
  @param fromPos <Integer> 開始位置。
  @param stringLength <Integer> 文字列の長さ。負の値を指定した場合は文字列の末尾までが範囲になる。
  @param input <String> 置換文字列。
  @returns <String|UndefinedClass>
  @remarks 範囲指定が正しくない場合は`undefined`を返す。
  */
  public fn ReplaceText source fromPos stringLength input = (
    local result = undefined
    if classOf source == String \
        and classOf fromPos == Integer and classOf stringLength == Integer \
        and fromPos > 0 and stringLength != 0 \
        and classOf input == String do (
      if stringLength < 0 do (
        stringLength = source.Count - fromPos + 1
      )
      if source.Count >= fromPos + stringLength - 1 do (
        result = replace source fromPos stringLength input
      )
    )
    result
  ),

  /*-
  アンインストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Uninstall = (
    if isProperty ::startupLoader #UnregisterFile do (
      ::startupLoader.UnregisterFile (getSourceFileName())
    )
    format "[uninstall]::MxsPackStruct\n"
    ok
  ),

  /*-
  `::std.FileUtility.WriteAllText`メソッドをラップする。
  @param path <String> 相対パスも可。
  @param contents <String|StringStream>
  @returns <OkClass>
  @remarks 基準となるディレクトリが未指定の場合は何もしない。
  */
  public fn WriteAllText path contents = (
    if this.isValidPathUtility this.pathUtility do (
      local fullPath = this.pathUtility.GetFullPath path
      local dirPath = this.pathUtility.GetDirectoryName fullPath
      if not ::std.FileUtility.DirectoryExists dirPath do (
        ::std.FileUtility.CreateDirectory dirPath
      )
      if ::std.FileUtility.DirectoryExists dirPath do (
        ::std.FileUtility.WriteAllText fullPath contents
        format "[write]@\"%\"\n" fullPath
      )
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidPathUtility obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #PathUtilityStruct
  ),

  /*- @prop <Array[<Integer>]> バージョン番号。メジャー、マイナー、パッチの順。 */
  private version = #(1, 0, 0),

  /*- @returns <Name> */
  public fn StructName = #MxsPackStruct,

  /*-
  @param indent: <String>
  @param out: <FileStream|StringStream|WindowStream> 出力先。既定値は`listener`。
  @returns <OkClass>
  */
  public fn Dump indent:"" out:listener = (
    format "%MxsPackStruct\n" indent to:out
    if this.isValidPathUtility this.pathUtility then (
      format "%  pathUtility:\n" indent to:out
      this.pathUtility.Dump indent:(indent + "    ") out:out
    )
    else (
      format "%  pathUtility:%\n" indent this.pathUtility to:out
    )
    ok
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  @remarks 大文字と小文字を区別する。
  */
  public fn Equals obj = (
    local isEqualStructName = isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == this.StructName()

    local isEqualProperties = true

    isEqualStructName and isEqualProperties
  ),

  /*-
  @returns <Array[<Integer>]>
  */
  public fn GetVersion = (
    this.version
  ),

  on Create do (
    if classOf this._CP1_ == String do (
      if ::std.FileUtility.DirectoryExists this._CP1_ \
          or ::std.FileUtility.FileExists this._CP1_ do (
        this.pathUtility = ::std.PathUtilityStruct this._CP1_
      )
    )
    this.blankLineRegex = ::std.StringUtility.CreateRegex "^ *?\n" options:#(#IgnoreCase, #Multiline)
    this.blockCommentRegex = ::std.StringUtility.CreateRegex "^ */\*(?!!)(.|\n)*?\*/\n?" options:#(#IgnoreCase, #Multiline)
    this.commaBreakRegex = ::std.StringUtility.CreateRegex "(?<=\(|,)\n" options:#(#IgnoreCase, #Multiline)
    this.continuationLineRegex = ::std.StringUtility.CreateRegex " *\\\\ *\n *" options:#(#IgnoreCase, #Multiline)
    this.indentationRegex = ::std.StringUtility.CreateRegex "^ +" options:#(#IgnoreCase, #Multiline)
    this.installerRegex = ::std.StringUtility.CreateRegex "(?<=\.RegisterFile \(getSourceFileName\(\)\)) installer:true" options:#(#IgnoreCase, #Multiline)
    this.lfRegex = ::std.StringUtility.CreateRegex "\n" options:#(#IgnoreCase, #Multiline)
    this.lineCommentRegex = ::std.StringUtility.CreateRegex "^ *--.*?\n" options:#(#IgnoreCase, #Multiline)
  )
)
