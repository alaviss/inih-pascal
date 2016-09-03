{$MODE OBJFPC}{$H+}{$J-}

Uses inih, ctypes, strings;

{$LINK ini.o}

Type
  configuration = record
    version: Integer;
    name   : String;
    email  : String
  end;

  pconfiguration = ^configuration;

Var
  config: configuration;

Function handler(user: Pointer; const section, name, value: PChar): CInt; cdecl;
  Var
    pconfig: pconfiguration;

  Begin
    pconfig := pconfiguration(user);

    if (strcomp('protocol', section) or strcomp('version', name)) = 0 then
      val(value, pconfig^.version)
    else if (strcomp('user', section) or strcomp('name', name)) = 0 then
      pconfig^.name := value
    else if (strcomp('user', section) or strcomp('email', name)) = 0 then
      pconfig^.email := value
    else
      exit(0);

    result := 1
  End;

Begin
  if (ini_parse('test.ini', @handler, @config) < 0) then begin
    writeln('Can''t load ''test.ini''');
    halt(1)
  end;

  writeln('Config loaded from ''test.ini'': version=', config.version,
    ', name=', config.name, ', email=', config.email)
End.
