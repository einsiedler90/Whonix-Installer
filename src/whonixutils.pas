(*
 * Whonix Starter ( whonixutils.pas )
 *
 * Copyright: 2012 - 2023 ENCRYPTED SUPPORT LP <adrelanos@riseup.net>
 * Author: einsiedler90@protonmail.com
 * License: See the file COPYING for copying conditions.
 *)

unit WhonixUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Process, Math;

function AppDiskGetFreeSpace(const fn: string): Int64;
procedure EnsureValidExePath(var TargetPath: string; DefaultPath: string);
procedure Execute(CommandLine: string; Output: TStrings = nil);
procedure StreamSaveToFile(Stream: TStream; FileName: String);
procedure CopyUnblocked(FromStream, ToStream: TStream);

implementation

function AppDiskGetFreeSpace(const fn: string): Int64;
begin
  {$ifdef linux}
  //this crashes on FreeBSD 12 x64
  exit(SysUtils.DiskFree(SysUtils.AddDisk(ExtractFileDir(fn))));
  {$endif}

  {$ifdef windows}
  exit(SysUtils.DiskFree(SysUtils.GetDriveIDFromLetter(ExtractFileDrive(fn))));
  {$endif}

  //cannot detect
  exit(-1);
end;

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

procedure Execute(CommandLine: string; Output: TStrings = nil);
const
  BUFSIZE = 2048;
var
  Process: TProcess;
  StrStream: TStringStream;
  BytesRead: longint;
  Running: boolean;
  Buffer: array[1..BUFSIZE] of byte;
begin
  Process := TProcess.Create(nil);
  Process.CommandLine := CommandLine;
  Process.Options := Process.Options + [poNoConsole];

  if Output <> nil then
  begin
    Process.Options := Process.Options + [poUsePipes, poStderrToOutPut];
    Output.Append('Execute: ' + Process.CommandLine);
  end;

  Process.Execute;

  StrStream := TStringStream.Create;

  try
    repeat
      Sleep(100);
      Application.ProcessMessages;

      Running := Process.Running;
      BytesRead := Min(BUFSIZE, Process.Output.NumBytesAvailable);
      if BytesRead > 0 then
      begin
        BytesRead := Process.Output.Read(Buffer, BytesRead);
        StrStream.Write(Buffer, BytesRead);
      end;
    until (BytesRead = 0) and not Running;
  except
    on E: Exception do
      if Output <> nil then
      begin
        Output.Append('Exception: ' + E.Message);
      end;
  end;

  if Output <> nil then
  begin
    Output.Append('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    if StrStream.Size > 0 then
    begin
      Output.Append(StrStream.DataString);
    end;
    Output.Append('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
  end;

  StrStream.Free;
  Process.Free;
end;

procedure StreamSaveToFile(Stream: TStream; FileName: String);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    CopyUnblocked(Stream, FileStream);
  finally
    FileStream.Free;
  end;
end;

procedure CopyUnblocked(FromStream, ToStream: TStream);
begin
  while FromStream.Position + 1024 * 1024 < FromStream.Size do
  begin
    ToStream.CopyFrom(FromStream, 1024 * 1024);
    Application.ProcessMessages;
  end;
  ToStream.CopyFrom(FromStream, FromStream.Size - FromStream.Position);
end;

end.
