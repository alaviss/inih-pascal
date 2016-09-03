{$MODE OBJFPC}{$H+}{$J-}

Uses inih, strings, ctypes;

{$LINK ini.o}

Var
  error       : Integer = 0;
  prev_section: String[50] = '';

Function dumper(user: Pointer; const section, name, value: PChar): CInt; cdecl;
  Var
    p: PChar;
  Begin
    p := stralloc(50);

    if strcomp(section, strpcopy(p, prev_section)) <> 0 then begin
      if prev_section[0] <> #0 then writeln;

      writeln('[', section, ']');

      prev_section := strpas(section);
    end;

    writeln(name, ' = ', value);

    result := 1
  End;

Begin
  if argc <= 1 then begin
    writeln('Usage: ini_dump filename.ini');
    halt(1)
  end;

  error := ini_parse(argv[1], @dumper, Nil);

  if error < 0 then begin
    writeln('Can''t read ''', argv[1], '''!');
    halt(2)
  end
  else if error > 0 then begin
    writeln('Bad config file (first error on line', error, ')!');
    halt(3)
  end
End.
