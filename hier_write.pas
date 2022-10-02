{   Routines for writing various items to a hierarchy output file.
}
module hier_write;
define hier_write_line;
define hier_write_blankline;
define hier_write_vstr;
define hier_write_str;
define hier_write_vtk;
define hier_write_tk;
define hier_write_blank;
define hier_write_int;
define hier_write_fpf;
define hier_write_fps;
define hier_write_onoff;
define hier_write_block_start;
define hier_write_block_end;
%include 'hier2.ins.pas';
{
********************************************************************************
*
*   Subroutine HIER_WRITE_LINE (WR, STAT)
*
*   Write the current output line to the file open on WR.  The output line is
*   reset to empty.
}
procedure hier_write_line (            {write curr line to output file, reset line}
  in out  wr: hier_write_t;            {output file writing state}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  file_write_text (wr.buf, wr.conn, stat); {write the line}
  wr.buf.len := 0;                     {reset the output line to empty}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_BLANKLINE (WR, STAT)
*
*   Write a blank line to the output file if not at the start of the file.  The
*   current output line is written first if it is not empty.
}
procedure hier_write_blankline (       {write blank line unless at start of file}
  in out  wr: hier_write_t;            {output file writing state}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  sys_error_none (stat);               {init to no error encountered}

  if wr.buf.len > 0 then begin         {current output line is not empty ?}
    hier_write_line (wr, stat);        {write it}
    if sys_error(stat) then return;
    end;

  if wr.conn.lnum > 0 then begin       {not at start of file ?}
    hier_write_line (wr, stat);        {write the blank line}
    end;
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_VSTR (WR, VSTR)
*
*   Append the var string VSTR to the current output line.  If the output line
*   is currently empty, then indentation according to the current block nesting
*   level is written first.
}
procedure hier_write_vstr (            {write var string to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      vstr: univ string_var_arg_t); {the string to write}
  val_param;

var
  nsp: sys_int_machine_t;              {number of leading spaces for indentation}

begin
  if wr.buf.len <= 0 then begin        {this is first item on the output line ?}
    nsp := wr.lev * 2;                 {make number of blanks to add for indentation}
    while nsp > 0 do begin             {add the leading blanks for indentation}
      string_append1 (wr.buf, ' ');
      nsp := nsp - 1;                  {count one less leading blank left to write}
      end;
    end;

  string_append (wr.buf, vstr);        {append the string to the output line}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_STR (WR, STR)
*
*   Like HIER_WRITE_VSTR, except the argument is a Pascal string.
}
procedure hier_write_str (             {write Pascal string to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      str: string);                {the string to write}
  val_param;

var
  vstr: string_var80_t;

begin
  vstr.max := size_char(vstr.str);     {init local var string}

  string_vstring (vstr, str, size_char(str)); {convert to var string}
  hier_write_vstr (wr, vstr);          {write the var string}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_VTK (WR, VTK)
*
*   Write a token to the output line.  The string in VTK is written such that it
*   would be parsed as a separate but whole token from the resulting line.
}
procedure hier_write_vtk (             {write var string token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      vtk: univ string_var_arg_t); {the string to write as a single token}
  val_param;

var
  vstr: string_var8192_t;

begin
  vstr.max := size_char(vstr.str);     {init local var string}

  string_token_make (vtk, vstr);       {make single token from the input string}

  if wr.buf.len > 0 then begin         {there is previous content on the output line ?}
    string_append1 (wr.buf, ' ');      {write blank separator}
    end;
  hier_write_vstr (wr, vstr);          {write the token string to the output line}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_TK (WR, TK)
*
*   Write a token to the output line.  The token is supplies as a Pascal string.
}
procedure hier_write_tk (              {write Pascal token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      tk: string);                 {the string to write as a single token}
  val_param;

var
  vtk: string_var80_t;

begin
  vtk.max := size_char(vtk.str);       {init local var string}

  string_vstring (vtk, tk, size_char(tk)); {convert to var string}
  hier_write_vtk (wr, vtk);            {write it}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_BLANK (WR)
*
*   Write a single blank to the current output line.
}
procedure hier_write_blank (           {write single blank to output line}
  in out  wr: hier_write_t);           {output file writing state}
  val_param;

var
  tk: string_var4_t;

begin
  tk.max := size_char(tk.str);         {init local var string}

  tk.str[1] := ' ';                    {make string to write}
  tk.len := 1;
  hier_write_vstr (wr, tk);            {append string to output line}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_INT (WR, II)
*
*   Write the integer II as the next token to the current output line.
}
procedure hier_write_int (             {write integer token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      ii: sys_int_machine_t);      {the integer value to write}
  val_param;

var
  tk: string_var32_t;

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_int (tk, ii);               {make integer string}
  hier_write_vtk (wr, tk);             {append it as token to the output file}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_FPF (WR, FP, FDIG)
*
*   Write floating point token to the current outputline.  FP is the floating
*   point value to write, and FDIG is the number of fraction digits (digits
*   right of the decimal point).
}
procedure hier_write_fpf (             {write FP token, N fraction digits}
  in out  wr: hier_write_t;            {output file writing state}
  in      fp: real;                    {the floating point value to write}
  in      fdig: sys_int_machine_t);    {number of fraction digits}
  val_param;

var
  tk: string_var32_t;

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_fp_fixed (tk, fp, fdig);    {make FP string}
  hier_write_vtk (wr, tk);             {append it as token to the output file}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_FPS (WR, FP, SIG)
*
*   Write floating point token to the current outputline.  FP is the floating
*   point value to write.  The value will be written with SIG significant
*   digits.
}
procedure hier_write_fps (             {write FP token, N significant digits}
  in out  wr: hier_write_t;            {output file writing state}
  in      fp: real;                    {the floating point value to write}
  in      sig: sys_int_machine_t);     {number of significant digits to write}
  val_param;

var
  tk: string_var32_t;

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_fp_free (tk, fp, sig);      {make FP string}
  hier_write_vtk (wr, tk);             {append it as token to the output file}
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_ONOFF (WR, B)
*
*   Write a boolean value as a token to the output line.  Either "ON" or "OFF"
*   will be written.
}
procedure hier_write_onoff (           {write ON or OFF token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      b: boolean);                 {the value to write}
  val_param;

begin
  if b
    then hier_write_tk (wr, 'ON')
    else hier_write_tk (wr, 'OFF');
  end;
{
********************************************************************************
*
*   Local subroutine HIER_WRITE_BLOCK_START (OS)
*
*   Indicate that subsequent output file writing will be one nesting level lower
*   within the block structure.
}
procedure hier_write_block_start (     {start a new subordinate block}
  in out  wr: hier_write_t);           {output file writing state}
  val_param;

begin
  wr.lev := wr.lev + 1;                {indicate one more level within nested blocks}
  end;
{
********************************************************************************
*
*   Local subroutine HIER_WRITE_BLOCK_END (OS)
*
*   Indicate that subsequent output file writing will be one nesting level up
*   within the block structure.
}
procedure hier_write_block_end (       {end the current subordinate block}
  in out  wr: hier_write_t);           {output file writing state}
  val_param;

begin
  if wr.lev > 0                        {not already at top nesting level ?}
    then wr.lev := wr.lev - 1;         {indicate one level up in block hierarchy}
  end;
