unit utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function GetVBoxY(const y: integer): integer;

implementation

function GetVBoxY(const y: integer): integer;
begin
  Result:=y+31;
end;

end.

