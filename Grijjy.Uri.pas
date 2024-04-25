unit Grijjy.Uri;

{ URI helper }

{$I Grijjy.inc}

interface

uses
  System.SysUtils, { for String, Classes, and other utility functions }
  System.Classes,  { for TComponent and record types }
  System.Net.URLClient; { for TURI type }

type
  TgoURI = record
  private
    FURI: TURI; { Holds the TURI instance }
  public
    Scheme: String; { Holds the URI scheme }
    Username: String; { Holds the URI username }
    Password: String; { Holds the URI password }
    Host: String; { Holds the URI host }
    Port: Integer; { Holds the URI port }
    Path: String; { Holds the URI path }
    Query: String; { Holds the URI query }
    Params: String; { Holds the URI parameters }
    Fragment: String; { Holds the URI fragment }
  public
    constructor Create(const AUri: String);
    { Create a new TgoURI instance from the given AUri string }
    function ToString: String;
    { Convert the TgoURI instance back to a string }
  end;

implementation

{ TgoURI }

constructor TgoURI.Create(const AUri: String);
var
  I: Integer;
begin
  FURI := TURI.Create(AUri);
  Scheme := FURI.Scheme;
  Username := FURI.Username;
  Password := FURI.Password;
  Host := FURI.Host;
  Port := FURI.Port;
  Path := FURI.Path;
  Query := FURI.Query;
  for I := 0 to Length(FURI.Params) - 1 do
    Params := Params + FURI.Params[I].Name + '=' + FURI.Params[I].Value + '&';
  Params := Params.Substring(0, Params.Length - 1);
  Fragment := FURI.Fragment;
end;

function TgoURI.ToString: String;
var
  Auth: String;
begin
  if Username <> '' then
    Auth := Username + ':' + Password + '@'
  else
    Auth := '';
  Result := Scheme + '://' + Auth + Host;
  if ((Port <> -1) and (Port <> 0)) and
     ((SameText(Scheme, 'http') and (Port <> 80)) or (SameText(Scheme, 'https') and (Port <> 443))) then
    Result := Result + ':' + IntToStr(Port);
  Result := Result + Path;
  if Length(Params) > 0 then
    Result := Result + '?' + Params;
end;

end.
