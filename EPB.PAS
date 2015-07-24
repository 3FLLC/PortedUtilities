Program EPB;

/////////////////////////////////////////////////////////////////////////////
// ED'S PASCAL BEAUTIFIER v1.5
// Copyright 1990 by Edward Lee (edlee@chinet.chi.il.us)
// Original Language: Turbo Pascal v4.0
//
// 31-Jan-1990 20:00 Program begun
//  1-Feb-1990 16:41
//  2-Feb-1990 16:47 v1.0 complete, Capitalizes keywords
//  4-Feb-1990 22:34 v1.1 complete, -Lower case option added
//  7-Feb-1990 00:29 v1.2 complete, Non-alphabetic token padding added. Identifier parsing debugged
// 25-Mar-1990 21:15 v1.3 maintenance ) append rule modified; (***) parsing debugged; REGISTERS and TEXT keywords added
// 26-May-1990 16:56 v1.4 complete, optimized loop in identifier parsing. Added identifier substitution option
//  7-Sep-1991 13:03 v1.5 maintenance
// 23-Jul-2015 18:00 v1.5a ported to Modern Pascal, spent next day expanding the grammar for Modern Pascal!
// The inputfile and outputfile may have the same name.
// If only the inputfile is specified, the outputfile is assumed to be same
// name unless -o to STDOUT is specified.
//
// Possible future feature:  full, automatic indentation
/////////////////////////////////////////////////////////////////////////////

CONST
   nkeys = 258;  (* Number of key strings to capitalize *)

  listkeys : ARRAY [1..nkeys] OF STRING [17] =
[
'ABS',
'ABSOLUTE',
'ADDR',
'AND',
'APPEND',
'ARC',
'ARCTAN',
'ARRAY',
'ASSIGN',
'ASSIGNCRT',
'BAR',
'BAR3D',
'BEGIN',
'BLOCKREAD',
'BLOCKWRITE',
'BOOLEAN',
'BYTE',
'CASE',
'CHAR',
'CHDIR',
'CHR',
'CIRCLE',
'CLEARDEVICE',
'CLEARVIEWPORT',
'CLOSE',
'CLOSEGRAPH',
'CLREOL',
'CLRSCR',
'COMP',
'CONCAT',
'CONST',
'COPY',
'COS',
'CSEG',
'DEC',
'DELAY',
'DELETE',
'DELLINE',
'DETECTGRAPH',
'DISKFREE',
'DISKSIZE',
'DISPOSE',
'DIV',
'DO',
'DOSEXITCODE',
'DOUBLE',
'DOWNTO',
'DRAWPOLY',
'DSEG',
'ELLIPSE',
'ELSE',
'END',
'EOF',
'EOLN',
'ERASE',
'EXEC',
'EXIT',
'EXP',
'EXTENDED',
'EXTERNAL',
'FALSE',
'FILE',
'FILEPOS',
'FILESIZE',
'FILLCHAR',
'FILLPOLY',
'FINDFIRST',
'FINDNEXT',
'FLOODFILL',
'FLUSH',
'FOR',
'FORWARD',
'FRAC',
'FREEMEM',
'FUNCTION',
'GETARCCOORDS',
'GETASPECTRATIO',
'GETBKCOLOR',
'GETCOLOR',
'GETDATE',
'GETDIR',
'GETFATTR',
'GETFILLPATTERN',
'GETFILLSETTINGS',
'GETFTIME',
'GETGRAPHMODE',
'GETIMAGE',
'GETINTVEC',
'GETLINESETTINGS',
'GETMAXCOLOR',
'GETMAXX',
'GETMAXY',
'GETMEM',
'GETMODERANGE',
'GETPALLETTE',
'GETPIXEL',
'GETTEXTSETTINGS',
'GETTIME',
'GETVIEWSETTINGS',
'GETX',
'GETY',
'GOTO',
'GOTOXY',
'GRAPHDEFAULTS',
'GRAPHERRORMESG',
'GRAPHRESULT',
'HALT',
'HI',
'HIGHVIDEO',
'IF',
'IMAGESIZE',
'IMPLEMENTATION',
'IN',
'INC',
'INITGRAPH',
'INLINE',
'INSERT',
'INSLINE',
'INT',
'INTEGER',
'INTERFACE',
'INTERRUPT',
'INTR',
'IORESULT',
'KEEP',
'KEYPRESSED',
'LABEL',
'LENGTH',
'LINE',
'LINEREL',
'LINETO',
'LN',
'LO',
'LONGINT',
'LOWVIDEO',
'MARK',
'MAXAVAIL',
'MEMAVAIL',
'MKDIR',
'MOD',
'MOVE',
'MOVEREL',
'MOVETO',
'MSDOS',
'NEW',
'NIL',
'NORMVIDEO',
'NOSOUND',
'NOT',
'ODD',
'OF',
'OFS',
'OR',
'ORD',
'OUTTEXT',
'OUTTEXTXY',
'PACKED',
'PACKTIME',
'PARAMCOUNT',
'PARAMSTR',
'PI',
'PIESLICE',
'POINTER',
'POS',
'PRED',
'PROCEDURE',
'PROGRAM',
'PTR',
'PUTIMAGE',
'PUTPIXEL',
'RANDOM',
'RANDOMIZE',
'READ',
'READKEY',
'READLN',
'REAL',
'RECORD',
'RECTANGLE',
'REGISTERBGIFONT',
'REGISTERBGIDRIVER',
'REGISTERS',
'RELEASE',
'RENAME',
'REPEAT',
'RESET',
'RESTORECRTMODE',
'REWRITE',
'RMDIR',
'ROUND',
'SEEK',
'SEEKEOF',
'SEEKEOLN',
'SEG',
'SET',
'SETACTIVEPAGE',
'SETALLPALETTE',
'SETBKCOLOR',
'SETCOLOR',
'SETDATE',
'SETFATTR',
'SETFILLPATTERN',
'SETFILLSTYLE',
'SETFTIME',
'SETGRAPHBUFSIZE',
'SETGRAPHMODE',
'SETINTVEC',
'SETLINESTYLE',
'SETPALETTE',
'SETTEXTBUF',
'SETTEXTJUSTIFY',
'SETTEXTSTYLE',
'SETTIME',
'SETUSERCHARSIZE',
'SETVIEWPORT',
'SETVISUALPAGE',
'SHORTINT',
'SHL',
'SHR',
'SIN',
'SINGLE',
'SIZEOF',
'SOUND',
'SPTR',
'SQR',
'SQRT',
'SSEG',
'STR',
'STRING',
'SUCC',
'SWAP',
'TEXT',
'TEXTBACKGROUND',
'TEXTCOLOR',
'TEXTHEIGHT',
'TEXTMODE',
'TEXTWIDTH',
'THEN',
'TO',
'TRUE',
'TRUNC',
'TRUNCATE',
'TYPE',
'UNIT',
'UNPACKTIME',
'UNTIL',
'UPCASE',
'USES',
'VAL',
'VAR',
'WHEREX',
'WHEREY',
'WHILE',
'WINDOW',
'WITH',
'WORD',
'WRITE',
'WRITELN',
'XOR'];
   (* const listkeys (whew!) *)
   sizebuf = 65535;  (* Let's go for the maximum buffer size *)

TYPE
   mybuf = ARRAY [0..65534] OF CHAR;

VAR
   (* Input and Output buffer pointers *)
   a,b: ^mybuf;
   istream, lcase, ostream, showbrackcom, showparencom: BOOLEAN;
   ch, lastch: CHAR;
   infile, outfile: FILE;
   i:Longint;
   ext, filename, iname, lstr, oname, Oident, path, RLident, RUident, s, ustr: STRING;
   ia, ib, nread, nwrit: Longint;


FUNCTION binsearch (s : STRING) : BOOLEAN;
(*
 * Binary Search variation:  success or failure returned, no index returned
 *
 * middle := (left+right) div 2
 * if middle=left then success := (s$ = a[left]) or (s$ = a[right]) else
 *   if s$ < a[middle] then right := middle;  repeat from top  else
 *     if s$ > a[middle] then left := middle;  repeat from top  else  success := true;
 *
 * The success flag may be left undefined before entering the search routine
 *)
VAR
   flag: BOOLEAN;
   b, m, t: WORD;

{listkeys, nkeys}
BEGIN
   b := 1;
   t := nkeys;
   while true do begin
      m := (b + t) DIV 2;
      IF (m = b) THEN flag := ( (s = listkeys [b]) OR (s = listkeys [t]) )
      ELSE IF (s < listkeys [m]) THEN BEGIN
         t := m;
         continue;
      END
      ELSE IF (s > listkeys [m]) THEN BEGIN
         b := m;
         continue;
      END
      ELSE flag := TRUE;
      result := flag;
      break;
   end; {while}
END;  (* binsearch *)

PROCEDURE writeblock;
{ib, outfile, b nwrit, oname}
BEGIN
   BLOCKWRITE (outfile, b^, ib, nwrit);
   IF (nwrit <> ib) AND (oname <> '') THEN BEGIN  // Dont check output to STDOUT
      WRITELN ('pb:  cannot finish outputting');
      WRITELN ('ib = ', ib, ' nwritten = ', nwrit);
      CLOSEFILE (outfile);
      HALT(1);
   END;
   ib := 0;
END;  (* writeblock *)

PROCEDURE getblock;
{ia, infile, a, sizebuf, nread}
BEGIN
   ia := 0;
   BLOCKREAD (infile, a^, sizebuf, nread);
   IF (nread = 0) THEN BEGIN
      writeblock;
      CLOSEFILE(infile);
      HALT(1);
   END;
END;  (* getblock *)

PROCEDURE skipspace;
{a, ia, nread}
BEGIN
   WHILE ( (a^ [ia] = #32) OR (a^ [ia] = #13) OR (a^ [ia] = #10) ) DO BEGIN
      INC (ia);
      IF (ia >= nread) THEN getblock;
   END;
END;  (* skipspace *)

PROCEDURE outc (c : CHAR);
{b, ib, lastch, sizebuf}
BEGIN
   CASE c OF
      '[','(','<','+','/','*','-',':':IF (lastch <> #32) AND (lastch <> #13) AND (lastch <> #10) THEN BEGIN
         b^ [ib] := #32;
         INC (ib);
         IF (ib = sizebuf) THEN writeblock;
      END;
      '=':IF (lastch <> #32) AND (lastch <> #13) AND (lastch <> #10) AND
         (lastch <> ':') AND (lastch <> '<') AND (lastch <> '>') THEN BEGIN
         b^ [ib] := #32;
         INC (ib);
         IF (ib = sizebuf) THEN writeblock;
      END;
      '>':IF (lastch <> #32) AND (lastch <> #13) AND (lastch <> #10) AND
         (lastch <> '<') THEN BEGIN
         b^ [ib] := #32;
         INC (ib);
         IF (ib = sizebuf) THEN writeblock;
      END;
      ')':IF (lastch = ')') THEN BEGIN
         b^ [ib] := #32;
         INC (ib);
         IF (ib = sizebuf) THEN writeblock;
      END;
(* case c *)
      ELSE IF (c <> #32) AND (c <> #13) AND (c <> #10) THEN
         CASE lastch OF
            '<':IF (c <> '>') AND (c <> '=') THEN BEGIN
               b^ [ib] := #32;
               INC (ib);
               IF (ib = sizebuf) THEN writeblock;
            END;
            '>':IF (c <> '=') THEN BEGIN
               b^ [ib] := #32;
               INC (ib);
               IF (ib = sizebuf) THEN writeblock;
            END;
            ':':IF (c <> '=') THEN BEGIN
               b^ [ib] := #32;
               INC (ib);
               IF (ib = sizebuf) THEN writeblock;
            END;
            ')':IF (c <> ';') AND (c <> ',') THEN BEGIN
               b^ [ib] := #32;
               INC (ib);
               IF (ib = sizebuf) THEN writeblock;
            END;
            '=','+','/','*','-',',':BEGIN
               b^ [ib] := #32;
               INC (ib);
               IF (ib = sizebuf) THEN writeblock;
            END;
         END;  (* case lastch *)
   END;  (* case c *)
   b^ [ib] := c;
   INC (ib);
   IF (ib = sizebuf) THEN writeblock;
   lastch := c;
END;  (* outc *)

PROCEDURE outp (c : CHAR);
{b, ib, lastch, sizebuf}
BEGIN
   b^ [ib] := c;
   INC (ib);
   IF (ib = sizebuf) THEN writeblock;
END;  (* outp *)

PROCEDURE outl (s : STRING);
VAR
   ch:CHAR;
   i,len:INTEGER;
{b, ib, sizebuf}
BEGIN
   len := LENGTH (s);
   IF (len <> 0) THEN BEGIN
      ch := s [1];
      IF (ch >= 'A') AND (ch <= 'Z') THEN ch := CHR (ORD (ch) + 32);
      outc (ch);
   END;
   FOR i := 2 TO len DO BEGIN
      ch := s [i];
      IF (ch >= 'A') AND (ch <= 'Z') THEN ch := CHR (ORD (ch) + 32);
      b^ [ib] := ch;
      INC (ib);
      IF (ib = sizebuf) THEN writeblock;
   END;
   lastch := ch;
END;  (* outl *)

PROCEDURE outs (s : STRING);
VAR
   i,len:INTEGER;

BEGIN
   len := LENGTH (s);
   IF (len <> 0) THEN outc (s [1]);
   FOR i := 2 TO len DO BEGIN
      b^ [ib] := s [i];
      INC (ib);
      IF (ib = sizebuf) THEN writeblock;
   END;
   lastch := s [len];
END;  (* outs *)

PROCEDURE SplitPFE (pf : STRING; VAR p : STRING; VAR f : STRING; VAR e : STRING);
VAR i : INTEGER;
BEGIN
   p := '';
   f := '';
   e := '';
   i := LENGTH (pf);
   WHILE ( (POS (COPY (pf, i, 1), ':/\') = 0) AND (i > 0) ) DO DEC (i);
   p := COPY (pf, 1, i);
   f := COPY (pf, i + 1, 255);
   i := POS ('.', f);
   IF (i > 0) THEN BEGIN
      e := COPY (f, i + 1, 3);
      f := COPY (f, 1, i);
   END;
END;

label start, findasterisk, findasterisk2;

{---- MAIN PROGRAM ----}
BEGIN
   IF (PARAMCOUNT <2 ) THEN BEGIN
      WRITELN (#10'ED''S PASCAL BEAUTIFIER v1.5, Copyright 1991 by Edward Lee, -Ed L');
      WRITELN ('edlee@chinet.chi.il.us');
      WRITELN (#10'DESCRIPTION:');
      WRITELN ('  This program capitalizes keywords and adds spaces around certain tokens.');
      WRITELN ('  Optionally, this program filters comments and uncapitalizes user-defined');
      WRITELN ('  LABEL, CONSTant, TYPE, VARiable, FUNCTION, and PROCEDURE identifiers.');
      WRITELN ('  In addition, this program can perform identifier substitutions by ignoring');
      WRITELN ('  identifiers that are in comments or literal strings, unlike most editors.');
      WRITELN (#10'INVOCATION:'#13#10'  epb [-biLop] [infile] [outfile] [-s Identifier Replacement]');
      WRITELN (#10'OPTIONS (case insensitive):');
      WRITELN (' -b  Shut off the output of Bracket comments:  { ... }');
      WRITELN (' -p  Shut off the output of Parentheses comments:  (* ... *)');
      WRITELN (' -i  Use the STDIN  stream for Input  instead of INFILE');
      WRITELN (' -o  Use the STDOUT stream for Output instead of OUTFILE');
      WRITELN (' -L  Cast all alphabetic characters that are non-keywords, non-comments,');
      WRITELN ('     and non-string literals into Lower case');
      WRITELN (' -s  Substitue all occurances of Identifier with a Replacement string');
      WRITELN ('     through a case-insensitive search.');
      HALT(1);
   END;

   showparencom := TRUE;
   showbrackcom := TRUE;
   istream := FALSE;
   ostream := FALSE;
   lcase := FALSE;
   Oident := '';
   RLident := '';
   RUident := '';
   i:=1; // changes for "mp pretty.p"
   WHILE (i < PARAMCOUNT) DO BEGIN   (* Process options *)
      INC (i);
      s := PARAMSTR (i);
      IF (s [1] = '-') THEN BEGIN
         IF (POS ('b', s) > 0) OR (POS ('B', s) > 0) THEN showbrackcom := FALSE;
         IF (POS ('p', s) > 0) OR (POS ('P', s) > 0) THEN showparencom := FALSE;
         IF (POS ('i', s) > 0) OR (POS ('I', s) > 0) THEN istream := TRUE;
         IF (POS ('o', s) > 0) OR (POS ('O', s) > 0) THEN ostream := TRUE;
         IF (POS ('l', s) > 0) OR (POS ('L', s) > 0) THEN lcase := TRUE;
         IF (POS ('s', s) > 0) OR (POS ('S', s) > 0) THEN BEGIN
            INC (i);
            Oident := PARAMSTR (i);
            INC (i);
            RLident := PARAMSTR (i);
            IF (i > PARAMCOUNT) THEN BEGIN
               WRITELN ('epb:  Error.  The -s option has been used without enough parameters.');
               HALT(1);
            END;
         END;  (* if (pos ('s' ... *)
      END;  (* if (s [1] ... *)
   END;  (* while *)

(* Normalize Original and Replacement strings via upper case function *)
   FOR i := 1 TO LENGTH (Oident) DO
      Oident [i] := UPCASE (Oident [i]);
   FOR i := 1 TO LENGTH (RLident) DO
      RUident := RUident + UPCASE (RLident [i]);
   iname := '';
   oname := '';
   IF NOT (istream AND ostream) THEN BEGIN
      i := 1; // changes for "mp pretty.p"
      WHILE (i < PARAMCOUNT) DO BEGIN   (* Get filename(s) *)
         INC (i);
         s := PARAMSTR (i);
         IF (s [1] <> '-') THEN BEGIN  (* Skip option flags *)
            IF (istream) THEN BEGIN    (* Input is from STDIN *)
               oname := s;
               Break;//GOTO outer;
            END
            ELSE IF (ostream) THEN BEGIN    (* Output is to STDOUT *)
               iname := s;
               Break;//GOTO outer;
            END
            ELSE IF (iname = '') THEN iname:=s  (* Input is from infile *)
            ELSE BEGIN
               oname := s;        (* Output is to outfile *)
               Break;//GOTO outer;
            END;
         END  (* if (s [1] ... *)
         ELSE IF (POS ('s', s) > 0) OR (POS ('S', s) > 0) THEN i := i + 2;
      END;  (* while *)
   END;  (* if not *)

//outer :
   splitPFE (iname, path, filename, ext);

   IF (COPY (filename, LENGTH (filename), 1) <> '.') THEN BEGIN
      filename := filename + '.';
      ext := 'PAS';
      iname := path + filename + ext;
   END;
   s := path + filename + 'BAK';
   IF (iname <> '') THEN
      IF (iname = oname) Or ((oname = '') AND NOT ostream) THEN BEGIN
        ASSIGNFILE(infile, s);
        {$I-} RESET(infile, 1); {$I+}
        IF (IORESULT = 0) THEN BEGIN
           CLOSEFILE(infile);
           ERASEFILE(infile);
        END;
        ASSIGNFILE(infile, iname);
        {$I-} RESET(infile, 1); {$I+}
        IF (IORESULT = 0) THEN BEGIN
           CLOSEFILE(infile);
           RENAMEFILE(infile, s);
        END
        ELSE BEGIN
           WRITELN ('epb:  cannot rename original file, ', iname, ', to ', s, '.');
           HALT(1);
        END;
         oname := iname;
         iname := s;
      END;

  ASSIGNFILE (infile, iname);
  {$I-} RESET(infile, 1); {$I+}
  IF (IORESULT <> 0) THEN BEGIN
     WRITELN ('epb:  cannot open input file, ', iname);
     HALT(1);
  END;

   splitPFE (oname, path, filename, ext);
   IF (COPY (filename, LENGTH (filename), 1) <> '.') THEN BEGIN
      filename := filename + '.';
      ext := 'PAS';
      oname := path + filename + ext;
   END;

  ASSIGNFILE (outfile, oname);  REWRITE(outfile, 1);

   NEW (a);
   NEW (b);
   getblock; 
   ib := 0;
   lastch := #0;
   lstr := '';
   ustr := '';
start:
   while true do begin
      ch := a^ [ia];
      CASE ch OF
         #39:   (* Do not process the contents of literal strings *)
             BEGIN
             outc (a^ [ia]);
             INC (ia);
             IF (ia >= nread) THEN getblock;
             outp (a^ [ia]);
             WHILE (a^ [ia] <> #39) DO BEGIN
                INC (ia);
                IF (ia >= nread) THEN getblock;
                outp (a^ [ia]);
             END;  (* a^[ia] = #39 *)
             INC (ia);
         IF (ia >= nread) THEN getblock;
         GOTO start;
      END;

    '/' :   { Do not process the contents of // comments }
      BEGIN
         INC (ia);
         IF (ia >= nread) THEN getblock;
         IF (a^ [ia] = '/') THEN BEGIN
            IF (showparencom) THEN begin
               outc (ch);
               lastch:=#32;
               outc (ch);
            End;
            WHILE (a^ [ia] <> #13) and (a^[ia]<>#10) DO BEGIN
               INC (ia);
               IF (ia >= nread) THEN getblock;
               IF (showparencom) THEN outp (a^ [ia]);
            END;
            INC (ia);
            GOTO start;
         END
         ELSE IF (a^ [ia] <> '*') THEN BEGIN
            outc (ch);
            GOTO start;
         END
         ELSE BEGIN  (* A comment has begun *)
            IF (showparencom) THEN  BEGIN
               outp (ch);
               outp (a^ [ia]);
            END;
            INC (ia);
            IF (ia >= nread) THEN getblock;
            IF (showparencom) THEN outp (a^ [ia]);
findasterisk:
            WHILE (a^ [ia] <> '*') DO BEGIN
               INC (ia);
               IF (ia >= nread) THEN getblock;
               IF (showparencom) THEN outp (a^ [ia]);
            END;  (* a^[ia] = '*' *)
            INC (ia);
            IF (ia >= nread) THEN getblock;
            IF (showparencom) THEN outp (a^ [ia]);
            IF (a^ [ia] <> '/') THEN GOTO findasterisk;
            INC (ia);
            IF (ia >= nread) THEN getblock;
            GOTO start;
         END;
      END;

    '{' :   (* Do not process the contents of { ... } comments *)
      BEGIN
         IF (showbrackcom) THEN outc (a^ [ia]);
         INC (ia);
         IF (ia >= nread) THEN getblock;
         IF (showbrackcom) THEN outp (a^ [ia]);
         WHILE (a^ [ia] <> '}') DO BEGIN
            INC (ia);
            IF (ia >= nread) THEN getblock;
            IF (showbrackcom) THEN outp (a^ [ia]);
         END;  (* a^[ia] = '}' *)
         INC (ia);
         IF (ia >= nread) THEN getblock;
         GOTO start;
      END;

    '(' :   { Do not process the contents of (* ... *) comments }
      BEGIN
         INC (ia);
         IF (ia >= nread) THEN getblock;
         IF (a^ [ia] <> '*') THEN BEGIN
            outc (ch);
            GOTO start;
         END
         ELSE BEGIN  (* A comment has begun *)
            IF (showparencom) THEN  BEGIN
               outp (ch);
               outp (a^ [ia]);
            END;
            INC (ia);
            IF (ia >= nread) THEN getblock;
            IF (showparencom) THEN outp (a^ [ia]);
findasterisk2:
            WHILE (a^ [ia] <> '*') DO BEGIN
               INC (ia);
               IF (ia >= nread) THEN getblock;
               IF (showparencom) THEN outp (a^ [ia]);
            END;  (* a^[ia] = '*' *)
            INC (ia);
            IF (ia >= nread) THEN getblock;
            IF (showparencom) THEN outp (a^ [ia]);
            IF (a^ [ia] <> ')') THEN GOTO findasterisk2;
            INC (ia);
            IF (ia >= nread) THEN getblock;
            GOTO start;
         END;
      END;

    'A'..'Z', 'a'..'z', '_' :
      BEGIN
        REPEAT
        ustr := ustr + UPCASE (ch);
        lstr := lstr + ch;
        INC (ia);
        IF (ia >= nread) THEN getblock;
        ch := a^ [ia];
        UNTIL ( (ch < 'A') OR (ch > 'Z') ) AND
              ( (ch < 'a') OR (ch > 'z') ) AND
              ( (ch < '0') OR (ch > '9') ) AND
              (ch <> '_');  {Turbo Pascal Sets are too slow}

      IF (ustr = Oident) THEN BEGIN
         ustr := RUident;
         lstr := RLident;
      END;

      IF (binsearch (ustr) ) THEN outs (ustr)
      ELSE IF (lcase) THEN outl (lstr)
      ELSE outs (lstr);
      lstr := '';
      ustr := '';
      GOTO start;
   END;

  ELSE BEGIN
      outc (ch);
      INC (ia);
      IF (ia >= nread) THEN getblock;
      GOTO start;
  END;

  END;  (* CASE ch *)
  Break;
end; {while}

(*Inline Procedures:
 *  skipquote (a, ia);
 *  skipbrack (a, ia);
 *  skipparens(a, ia);
 *  getident  (a, ia);
 *)
END.
