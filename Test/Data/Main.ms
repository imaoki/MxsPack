/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
fileIn @"definitionPool.ms"
/*-
メイン。
*/
struct MainStruct (
  /*-
  インストールする。
  @returns <OkClass>
  @remarks 静的メソッド。
  */
  public fn Install = (
    ::startupLoader.RegisterFile (getSourceFileName()) installer:true
    ok
  ),

  on Create do ()
)
