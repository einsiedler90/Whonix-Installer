unit WhonixSetup_Main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Arrow, ExtCtrls, Types, StrUtils, FileUtil, IniFiles, WhonixUtils;

type

  { TSetupForm }

  TSetupForm = class(TForm)
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
    procedure Installation;
    procedure NextStatus(Status: string; Output: TStrings = nil);
  end;

var
  SetupForm: TSetupForm;

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

{ TSetupForm }

procedure TSetupForm.CheckBoxOutputChange(Sender: TObject);
begin
  if CheckBoxOutput.Checked then
  begin
    //SetupForm.Height := 500;
    MemoOutput.Show;
  end
  else
  begin
    MemoOutput.Hide;
    //SetupForm.Height := CheckBoxOutput.Top + CheckBoxOutput.Height + 10;
  end;
end;

procedure TSetupForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
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

  if MessageDlg('Exit Setup', 'Are you sure you want to cancel the Whonix installation?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    CanClose := True;
  end
  else
  begin
    CanClose := False;
  end;
end;

procedure TSetupForm.ButtonNextClick(Sender: TObject);
begin
  ButtonBack.Enabled := False;
  ButtonNext.Enabled := False;
  ButtonCancel.Enabled := False;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex + 1;
  PageControlChange(PageControl);
end;

procedure TSetupForm.CheckBoxLicenseChange(Sender: TObject);
begin
  ButtonNext.Enabled := CheckBoxLicense.Checked;
end;

procedure TSetupForm.ButtonBackClick(Sender: TObject);
begin
  ButtonBack.Enabled := False;
  ButtonNext.Enabled := False;
  ButtonCancel.Enabled := False;
  PageControl.ActivePageIndex := PageControl.ActivePageIndex - 1;
  PageControlChange(PageControl);
end;

procedure TSetupForm.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TSetupForm.FormCreate(Sender: TObject);
var
  ResourceStream: TResourceStream;
begin
  PageControl.ShowTabs := False;
  PageControl.ActivePageIndex := 0;

  SetupForm.Icon.LoadFromResourceName(Hinstance, 'MAINICON');
  ImageBanner.Picture.LoadFromResourceName(Hinstance, 'BANNER');

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

procedure TSetupForm.FormDestroy(Sender: TObject);
begin
  DeleteDirectory(UnpackPath, False);
end;

procedure TSetupForm.LabelCompleteDescClick(Sender: TObject);
begin

end;

procedure TSetupForm.PageControlChange(Sender: TObject);
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

procedure TSetupForm.TabSheetConfigurationContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: boolean);
begin

end;

procedure TSetupForm.Installation;
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
  ProgressBar.Position := 1;
  SetupForm.NextStatus('Step 1 / 9 : check if VirtualBox is already installed');
  EnsureValidExePath(CurrentVBoxManagePath, defaultVBoxManagePath);

  if CurrentVBoxManagePath = '' then
  begin
    {$IFDEF WINDOWS}
    ProgressBar.Position := 2;
    SetupForm.NextStatus('Step 2 / 9 : unpack virtualbox installer');
    ResourceStream := TResourceStream.Create(HInstance, 'VBOX', RT_RCDATA);
    StreamSaveToFile(ResourceStream, UnpackPath + 'vbox.exe');
    ResourceStream.Free;

    ProgressBar.Position := 3;
    SetupForm.NextStatus('Step 3 / 9 : install virtualbox');
    Execute('cmd.exe /c ""' + UnpackPath + 'vbox.exe"" --silent --ignore-reboot',
      SetupForm.MemoOutput.Lines);
    {$ENDIF}

    EnsureValidExePath(CurrentVBoxManagePath, defaultVBoxManagePath);

    if CurrentVBoxManagePath = '' then
    begin
      SetupForm.NextStatus('Error : virtualbox could not be installed');
      ButtonCancel.Enabled := True;
      Exit;
    end;
  end;

  ProgressBar.Position := 4;
  SetupForm.NextStatus('Step 4 / 9 : detect already existing whonix vms');
  Output := TStringList.Create;
  Execute(CurrentVBoxManagePath + ' list vms', Output);
  SetupForm.MemoOutput.Lines.AddStrings(Output);

  // TODO: install/repair if only one of both VMs is missing?
  if not ContainsStr(Output.Text, 'Whonix-Gateway-XFCE') and not
    ContainsStr(Output.Text, 'Whonix-Workstation-XFCE') then
  begin
    ProgressBar.Position := 5;
    SetupForm.NextStatus('Step 5 / 9 : unpack whonix ova');
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

    ProgressBar.Position := 6;
    SetupForm.NextStatus('Step 6 / 9 : install whonix gateway and workstation');
    Execute(CurrentVBoxManagePath + ' import "' + UnpackPath +
      'whonix.ova' + '" --vsys 0 --eula accept --vsys 1 --eula accept',
      SetupForm.MemoOutput.Lines);
  end;

  Output.Free;

  if RadioButtonConfigMinimal.Checked then
  begin
    ButtonNextClick(ButtonNext);
    Exit;
  end;

  ProgressBar.Position := 7;
  SetupForm.NextStatus('Step 7 / 9 : check if whonix starter is already installed');
  EnsureValidExePath(CurrentWhonixStarterPath, defaultWhonixStarterPath);

  if CurrentWhonixStarterPath = '' then
  begin
    {$IFDEF WINDOWS}
    ProgressBar.Position := 8;
    SetupForm.NextStatus('Step 8 / 9 : unpack whonix starter installer');
    ResourceStream := TResourceStream.Create(HInstance, 'STARTER', RT_RCDATA);
    StreamSaveToFile(ResourceStream, UnpackPath + 'WhonixStarter.msi');
    ResourceStream.Free;

    ProgressBar.Position := 9;
    SetupForm.NextStatus('Step 9 / 9 : install whonix starter');
    Execute('msiexec /i "' + UnpackPath + 'WhonixStarter.msi"',
        SetupForm.MemoOutput.Lines);
    {$ENDIF}

    EnsureValidExePath(CurrentWhonixStarterPath, defaultWhonixStarterPath);

    if CurrentWhonixStarterPath = '' then
    begin
      SetupForm.NextStatus('Error : whonix starter could not be installed');
      ButtonCancel.Enabled := True;
      Exit;
    end;
  end;

  ButtonNextClick(ButtonNext);
end;

procedure TSetupForm.NextStatus(Status: string; Output: TStrings = nil);
var
  i: integer;
begin
  if not SetupForm.Showing then
  begin
    SetupForm.Show;
  end;

  PanelStatus.Caption := Status;
  MemoOutput.Append(Status);

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
