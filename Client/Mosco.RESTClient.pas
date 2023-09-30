unit Mosco.RESTClient;

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
  System.JSON, System.Net.HttpClient,
  Mosco.API;

type
  IMoscoResponse = interface(IInterface)
    ['{EEED2A0C-5303-47E2-89E0-5701A69FC533}']
    function GetHTTPResponse: IHTTPResponse;
    function GetResults: TJSONValue;
    function GetStatusCode: Integer;
    function GetStatusMessage: string;
    function IsOK: Boolean;
    property StatusCode: Integer read GetStatusCode;
    property StatusMessage: string read GetStatusMessage;
    property Results: TJSONValue read GetResults;
    property HTTPResponse: IHTTPResponse read GetHTTPResponse;
  end;

  TMoscoRESTClient = class(TObject)
  private
    FHost: string;
    FPort: Integer;
    function Execute(const APath: string; const ARequest: string = ''): IMoscoResponse;
    function GetURL(const APath: string): string;
  public
    function CanSend: Boolean;
    function GetFrameworks(const ASDK: string; out AFrameworks: TArray<string>): Boolean;
    function GetIdentities(out AIdentities: TIdentities): Boolean;
    function GetProfile(const ABundleId: string; const AProfileKind: Integer; out AProfile: TProfile): Boolean;
    function GetProfileFile(const ABundleId: string; const AProfileKind: Integer; const AFileName: string): Boolean;
    function GetProfiles(out AProfiles: TProfiles): Boolean;
    function GetSDKs(out ASDKs: TArray<string>): Boolean;
    function GetVersion(out AVersion: string): Boolean;
    function UploadIPA(ATargetInfo: TTargetInfo): Boolean;
    function ShowApp(ATargetInfo: TTargetInfo): Boolean;
    property Host: string read FHost write FHost;
    property Port: Integer read FPort write FPort;
  end;

implementation

uses
  System.Classes, System.SysUtils, System.Net.URLClient, System.NetConsts, System.IOUtils, System.Zip,
  DW.OSLog, DW.JSON,
  DW.Base64.Helpers, DW.OSDevice, DW.IOUtils.Helpers;

type
  TMoscoResponse = class(TInterfacedObject, IMoscoResponse)
  private
    FHTTPResponse: IHTTPResponse;
    FJSON: TJSONValue;
  public
    { IMoscoResponse }
    function GetHTTPResponse: IHTTPResponse;
    function GetResults: TJSONValue;
    function GetStatusCode: Integer;
    function GetStatusMessage: string;
    function IsOK: Boolean;
  public
    constructor Create(const AHTTPResponse: IHTTPResponse);
    destructor Destroy; override;
  end;

  TMoscoExceptionResponse = class(TInterfacedObject, IMoscoResponse)
  private
    FStatusMessage: string;
  public
    { IMoscoResponse }
    function GetHTTPResponse: IHTTPResponse;
    function GetResults: TJSONValue;
    function GetStatusCode: Integer;
    function GetStatusMessage: string;
    function IsOK: Boolean;
  public
    constructor Create(const AException: Exception);
  end;

{ TMoscoResponse }

constructor TMoscoResponse.Create(const AHTTPResponse: IHTTPResponse);
var
  LContent: string;
begin
  inherited Create;
  FHTTPResponse := AHTTPResponse;
  LContent := FHTTPResponse.ContentAsString;
  FJSON := TJSONObject.ParseJSONValue(LContent);
  if FJSON = nil then
    FJSON := TJSONObject.Create;
end;

destructor TMoscoResponse.Destroy;
begin
  FJSON.Free;
  inherited;
end;

function TMoscoResponse.GetHTTPResponse: IHTTPResponse;
begin
  Result := FHTTPResponse;
end;

function TMoscoResponse.GetResults: TJSONValue;
begin
  FJSON.TryGetValue('Results', Result);
end;

function TMoscoResponse.GetStatusCode: Integer;
begin
  if not FJSON.TryGetValue('StatusCode', Result) then
    Result := -1;
end;

function TMoscoResponse.GetStatusMessage: string;
begin
  FJSON.TryGetValue('StatusMessage', Result);
end;

function TMoscoResponse.IsOK: Boolean;
begin
  Result := GetStatusCode = cStatusCodeOK;
end;

{ TMoscoExceptionResponse }

constructor TMoscoExceptionResponse.Create(const AException: Exception);
begin
  inherited Create;
  FStatusMessage := Format('%s: %s', [AException.ClassName, AException.Message]);
end;

function TMoscoExceptionResponse.GetHTTPResponse: IHTTPResponse;
begin
  Result := nil;
end;

function TMoscoExceptionResponse.GetResults: TJSONValue;
begin
  Result := nil;
end;

function TMoscoExceptionResponse.GetStatusCode: Integer;
begin
  Result := -1;
end;

function TMoscoExceptionResponse.GetStatusMessage: string;
begin
  Result := FStatusMessage;
end;

function TMoscoExceptionResponse.IsOK: Boolean;
begin
  Result := False;
end;

{ TMoscoRESTClient }

function TMoscoRESTClient.GetURL(const APath: string): string;
var
  LURI: TURI;
begin
  LURI.Scheme := TURI.SCHEME_HTTP;
  LURI.Host := FHost;
  LURI.Port := FPort;
  LURI.Path := APath;
  Result := LURI.ToString;
end;

function TMoscoRESTClient.CanSend: Boolean;
begin
  Result := not FHost.IsEmpty and (FPort > 0);
end;

function TMoscoRESTClient.Execute(const APath: string; const ARequest: string = ''): IMoscoResponse;
var
  LHTTP: THTTPClient;
  LResponse: IHTTPResponse;
  LRequest: TStream;
  LURL: string;
begin
  try
    LURL := GetURL(APath);
    TOSLog.d('Execute: %s', [LURL]);
    LHTTP := THTTPClient.Create;
    try
      LHTTP.ConnectionTimeout := 5000;
      if not ARequest.IsEmpty then
      begin
        LHTTP.ContentType := 'application/json';
        LRequest := TStringStream.Create(ARequest);
        try
          LResponse := LHTTP.Post(LURL, LRequest);
        finally
          LRequest.Free;
        end;
      end
      else
        LResponse := LHTTP.Get(LURL);
    finally
      LHTTP.Free;
    end;
    Result := TMoscoResponse.Create(LResponse);
  except
    on E: Exception do
      Result := TMoscoExceptionResponse.Create(E);
  end;
end;

function TMoscoRESTClient.GetVersion(out AVersion: string): Boolean;
var
  LResponse: IMoscoResponse;
begin
  Result := False;
  LResponse := Execute(cAPIPing);
  if LResponse.IsOK then
  begin
    Result := True;
    AVersion := LResponse.Results.Value;
  end
end;

function TMoscoRESTClient.ShowApp(ATargetInfo: TTargetInfo): Boolean;
//var
//  LResponse: IMoscoResponse;
//  LMessage: string;
begin
  ATargetInfo.User := TOSDevice.GetUsername;
  Result := Execute(cAPISystemShowApp, ATargetInfo.ToJSON).IsOK;
end;

function TMoscoRESTClient.UploadIPA(ATargetInfo: TTargetInfo): Boolean;
begin
  Result := False;  // TODO
end;

function TMoscoRESTClient.GetFrameworks(const ASDK: string; out AFrameworks: TArray<string>): Boolean;
var
  LResponse: IMoscoResponse;
begin
  Result := False;
  LResponse := Execute(cAPIXcodeFrameworksGet, TJSONHelper.ToJSON(ASDK, 'sdk'));
  if LResponse.IsOK then
  begin
    Result := True;
    AFrameworks := TJSONHelper.ToStringArray(TJSONArray(LResponse.Results));
  end;
end;

function TMoscoRESTClient.GetIdentities(out AIdentities: TIdentities): Boolean;
var
  LResponse: IMoscoResponse;
begin
  Result := False;
  LResponse := Execute(cAPIIdentitiesGet);
  if LResponse.IsOK then
  begin
    Result := True;
    AIdentities.FromJSONValue(LResponse.Results);
  end;
end;

function TMoscoRESTClient.GetProfile(const ABundleId: string; const AProfileKind: Integer; out AProfile: TProfile): Boolean;
var
  LResponse: IMoscoResponse;
  LRequest: TJSONObject;
begin
  AProfile := Default(TProfile);
  LRequest := TJSONObject.Create;
  try
    LRequest.AddPair('bundleid', TJSONString.Create(ABundleId));
    LRequest.AddPair('profilekind', AProfileKind);
    LResponse := Execute(cAPIProfileGet, LRequest.ToJSON);
  finally
    LRequest.Free;
  end;
  Result := LResponse.IsOK;
  if Result then
    AProfile.FromJSONValue(LResponse.Results);
end;

function TMoscoRESTClient.GetProfileFile(const ABundleId: string; const AProfileKind: Integer; const AFileName: string): Boolean;
var
  LResponse: IMoscoResponse;
  LRequest: TJSONObject;
begin
  LRequest := TJSONObject.Create;
  try
    LRequest.AddPair('bundleid', TJSONString.Create(ABundleId));
    LRequest.AddPair('profilekind', AProfileKind);
    LResponse := Execute(cAPIProfileFileGet, LRequest.ToJSON);
  finally
    LRequest.Free;
  end;
  Result := LResponse.IsOK;
  if Result then
    TBase64Helper.DecodeDecompressToFile(LResponse.Results.Value, AFileName);
end;

function TMoscoRESTClient.GetProfiles(out AProfiles: TProfiles): Boolean;
var
  LResponse: IMoscoResponse;
begin
  LResponse := Execute(cAPIProfilesGet);
  Result := LResponse.IsOK;
  if Result then
    AProfiles.FromJsonValue(LResponse.Results);
end;

function TMoscoRESTClient.GetSDKs(out ASDKs: TArray<string>): Boolean;
var
  LResponse: IMoscoResponse;
begin
  LResponse := Execute(cAPIXcodeSDKsGet);
  Result := LResponse.IsOK;
  if Result then
    ASDKs := TJSONHelper.ToStringArray(TJSONArray(LResponse.Results));
end;

end.
