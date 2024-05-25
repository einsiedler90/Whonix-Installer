unit WhonixInstaller_Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Arrow, ExtCtrls, Types, StrUtils, FileUtil, IniFiles, WhonixUtils;

type

  { TInstallerForm }

  TInstallerForm = class(TForm)
    ButtonBack: TButton;
    ButtonNext: TButton;
    ButtonCancel: TButton;
    CheckBoxLicense: TCheckBox;
    CheckBoxOutput: TCheckBox;
    ImageBanner: TImage;
    LabelConfiguration: TLabel;
    LabelConfigFullDesc: TLabel;
    LabelConfigMinimalDesc: TLabel;
    LabelInstallation: TLabel;
    LabelComplete: TLabel;
    LabelLicenseDesc: TLabel;
    LabelLicense: TLabel;
    LabelConfigurationDesc: TLabel;
    LabelInstallationDesc: TLabel;
    LabelCompleteDesc: TLabel;
    MemoLicense: TMemo;
    MemoOutput: TMemo;
    PageControl: TPageControl;
    PanelControl: TPanel;
    PanelStatus: TPanel;
    ProgressBar: TProgressBar;
    RadioButtonConfigFull: TRadioButton;
    RadioButtonConfigMinimal: TRadioButton;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    TabSheetConfiguration: TTabSheet;
    TabSheetLicense: TTabSheet;
    TabSheetInstallation: TTabSheet;
    TabSheetComplete: TTabSheet;
    procedure ButtonBackClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonNextClick(Sender: TObject);
    procedure CheckBoxLicenseChange(Sender: TObject);
    procedure CheckBoxOutputChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LabelCompleteDescClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure TabSheetConfigurationContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: boolean);
  private
    UnpackPath: string;
  public
    procedure InstallationBuildIn;
    procedure InstallationScript(Script: TStrings);
    procedure Installation;
    procedure SetNextStatus(Step: integer; Status: string; Output: TStrings = nil);
  end;

var
  InstallerForm: TInstallerForm;

implementation

{$R *.lfm}

(*

procedure EnsureValidExePath(var TargetPath: string; DefaultPath: string);
var
  filename: string;
  sl: TStringList;
begin
  if FileExists(TargetPath) then
  begin
    Exit;
  end;

  if (TargetPath <> DefaultPath) and FileExists(DefaultPath) then
  begin
    TargetPath := DefaultPath;
    Exit;
  end;

  filename := ExtractFileName(DefaultPath);
  TargetPath := FindDefaultExecutablePath(filename);
  if FileExists(TargetPath) then
  begin
    Exit;
  end;

  sl := TStringList.Create;
  {$IFDEF WINDOWS}
  Execute('where /r C:\ ' + filename, sl);
  {$ELSE}
  Execute('which ' + filename, sl);
  {$ENDIF}

  if (sl.Count > 0) and FileExists(sl.Strings[0]) then
  begin
    TargetPath := sl.Strings[0];
  end
  else
  begin
    TargetPath := '';
  end;

  sl.Free;
end;

*)

{ TInstallerForm }

procedure TInstallerForm.CheckBoxOutputChange(Sender: TObject);
begin
  if CheckBoxOutput.Checked then
  begin
    //InstallerForm.Height := 500;
    MemoOutput.Show;
  end
  else
  begin
    MemoOutput.Hide;
    //InstallerForm.Height := CheckBoxOutput.Top + CheckBoxOutput.Height + 10;
  end;
end;

procedure TInstallerForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if PageControl.ActivePage = TabSheetComplete then
  begin
    CanClose := True;
    Exit;
  end;

  if not ButtonCancel.Enabled then
  begin
    CanClose := False;
    Exit;
  end;

  if MessageDlg('Exit Installer',
    'Are you sure you want to cancel the Whonix installation?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
end;

procedure TInstallerForm.ButtonNextClick(Sender: TObject);
begin
  ButtonBack.Enabled := False;
  ButtonNext.Enabled := False;
  ButtonCancel.Enabled := False;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex + 1;
  PageControlChange(PageControl);
end;

procedure TInstallerForm.CheckBoxLicenseChange(Sender: TObject);
begin
  ButtonNext.Enabled := CheckBoxLicense.Checked;
end;

procedure TInstallerForm.ButtonBackClick(Sender: TObject);
begin
  ButtonBack.Enabled := False;
  ButtonNext.Enabled := False;
  ButtonCancel.Enabled := False;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex - 1;
  PageControlChange(PageControl);
end;

procedure TInstallerForm.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TInstallerForm.FormCreate(Sender: TObject);
var
  ResourceStream: TResourceStream;
begin
  PageControl.ShowTabs := False;
  PageControl.ActivePageIndex := 0;

  InstallerForm.Icon.LoadFromResourceName(Hinstance, 'MAINICON');

  {$IFDEF WINDOWS}
  ImageBanner.Picture.LoadFromResourceName(Hinstance, 'BANNERWINDOWS');
  {$ELSE}
  ImageBanner.Picture.LoadFromResourceName(Hinstance, 'BANNERLINUX');
  {$ENDIF}

  ResourceStream := TResourceStream.Create(HInstance, 'LICENSE', RT_RCDATA);
  MemoLicense.Lines.LoadFromStream(ResourceStream);
  ResourceStream.Free;

  MemoOutput.Hide;

  UnpackPath := GetAppConfigDir(False);
  if not ForceDirectories(UnpackPath) then
  begin
    ShowMessage('Error : directory for unpacking could not be created');
    Halt;
  end;

  while AppDiskGetFreeSpace(UnpackPath) < 4 * 1024 * 1024 * 1024 do
  begin
    if MessageDlg('no free disk space for temp data! ( 4GB needed )',
      'do you wish to select directory?', mtConfirmation, [mbYes, mbClose], 0) =
      mrYes then
    begin
      if SelectDirectoryDialog.Execute then
      begin
        UnpackPath := IncludeTrailingPathDelimiter(
          IncludeTrailingPathDelimiter(SelectDirectoryDialog.FileName) +
          ApplicationName);
        if not ForceDirectories(UnpackPath) then
        begin
          ShowMessage('Error : directory for unpacking could not be created');
          Halt;
        end;
      end;
    end
    else
    begin
      Halt;
    end;
  end;
end;

procedure TInstallerForm.FormDestroy(Sender: TObject);
begin
  DeleteDirectory(UnpackPath, False);
end;

procedure TInstallerForm.LabelCompleteDescClick(Sender: TObject);
begin

end;

procedure TInstallerForm.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage = TabSheetLicense then
  begin
    ButtonNext.Caption := 'Next >';
    ButtonNext.Enabled := CheckBoxLicense.Checked;
    ButtonCancel.Enabled := True;
  end
  else if PageControl.ActivePage = TabSheetConfiguration then
  begin
    ButtonBack.Enabled := True;
    ButtonNext.Caption := 'Execute';
    ButtonNext.Enabled := True;
    ButtonCancel.Enabled := True;
  end
  else if PageControl.ActivePage = TabSheetInstallation then
  begin
    ButtonNext.Caption := 'Execute';
    Installation;
  end
  else if PageControl.ActivePage = TabSheetComplete then
  begin
    ButtonBack.Visible := False;
    ButtonNext.Visible := False;
    ButtonCancel.Caption := 'Finish';
    ButtonCancel.Enabled := True;
  end;
end;

procedure TInstallerForm.TabSheetConfigurationContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: boolean);
begin

end;

procedure TInstallerForm.InstallationBuildIn;
const
  {$IFDEF WINDOWS}
  defaultVBoxManagePath = 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe';
  defaultWhonixStarterPath = 'C:\Program Files\Whonix\Whonix.exe';
  {$ELSE}
  defaultVBoxManagePath = '/usr/bin/VBoxManage';
  defaultWhonixStarterPath = '/usr/bin/Whonix';
  {$ENDIF}
var
  CurrentVBoxManagePath, CurrentWhonixStarterPath: string;
  Output: TStringList;
  ResourceStream: TResourceStream;
  ExeFileStream: TFileStream;
begin
  SetNextStatus(1, 'Checking if VirtualBox is already installed...');
  if not EnsureExePath(CurrentVBoxManagePath, defaultVBoxManagePath) then
  begin
    {$IFDEF WINDOWS}
    SetNextStatus(2, 'Unpacking VirtualBox installer...');
    ResourceStream := TResourceStream.Create(HInstance, 'VBOX', RT_RCDATA);
    StreamSaveToFile(ResourceStream, UnpackPath + 'vbox.exe');
    ResourceStream.Free;

    SetNextStatus(3, 'Installing VirtualBox..');
    Execute('cmd.exe /c ""' + UnpackPath + 'vbox.exe"" --silent --ignore-reboot',
      InstallerForm.MemoOutput.Lines);
    {$ENDIF}

    if not EnsureExePath(CurrentVBoxManagePath, defaultVBoxManagePath) then
    begin
      SetNextStatus(-1, 'VirtualBox could not be installed.');
      ButtonCancel.Enabled := True;
      Exit;
    end;
  end;

  SetNextStatus(4, 'Detecting already existing Whonix VMs.');
  Output := TStringList.Create;
  Execute(CurrentVBoxManagePath + ' list vms', Output);
  InstallerForm.MemoOutput.Lines.AddStrings(Output);

  // TODO: install/repair if only one of both VMs is missing?
  if not ContainsStr(Output.Text, 'Whonix-Gateway-Xfce') and not
    ContainsStr(Output.Text, 'Whonix-Workstation-Xfce') then
  begin
    SetNextStatus(5, 'Unpacking Whonix ova...');
    ExeFileStream := TFileStream.Create(Application.ExeName, fmOpenRead);
    ResourceStream := TResourceStream.Create(HInstance, 'OVAINFO', RT_RCDATA);
    with TIniFile.Create(ResourceStream) do
    begin
      ExeFileStream.Position := ExeFileStream.Size - ReadInt64('general', 'size', 0);
      Free;
    end;
    StreamSaveToFile(ExeFileStream, UnpackPath + 'whonix.ova');
    ResourceStream.Free;
    ExeFileStream.Free;

    SetNextStatus(6, 'Installing Whonix-Gateway and Whonix-Workstation.');
    Execute(CurrentVBoxManagePath + ' import "' + UnpackPath +
      'whonix.ova' + '" --vsys 0 --eula accept --vsys 1 --eula accept',
      InstallerForm.MemoOutput.Lines);
  end;

  Output.Free;

  if RadioButtonConfigMinimal.Checked then
  begin
    ButtonNextClick(ButtonNext);
    Exit;
  end;

  SetNextStatus(7, 'Checking if Whonix-Starter is already installed...');
  if not EnsureExePath(CurrentWhonixStarterPath, defaultWhonixStarterPath) then
  begin
    {$IFDEF WINDOWS}
    SetNextStatus(8, 'Unpacking Whonix-Starter installer...');
    ResourceStream := TResourceStream.Create(HInstance, 'STARTER', RT_RCDATA);
    StreamSaveToFile(ResourceStream, UnpackPath + 'WhonixStarter.msi');
    ResourceStream.Free;

    SetNextStatus(9, 'Installing Whonix-Starter...');
    Execute('msiexec /i "' + UnpackPath + 'WhonixStarter.msi"',
        InstallerForm.MemoOutput.Lines);
    {$ENDIF}

    if not EnsureExePath(CurrentWhonixStarterPath, defaultWhonixStarterPath) then
    begin
      SetNextStatus(-1, 'Whonix-Starter could not be installed.');
      ButtonCancel.Enabled := True;
      Exit;
    end;
  end;

  ButtonNextClick(ButtonNext);
end;

procedure TInstallerForm.InstallationScript(Script: TStrings);
begin
  SetNextStatus(1, 'Saving install script to unpack path...');
  Script.SaveToFile(UnpackPath + 'whonix-xfce-installer-cli');

  {$IFNDEF WINDOWS}
  Execute('chmod +x ' + UnpackPath + 'whonix-xfce-installer-cli',InstallerForm.MemoOutput.Lines);

  SetNextStatus(2, 'Execute install script...');

  Execute(UnpackPath + 'whonix-xfce-installer-cli -d -n',InstallerForm.MemoOutput.Lines);
  {$ENDIF}

  SetNextStatus(-1, 'Test error.');
  ButtonCancel.Enabled := True;
  //ButtonNextClick(ButtonNext);
end;

procedure TInstallerForm.Installation;
{$IFNDEF WINDOWS}
var ResourceStream: TResourceStream;
    Script: TStringList;
{$ENDIF}
begin
  {$IFNDEF WINDOWS}
  ResourceStream := TResourceStream.Create(HInstance, 'SCRIPT', RT_RCDATA);
  Script := TStringList.Create;
  Script.LoadFromStream(ResourceStream);

  if (Script.Count > 0) and (Script.Strings[0] = '#!/bin/bash') then
  begin
    InstallationScript(Script);
  end else begin
    InstallationBuildIn;
  end;

  Script.Free;
  ResourceStream.Free;
  {$ELSE}
  InstallationBuildIn;
  {$ENDIF}
end;

procedure TInstallerForm.SetNextStatus(Step: integer; Status: string;
  Output: TStrings = nil);
const
  MAX_STEPS = 9;
var
  i: integer;
begin
  // depricated??? ---------------------->
  if not InstallerForm.Showing then
  begin
    InstallerForm.Show;
  end;
  // ------------------------------------<

  if (Step >= 0) and (Step <= MAX_STEPS) then
  begin
    ProgressBar.Position := Step;
    PanelStatus.Caption := 'Step ' + IntToStr(Step) + ' / ' +
      IntToStr(MAX_STEPS) + ' : ' + Status;
  end
  else
  begin
    PanelStatus.Caption := 'Error : ' + Status;
  end;

  MemoOutput.Append(PanelStatus.Caption);

  if Output <> nil then
  begin
    for i := 0 to Output.Count - 1 do
    begin
      MemoOutput.Append(Output.Strings[i]);
    end;
  end;

  //MemoOutput.Lines.SaveToFile(GetAppConfigDir(False) + 'Whonix.log');

  // wait 2 seconds to make status reading possible
  for i := 1 to 20 do
  begin
    Sleep(100);
    Application.ProcessMessages;
  end;
end;

end.
