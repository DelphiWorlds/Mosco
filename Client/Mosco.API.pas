unit Mosco.API;

{*******************************************************}
{                                                       }
{                   Mosco Client                        }
{                                                       }
{          Code for comms with the Mosco app            }
{                                                       }
{  Copyright 2020-2023 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

uses
  System.JSON, System.Types;

const
  cAPIALToolUploadIPA = '/altool/uploadipa';
  cAPIIdentitiesGet = '/profiles/identities';
  cAPIPing = '/ping';
  cAPIProfileGet = '/profiles/profile';
  cAPIProfileFileGet = '/profiles/profilefile';
  cAPIProfilesGet = '/profiles/profiles';
  cAPISystemDevices = '/system/devices';
  cAPISystemExtensionFilesGet = '/system/extensionfiles';
  cAPISystemExtensionNamesGet = '/system/extensionnames';
  cAPISystemShowApp = '/system/showapp';
  cAPIXcodeDeployIOS = '/xcode/deployios';
  cAPIXcodeFrameworksGet = '/xcode/frameworks';
  cAPIXcodeGet = '/xcode/get';
  cAPIXcodeList = '/xcode/list';
  cAPIXcodeNotifyLaunch = '/xcode/notifylaunch';
  cAPIXcodeSDKsGet = '/xcode/sdks';
  cAPIXcodeSDKInfoGet = '/xcode/sdkinfo';

  cStatusCodeOK = 0;

  cStatusCodeSystemShowAppError = 900;
  cStatusCodeUploadAppNoFile = 901;
  cStatusCodeUploadAppError = 902;
  cStatusCodeXcodeGetFrameworksError = 903;
  cStatusCodeXcodeGetSDKsError = 904;
  cStatusCodeSystemDeployExtensionsError = 905;
  cStatusCodeXcodeDeployIOSError = 906;

type
  TClientStatus = (Connected, Disconnected);

  TProfileKind = (AppStore, AdHoc, Development, Enterprise);

  TProfileState = (OnMac, OnAppStoreConnect);

  TProfileStates = set of TProfileState;

  TProfileCertificate = record
    CertificateType: string;
    DisplayName: string;
    Expiry: TDateTime;
    Name: string;
  end;

  TProfile = record
    AppID: string;
    BundleID: string;
    Certificates: TArray<TProfileCertificate>;
    CreationDate: TDateTime;
    Entitlements: string;
    EntitlementsFileName: string;
    ExpirationDate: TDateTime;
    FileName: string;
    FileDateTime: TDateTime;
    Kind: TProfileKind;
    Platforms: TArray<string>;
    ProfileName: string;
    ProvisionedDevices: TArray<string>;
    States: TProfileStates;
    TaskAllow: Boolean; // part of entitlements (<get-task-allow>)
    TeamIdentifier: string; // part of entitlements
    TeamIdentifiers: TArray<string>;
    UUID: string;
    function CertDescriptions: TArray<string>;
    procedure FromJSON(const AValue: string);
    procedure FromJSONValue(const AValue: TJSONValue);
    function GetProfileKind: TProfileKind;
    function Exists: Boolean;
    function IsValid: Boolean;
    function ToJSON: string;
    function ToJSONValue: TJSONValue;
  end;

  TProfiles = TArray<TProfile>;

  TProfilesHelper = record helper for TProfiles
  public
    function Count: Integer;
    function FindIndexFromFileName(const AFileName: string; var AIndex: Integer): Boolean;
    function FindIndexFromUUID(const AUUID: string; var AIndex: Integer): Boolean;
    procedure FromJSON(const AValue: string);
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
    function ToJSON: string;
  end;

  TIdentity = record
    Description: string;
    Expiry: TDateTime;
    function LongDescription: string;
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TIdentities = TArray<TIdentity>;

  TIdentitiesHelper = record helper for TIdentities
  public
    procedure FromJSON(const AValue: string);
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSON: string;
    function ToJSONValue: TJSONValue;
    function ToText(const ASeparator: string): string;
  end;

  TCodesignInfo = record
    Identity: string;
    Target: string;
  end;

  TALToolInfo = record
    AppleID: string;
    AppType: string;
    BundleID: string;
    CertName: string;
    ExtraOptions: string;
    Password: string;
    Provider: string;
    StapleTicket: Boolean;
    Target: string;
    // TeamID: string;
    function IsPackage: Boolean;
  end;

  TACToolInfo = record
    BuildType: Integer;
    InfoPlist: string;
    MinVersion: string;
    PlatformName: string;
    PlatformVersion: string;
    Target: string;
  end;

  TAppIconImage = record
    Filename: string;
    Idiom: string;
    Scale: string;
    Size: string;
    ImageSize: TSizeF;
    function Description: string;
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TAppIconImages = TArray<TAppIconImage>;

  TAppIconImagesHelper = record helper for TAppIconImages
  public
    function Count: Integer;
    function FindMatching(const ASourcePath, ADestPath: string): Boolean;
    function FindBySize(const AWidth, AHeight: Single; out AImage: TAppIconImage): Boolean;
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TContentsInfo = record
    Author: string;
    Version: string;
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TAppIconContents = record
    Images: TAppIconImages;
    Info: TContentsInfo;
    procedure FromJSON(const AValue: string);
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
    function ToJSON: string;
  end;

  TProvider = record
    Name: string;
    PublicID: string;
    ShortName: string;
    WWDRTeamID: string;
    KeyValue: string;
    function DisplayValue: string;
  end;

  TProviders = TArray<TProvider>;

  TPingInfo = record
    Version: string;
  end;

  TTargetInfo = record
    User: string;
    Profile: string;
    FileName: string;
    DeviceID: string;
    BuildKind: Integer;
    constructor Create(const AProfile, AFileName: string);
    function ToJSON: string;
    procedure FromJSONValue(const AValue: TJSONValue);
  end;

  TExtensionFile = record
    FileName: string;
    Content: string; // Compressed, Base64 encoded
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TExtensionFiles = TArray<TExtensionFile>;

  TExtensionFilesHelper = record helper for TExtensionFiles
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TExtension = record
    Folder: string;
    Files: TExtensionFiles;
    procedure AddFiles(const AFolder: string);
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TExtensions = TArray<TExtension>;

  TExtensionsHelper = record helper for TExtensions
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TSDK = record
    Name: string;
    Path: string;
    Build: string;
    Version: string;
    IsSimulator: Boolean;
    constructor Create(const AValue: TJSONValue);
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TSDKs = TArray<TSDK>;

  TXcodeInfo = record
    Version: string;
    Build: string;
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

  TSDKInfo = record
    Xcode: TXcodeInfo;
    SDKs: TSDKs;
    procedure FromJSONValue(const AValue: TJSONValue);
    function ToJSONValue: TJSONValue;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, System.Generics.Collections, System.IOUtils, System.Math,
  {$IF Defined(MACOS)}
  Macapi.AppKit, Macapi.Helpers,
  Mosco.Logger, Mosco.Config,
  {$ENDIF}
  DW.OSLog,
  DW.Base64.Helpers;

{ TTargetInfo }

constructor TTargetInfo.Create(const AProfile, AFileName: string);
begin
  Profile := AProfile;
  FileName := AFileName;
end;

procedure TTargetInfo.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('user', User);
  AValue.TryGetValue('profile', Profile);
  AValue.TryGetValue('filename', FileName);
  AValue.TryGetValue('deviceid', DeviceID);
  AValue.TryGetValue('buildkind', BuildKind);
end;

function TTargetInfo.ToJSON: string;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  try
    LJSON.AddPair('user', User);
    LJSON.AddPair('profile', Profile);
    LJSON.AddPair('filename', FileName);
    LJSON.AddPair('deviceid', DeviceID);
    LJSON.AddPair('buildkind', BuildKind);
    Result := LJSON.ToJSON;
  finally
    LJSON.Free;
  end;
end;

{ TProfile }

procedure TProfile.FromJSONValue(const AValue: TJSONValue);
var
  LValue: string;
  LJSONArray: TJSONArray;
  I: Integer;
  LCertificate: TProfileCertificate;
begin
  Certificates := [];
  ProvisionedDevices := [];
  Platforms := [];
  CreationDate := 0;
  ExpirationDate := 0;
  AValue.TryGetValue('AppID', AppID);
  AValue.TryGetValue('BundleID', BundleID);
  AValue.TryGetValue('CertDescriptions', LJSONArray);
  if LJSONArray <> nil then
  begin
    for I := 0 to LJSONArray.Count - 1 do
    begin
      LCertificate := Default(TProfileCertificate);
      LCertificate.DisplayName := LJSONArray.Items[I].Value;
      Certificates := Certificates + [LCertificate];
    end;
  end;
  AValue.TryGetValue('ProvisionedDevices', LJSONArray);
  if LJSONArray <> nil then
  begin
    for I := 0 to LJSONArray.Count - 1 do
      ProvisionedDevices := ProvisionedDevices + [LJSONArray.Items[I].Value];
  end;
  AValue.TryGetValue('CreationDate', LValue);
  if not LValue.IsEmpty then
    CreationDate := ISO8601ToDate(LValue)   ;
  AValue.TryGetValue('Entitlements', LValue);
  Entitlements := TBase64Helper.DecodeDecompress(LValue);
  AValue.TryGetValue('ExpiryDate', LValue);
  if not LValue.IsEmpty then
    ExpirationDate := ISO8601ToDate(LValue);
  AValue.TryGetValue('FileName', FileName);
  AValue.TryGetValue('Platforms', Platforms);
  AValue.TryGetValue('ProfileName', ProfileName);
  AValue.TryGetValue('UUID', UUID);
  AValue.TryGetValue('TaskAllow', TaskAllow);
end;

function TProfile.GetProfileKind: TProfileKind;
begin
  if TaskAllow then
    Result := TProfileKind.Development
  else if Length(ProvisionedDevices) > 0 then
    Result := TProfileKind.AdHoc
  else
    Result := TProfileKind.AppStore;
end;

function TProfile.Exists: Boolean;
begin
  Result := not AppID.IsEmpty and not ProfileName.IsEmpty;
end;

function TProfile.IsValid: Boolean;
begin
  Result := Exists and (Length(Certificates) > 0);
end;

function TProfile.ToJSON: string;
var
  LValue: TJSONValue;
begin
  LValue := ToJSONValue;
  try
    Result := LValue.ToJSON;
  finally
    LValue.Free;
  end;
end;

function TProfile.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
  LJSONArray: TJSONArray;
  I: Integer;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('AppID', AppID);
  LJSON.AddPair('BundleID', BundleID);
  LJSON.AddPair('CreationDate', DateToISO8601(CreationDate));
  LJSON.AddPair('Entitlements', TBase64Helper.CompressEncode(Entitlements));
  LJSON.AddPair('ExpiryDate', DateToISO8601(ExpirationDate));
  LJSON.AddPair('FileName', FileName);
  LJSON.AddPair('TaskAllow', TJSONBool.Create(TaskAllow));
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(Platforms) - 1 do
    LJSONArray.Add(Platforms[I]);
  LJSON.AddPair('Platforms', LJSONArray);
  LJSON.AddPair('ProfileName', ProfileName);
  LJSON.AddPair('UUID', UUID);
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(Certificates) - 1 do
    LJSONArray.Add(Certificates[I].DisplayName);
  LJSON.AddPair('CertDescriptions', LJSONArray);
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(ProvisionedDevices) - 1 do
    LJSONArray.Add(ProvisionedDevices[I]);
  LJSON.AddPair('ProvisionedDevices', LJSONArray);
  Result := LJSON;
end;

function TProfile.CertDescriptions: TArray<string>;
var
  LCertificate: TProfileCertificate;
begin
  Result := [];
  for LCertificate in Certificates do
    Result := Result + [LCertificate.DisplayName];
end;

procedure TProfile.FromJSON(const AValue: string);
var
  LJSON: TJSONValue;
begin
  LJSON := TJSONObject.ParseJSONValue(AValue);
  if LJSON <> nil then
  try
    FromJSONValue(LJSON);
  finally
    LJSON.Free;
  end;
end;

{ TProfilesHelper }

function TProfilesHelper.Count: Integer;
begin
  Result := Length(Self);
end;

function TProfilesHelper.FindIndexFromFileName(const AFileName: string; var AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    if Self[I].FileName.Equals(AFileName) then
    begin
      AIndex := I;
      Exit(True);
    end;
  end;
end;

function TProfilesHelper.FindIndexFromUUID(const AUUID: string; var AIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    if Self[I].UUID.Equals(AUUID) then
    begin
      AIndex := I;
      Exit(True);
    end;
  end;
end;

procedure TProfilesHelper.FromJSON(const AValue: string);
var
  LJSON: TJSONValue;
begin
  LJSON := TJSONObject.ParseJSONValue(AValue);
  if LJSON <> nil then
  try
    FromJSONValue(LJSON);
  finally
    LJSON.Free;
  end;
end;

procedure TProfilesHelper.FromJSONValue(const AValue: TJSONValue);
var
  LJSON: TJSONArray;
  I: Integer;
  LProfile: TProfile;
begin
  if AValue is TJSONArray then
  begin
    LJSON := TJSONArray(AValue);
    for I := 0 to LJSON.Count - 1 do
    begin
      LProfile.FromJSONValue(LJSON.Items[I]);
      Self := Self + [LProfile];
    end;
  end;
end;

function TProfilesHelper.ToJSON: string;
var
  LValue: TJSONValue;
begin
  LValue := ToJSONValue;
  try
    Result := LValue.ToJSON;
  finally
    LValue.Free;
  end;
end;

function TProfilesHelper.ToJSONValue: TJSONValue;
var
  LJSONArray: TJSONArray;
  I: Integer;
begin
  LJSONArray := TJSONArray.Create;
  for I := 0 to Count - 1 do
    LJSONArray.AddElement(Self[I].ToJSONValue);
  Result := LJSONArray;
end;

{ TIdentity }

procedure TIdentity.FromJSONValue(const AValue: TJSONValue);
var
  LValue: string;
begin
  AValue.TryGetValue('Description', Description);
  AValue.TryGetValue('Expiry', LValue);
  if not LValue.IsEmpty then
    Expiry := ISO8601ToDate(LValue);
end;

function TIdentity.LongDescription: string;
begin
  if Expiry > 0 then
    Result := Format('%s [Expires %s]', [Description, FormatDateTime('dd-MMM-yyyy', Expiry)])
  else
    Result := Description;
end;

function TIdentity.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Description', Description);
  LJSON.AddPair('Expiry', DateToISO8601(Expiry));
  Result := LJSON;
end;

{ TIdentitiesHelper }

function TIdentitiesHelper.ToText(const ASeparator: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(Self) - 1 do
  begin
    Result := Result + AnsiQuotedStr(Self[I].Description, '"');
    if I < Length(Self) - 1 then
      Result := Result + ASeparator;
  end;
end;

procedure TIdentitiesHelper.FromJSON(const AValue: string);
var
  LJSON: TJSONValue;
begin
  LJSON := TJSONObject.ParseJSONValue(AValue);
  if LJSON <> nil then
  try
    FromJSONValue(LJSON);
  finally
    LJSON.Free;
  end;
end;

procedure TIdentitiesHelper.FromJSONValue(const AValue: TJSONValue);
var
  LJSON: TJSONArray;
  I: Integer;
  LIdentity: TIdentity;
begin
  if AValue is TJSONArray then
  begin
    LJSON := TJSONArray(AValue);
    for I := 0 to LJSON.Count - 1 do
    begin
      LIdentity.FromJSONValue(LJSON.Items[I]);
      Self := Self + [LIdentity];
    end;
  end;
end;

function TIdentitiesHelper.ToJSON: string;
var
  LValue: TJSONValue;
begin
  LValue := ToJSONValue;
  try
    Result := LValue.ToJSON;
  finally
    LValue.Free;
  end;
end;

function TIdentitiesHelper.ToJSONValue: TJSONValue;
var
  LJSONArray: TJSONArray;
  I: Integer;
begin
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(Self) - 1 do
    LJSONArray.AddElement(Self[I].ToJSONValue);
  Result := LJSONArray;
end;

{ TALToolInfo }

function TALToolInfo.IsPackage: Boolean;
begin
  Result := Target.EndsWith('.pkg');
end;

{ TAppIconImage }

function TAppIconImage.Description: string;
begin
  Result := Format('Idiom: %s, Scale: %S, Size: %s', [Idiom, Scale, Size]);
end;

procedure TAppIconImage.FromJSONValue(const AValue: TJSONValue);
var
  LSizeParts: TArray<string>;
  LScale: Integer;
  LFormatSettings: TFormatSettings;
begin
  AValue.TryGetValue('filename', Filename);
  AValue.TryGetValue('idiom', Idiom);
  AValue.TryGetValue('scale', Scale);
  LScale := StrToIntDef(Scale.Substring(0, Length(Scale) - 1), 0);
  if AValue.TryGetValue('size', Size) and (LScale > 0) then
  begin
    LSizeParts := Size.Split(['x'], 2);
    if Length(LSizeParts) = 2 then
    begin
      LFormatSettings := TFormatSettings.Create;
      LFormatSettings.DecimalSeparator := '.';
      TryStrToFloat(LSizeParts[0], ImageSize.cx, LFormatSettings);
      TryStrToFloat(LSizeParts[1], ImageSize.cy, LFormatSettings);
      ImageSize.cx := ImageSize.cx * LScale;
      ImageSize.cy := ImageSize.cy * LScale;
    end;
  end;
end;

function TAppIconImage.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  if not Filename.IsEmpty then
    LJSON.AddPair('filename', Filename);
  LJSON.AddPair('idiom', Idiom);
  LJSON.AddPair('scale', Scale);
  LJSON.AddPair('size', Size);
  Result := LJSON;
end;

{ TContentsInfo }

procedure TContentsInfo.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('author', Author);
  AValue.TryGetValue('version', Version);
end;

function TContentsInfo.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('author', Author);
  LJSON.AddPair('version', Version);
  Result := LJSON;
end;

{ TAppIconContents }

procedure TAppIconContents.FromJSON(const AValue: string);
var
  LJSON: TJSONValue;
begin
  LJSON := TJSONObject.ParseJSONValue(AValue);
  if LJSON <> nil then
  try
    FromJSONValue(LJSON);
  finally
    LJSON.Free;
  end;
end;

procedure TAppIconContents.FromJSONValue(const AValue: TJSONValue);
var
  LValue: TJSONValue;
begin
  if AValue.TryGetValue('images', LValue) then
    Images.FromJSONValue(LValue);
  if AValue.TryGetValue('info', LValue) then
    Info.FromJSONValue(LValue);
end;

function TAppIconContents.ToJSON: string;
var
  LJSONValue: TJSONValue;
begin
  LJSONValue := ToJSONValue;
  try
    Result := LJSONValue.ToJSON;
  finally
    LJSONValue.Free;
  end;
end;

function TAppIconContents.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('images', Images.ToJSONValue);
  LJSON.AddPair('info', Info.ToJSONValue);
  Result := LJSON;
end;

{$IF Defined(MACOS)}
function GetImageSize(const AImage: NSImage): TPoint;
var
  LRep: NSImageRep;
  I: Integer;
begin
  Result := TPoint.Create(Trunc(AImage.size.width), Trunc(AImage.size.height));
  for I := 0 to AImage.representations.count - 1 do
  begin
    LRep := TNSImageRep.Wrap(AImage.representations.objectAtIndex(I));
    if LRep.pixelsWide > Result.X then
      Result.X := LRep.pixelsWide;
    if LRep.pixelsHigh > Result.Y then
      Result.Y := LRep.pixelsHigh;
  end;
end;
{$ENDIF}

{ TAppIconImagesHelper }

function TAppIconImagesHelper.Count: Integer;
begin
  Result := Length(Self);
end;

function TAppIconImagesHelper.FindBySize(const AWidth, AHeight: Single; out AImage: TAppIconImage): Boolean;
var
  LImage: TAppIconImage;
begin
  Result := False;
  for LImage in Self do
  begin
    if (LImage.ImageSize.cx = AWidth) and (LImage.ImageSize.cy = AHeight) then
    begin
      AImage := LImage;
      Exit(True);
    end;
  end;
end;

function TAppIconImagesHelper.FindMatching(const ASourcePath, ADestPath: string): Boolean;
{$IF Defined(MACOS)}
var
  LIconImage: TAppIconImage;
  LImage: NSImage;
  LImageSize: TPoint;
  LFile, LCopyToFileName: string;
  I: Integer;
begin
  Result := True;
  LImage := TNSImage.Wrap(TNSImage.OCClass.alloc);
  if TMoscoConfig.Current.ShowDeepDiagnostics then
    TLogger.Log('Searching image files in ' + ASourcePath);
  for LFile in TDirectory.GetFiles(ASourcePath, '*.png', TSearchOption.soTopDirectoryOnly) do
  begin
    LImage.initWithContentsOfFile(StrToNSStr(LFile));
    LImageSize := GetImageSize(LImage);
    if TMoscoConfig.Current.ShowDeepDiagnostics then
      TLogger.Log(TPath.GetFileName(LFile) + Format(' is %d x %d', [LImageSize.X, LImageSize.Y]));
    for I := 0 to Length(Self) - 1 do
    begin
      LIconImage := Self[I];
      if (Trunc(LIconImage.ImageSize.cx) = LImageSize.X) and (Trunc(LIconImage.ImageSize.cy) = LImageSize.Y) then
        Self[I].Filename := TPath.GetFileName(LFile);
    end;
  end;
  if TMoscoConfig.Current.ShowDeepDiagnostics then
    TLogger.Log('Checking files against AppIconConfig');
  for I := 0 to Length(Self) - 1 do
  begin
    LIconImage := Self[I];
    LCopyToFileName := TPath.Combine(ADestPath, LIconImage.Filename);
    if not LIconImage.Filename.IsEmpty then
    begin
      if TMoscoConfig.Current.ShowDeepDiagnostics then
        TLogger.Log(LIconImage.Description + ' matched with: ' + TPath.GetFileName(LIconImage.Filename));
      if not TFile.Exists(LCopyToFileName) then
        TFile.Copy(TPath.Combine(ASourcePath, LIconImage.Filename), LCopyToFileName);
    end
    else
    begin
      TLogger.Log('Did not find a matching image for: ' + LIconImage.Description);
      Result := False; // Does not exit - just indicates that not all images were found
    end;
  end;
end;
{$ELSE}
begin
  Result := False;
end;
{$ENDIF}

procedure TAppIconImagesHelper.FromJSONValue(const AValue: TJSONValue);
var
  LJSON: TJSONArray;
  I: Integer;
  LImage: TAppIconImage;
begin
  if AValue is TJSONArray then
  begin
    LJSON := TJSONArray(AValue);
    for I := 0 to LJSON.Count - 1 do
    begin
      LImage.FromJSONValue(LJSON.Items[I]);
      Self := Self + [LImage];
    end;
  end;
end;

function TAppIconImagesHelper.ToJSONValue: TJSONValue;
var
  LJSONArray: TJSONArray;
  I: Integer;
begin
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(Self) - 1 do
    LJSONArray.AddElement(Self[I].ToJSONValue);
  Result := LJSONArray;
end;

{ TProvider }

function TProvider.DisplayValue: string;
begin
  Result := Format('%s (%s)', [Name, ShortName]);
end;

{ TExtension }

procedure TExtension.AddFiles(const AFolder: string);
var
  LExtensionFile: TExtensionFile;
  LFileName: string;
begin
  Folder := AFolder;
  TOSLog.d('Folder: %s', [AFolder]);
  for LFileName in TDirectory.GetFiles(Folder, '*.*', TSearchOption.soAllDirectories) do
  begin
    TOSLog.d('Full FileName: %s', [LFileName]);
    LExtensionFile := Default(TExtensionFile);
    LExtensionFile.FileName := LFileName.Substring(Length(Folder));
    TOSLog.d('FileName: %s', [LExtensionFile.FileName]);
    LExtensionFile.Content := TBase64Helper.CompressEncodeFromFile(LFileName);
    Files := Files + [LExtensionFile];
  end;
end;

procedure TExtension.FromJSONValue(const AValue: TJSONValue);
var
  LValue: TJSONValue;
begin
  AValue.TryGetValue('Folder', Folder);
  if AValue.TryGetValue('Files', LValue) then
    Files.FromJSONValue(LValue);
end;

function TExtension.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Folder', Folder);
  LJSON.AddPair('Files', Files.ToJSONValue);
  Result := LJSON;
end;

{ TExtensionFile }

procedure TExtensionFile.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('FileName', FileName);
  AValue.TryGetValue('Content', Content);
end;

function TExtensionFile.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('FileName', FileName);
  LJSON.AddPair('Content', Content);
  Result := LJSON;
end;

{ TExtensionFilesHelper }

procedure TExtensionFilesHelper.FromJSONValue(const AValue: TJSONValue);
var
  LJSON: TJSONArray;
  I: Integer;
  LExtensionFile: TExtensionFile;
begin
  if AValue is TJSONArray then
  begin
    LJSON := TJSONArray(AValue);
    for I := 0 to LJSON.Count - 1 do
    begin
      LExtensionFile.FromJSONValue(LJSON.Items[I]);
      Self := Self + [LExtensionFile];
    end;
  end;
end;

function TExtensionFilesHelper.ToJSONValue: TJSONValue;
var
  LJSONArray: TJSONArray;
  I: Integer;
begin
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(Self) - 1 do
    LJSONArray.AddElement(Self[I].ToJSONValue);
  Result := LJSONArray;
end;

{ TExtensionsHelper }

procedure TExtensionsHelper.FromJSONValue(const AValue: TJSONValue);
var
  LJSON: TJSONArray;
  I: Integer;
  LExtension: TExtension;
begin
  if AValue is TJSONArray then
  begin
    LJSON := TJSONArray(AValue);
    for I := 0 to LJSON.Count - 1 do
    begin
      LExtension.FromJSONValue(LJSON.Items[I]);
      Self := Self + [LExtension];
    end;
  end;
end;

function TExtensionsHelper.ToJSONValue: TJSONValue;
var
  LJSONArray: TJSONArray;
  I: Integer;
begin
  LJSONArray := TJSONArray.Create;
  for I := 0 to Length(Self) - 1 do
    LJSONArray.AddElement(Self[I].ToJSONValue);
  Result := LJSONArray;
end;

{ TSDK }

constructor TSDK.Create(const AValue: TJSONValue);
begin
  FromJSONValue(AValue);
end;

procedure TSDK.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('Name', Name);
  AValue.TryGetValue('Path', Path);
  AValue.TryGetValue('Build', Build);
  AValue.TryGetValue('Version', Version);
  AValue.TryGetValue('IsSimulator', IsSimulator);
end;

function TSDK.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Name', Name);
  LJSON.AddPair('Path', Path);
  LJSON.AddPair('Build', Build);
  LJSON.AddPair('Version', Version);
  LJSON.AddPair('IsSimulator', IsSimulator);
  Result := LJSON;
end;

{ TXcodeInfo }

procedure TXcodeInfo.FromJSONValue(const AValue: TJSONValue);
begin
  AValue.TryGetValue('Version', Version);
  AValue.TryGetValue('Build', Build);
end;

function TXcodeInfo.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Version', Version);
  LJSON.AddPair('Build', Build);
  Result := LJSON;
end;

{ TSDKInfo }

procedure TSDKInfo.FromJSONValue(const AValue: TJSONValue);
var
  LMember, LValue: TJSONValue;
begin
  if AValue.TryGetValue('Xcode', LMember) then
    Xcode.FromJSONValue(LMember);
  if AValue.TryGetValue('SDKs', LMember) and (LMember is TJSONArray) then
  begin
    for LValue in TJSONArray(LMember) do
      SDKs := SDKs + [TSDK.Create(LValue)];
  end;
end;

function TSDKInfo.ToJSONValue: TJSONValue;
var
  LJSON: TJSONObject;
  LArray: TJSONArray;
  LSDK: TSDK;
begin
  LJSON := TJSONObject.Create;
  LJSON.AddPair('Xcode', Xcode.ToJSONValue);
  LArray := TJSONArray.Create;
  for LSDK in SDKs do
    LArray.AddElement(LSDK.ToJSONValue);
  LJSON.AddPair('SDKs', LArray);
  Result := LJSON;
end;

end.
