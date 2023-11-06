program WhonixInstaller;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF LCLQT5}
    {$linklib Qt5PrintSupport}
    {$linklib Qt5Widgets}
    {$linklib Qt5X11Extras}
    {$linklib Qt5Gui}
    {$linklib Qt5Core}
    {$linklib stdc++}
    {$linklib gcc_s}
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, WhonixInstaller_Main
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TInstallerForm, InstallerForm);
  Application.Run;
end.
