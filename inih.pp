{$MACRO+}

Unit inih;

{$LINKLIB c}

Interface
  Uses CTypes;

  Type
    // Prototype of handler function
    TINI_Handler = Function(user: Pointer; const section, name, value: PChar): CInt; cdecl;

    // Prototype of fgets-style reader function
    TINI_Reader = Function(str: PChar; num: CInt; stream: Pointer): CInt; cdecl;

    PFile = type Pointer;

  {* Parse given INI-style file. May have [section]s, name=value pairs
     (whitespace stripped), and comments starting with ';' (semicolon). Section
     is "" if name=value pair parsed before any section heading. name:value
     pairs are also supported as a concession to Python's configparser.

     For each name=value pair parsed, call handler function with given user
     pointer as well as section, name, and value (data only valid for duration
     of handler call). Handler should return nonzero on success, zero on error.

     Returns 0 on success, line number of first error on parse error (doesn't
     stop on first error), -1 on file open error, or -2 on memory allocation
     error (only when INI_USE_STACK is zero).
  *}
  Function ini_parse(const filename: PChar; handler: TINI_Handler; user: Pointer): CInt;
    cdecl; external;

  Function ini_parse_file(_file: PFile; handler: TINI_Handler; user: Pointer): CInt;
    cdecl; external;

  {* Same as ini_parse(), but takes an ini_reader function pointer instead of
     filename. Used for implementing custom or string-based I/O. *}

  Function ini_parse_stream(reader: TINI_Reader; stream: Pointer;
    handler: TINI_Handler; user: Pointer): CInt; cdecl; external;

  Function fopen(filename, rights: PChar): PFile; cdecl; external;
  Procedure fclose(f: PFile); cdecl; external;

Implementation

End.

// vim: set ft=pascal et:
