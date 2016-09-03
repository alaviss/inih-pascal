{* Example: parse an INI file using a custom ini_reader and a string buffer for I/O

This example was provided by Grzegorz Sokół (https://github.com/greg-sokol)
in pull request https://github.com/benhoyt/inih/pull/38
*}

{$MODE OBJFPC}{$H+}{$J-}

{$LINK ini.o}
Uses inih, strings, ctypes;

Type
  configuration = record
    version: Integer;
    name   : String;
    email  : String
  end;

  buffer_ctx = record
    _ptr      : PChar;
    bytes_left: Integer;
  end;

  pconfiguration = ^configuration;
  pbuffer_ctx    = ^buffer_ctx;

Var
  config: configuration;
  ctx   : buffer_ctx;

Function ini_buffer_reader(_str: PChar; num: CInt; stream: Pointer): PChar; cdecl;
  Var
    ctx    : pbuffer_ctx;
    idx    : Integer = 0;
    newline: Char = #0;

  Begin
    ctx := pbuffer_ctx(stream);

    if ctx^.bytes_left <= 0 then exit(nil);

    for idx := 0 to num - 2 do begin
      if idx = ctx^.bytes_left then break;

      if ctx^._ptr[idx] = #10 then newline := #10;
      if ctx^._ptr[idx] = #13 then newline := #13;

      if newline <> #0 then break;
    end;

    StrLCopy(_str, PChar(ctx^._ptr), idx);

    ctx^._ptr += idx + 1;
    ctx^.bytes_left -= idx + 1;

    if (newline <> #0) and (ctx^.bytes_left > 0) and
        (((newline = #13) and (ctx^._ptr[0] = #10)) or
         ((newline = #10) and (ctx^._ptr[0] = #13))) then begin
      Dec(ctx^.bytes_left);
      Inc(ctx^._ptr)
    end;

    result := _str
  End;

Function handler(user: Pointer; const section, name, value: PChar): Integer; cdecl;
  Var
    pconfig: pconfiguration;

  Begin
    pconfig := pconfiguration(user);

    if (StrComp(section, 'protocol') = 0) and (StrComp(name, 'version') = 0) then
      val(value, pconfig^.version)
    else if (StrComp(section, 'user') = 0) and (StrComp(name, 'name') = 0) then
      pconfig^.name := value
    else if (StrComp(section, 'user') = 0) and (StrComp(name, 'email') = 0) then
      pconfig^.email := value
    else
      exit(0);

    result := 1
  End;

Begin
  ctx._ptr := '; Test ini buffer' + LineEnding +
             LineEnding +
             '[protocol]' + LineEnding +
             'version=42' + LineEnding +
             LineEnding +
             '[user]' + LineEnding +
             'name = Jane Smith' + LineEnding +
             'email = jane@smith.com' + LineEnding;
  ctx.bytes_left := Length(ctx._ptr);

  if ini_parse_stream(TINI_Reader(@ini_buffer_reader), @ctx, @handler, @config) < 0 then begin
    writeln('Can''t load buffer');
    halt(1)
  end;

  with config do
    writeln('Config loaded from buffer: version=', version, ', name=', name,
      ', email=',email)
End.
