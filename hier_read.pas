module hier_read;
define hier_read_line;
define hier_read_line_next;
define hier_read_eol;
define hier_read_block_start;
define hier_read_tk;
define hier_read_tk_req;
define hier_read_keyw;
define hier_read_keyw_req;
define hier_read_keyw_pick;
define hier_read_int;
define hier_read_fp;
define hier_read_bool;
define hier_read_string;
%include 'hier2.ins.pas';
{
********************************************************************************
*
*   Local subroutine READLINE (RD, STAT)
*
*   Read the next content line into the input buffer.  RD.LLEV is set to the
*   nesting level of the new line.
*
*   Blank lines and comment lines are not considered content.  A comment line is
*   any line where the first non-blank is "*".
}
procedure readline (                   {read next content line into buffer}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t);            {completion status}
  val_param; internal;

label
  eof, leave;

begin
  if rd.llev < 0 then goto eof;        {previously hit end of file ?}

  while true do begin                  {loop until content line or EOF}
    if rd.llev < 0 then exit;          {previously hit end of file ?}
    file_read_text (rd.conn, rd.buf, stat); {read next line from file}
    if file_eof(stat) then begin       {hit end of file ?}
      file_close (rd.conn);            {close the file}
      rd.llev := -1;                   {indicate hit end of file, file closed}
      goto eof;
      end;
    if sys_error(stat) then return;    {hard error ?}

    string_unpad (rd.buf);             {delete all trailing spaces from input line}
    if rd.buf.len <= 0 then next;      {ignore blank lines}
    rd.p := 1;                         {init new input line parse index}
    while rd.buf.str[rd.p] = ' ' do begin {skip over leading blanks}
      rd.p := rd.p + 1;
      end;
    if rd.buf.str[rd.p] = '*' then next; {ignore comment lines}
    exit;                              {this is a real content line}
    end;                               {back to read next line from file}

  rd.llev := (rd.p - 1) div 2;         {make nesting level of this line from indentation}
  if ((rd.llev * 2) + 1) <> rd.p then begin {invalid indentation ?}
    sys_stat_set (hier_subsys_k, hier_stat_badindent_k, stat); {set error status}
    hier_err_line_file (rd, stat);     {add line number, file name}
    end;
  goto leave;

eof:                                   {end of file encountered}
  rd.buf.len := 0;                     {as if empty line}
  rd.p := 1;

leave:
  rd.lret := false;                    {init to this line not returned}
  end;
{
********************************************************************************
*
*   Function HIER_READ_LINE (RD, STAT)
*
*   Read the next line from the input file.  The function returns TRUE if the
*   new content is at the same level as the previous line.  The function returns
*   FALSE once for each level being popped up.  The function returns FALSE
*   indefinitely after the end of the input file has been encountered.  A line
*   at a lower nesting level is an error.
*
*   On error, STAT is set to indicate the error, and the function returns FALSE.
*
*   Blank and comment lines are ignored.  A comment line is any line where the
*   first non-blank is "*".
}
function hier_read_line (              {read next line from input file}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t)             {completion status}
  :boolean;                            {at same nesting level, no error}
  val_param;

begin
  sys_error_none (stat);               {init to no error encountered}
  hier_read_line := false;             {init to error or different level}

  if rd.lret then begin                {need a new line ?}
    readline (rd, stat);               {read the new line}
    if sys_error(stat) then return;
    end;

  if rd.llev = rd.level then begin     {new line is at existing nesting level ?}
    rd.lret := true;                   {remember that this line was returned}
    hier_read_line := true;            {indicate returning with line at curr level}
    return;                            {return with the new line}
    end;

  if rd.llev < rd.level then begin     {new line is at a higher level ?}
    if rd.level > 0 then rd.level := rd.level - 1; {pop up one level}
    return;
    end;

  sys_stat_set (                       {unexpected subordinate level error}
    hier_subsys_k, hier_stat_lower_k, stat);
  hier_err_line_file (rd, stat);       {add line number, file name}
  end;
{
********************************************************************************
*
*   Function HIER_READ_LINE_NEXT (RD, STAT)
*
*   Read the next line from the input at the current or higher level.  Lines at
*   lower levels are ignored.
}
function hier_read_line_next (         {read next line at current or higher level}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t)             {completion status}
  :boolean;                            {at same nesting level, no error}
  val_param;

begin
  sys_error_none (stat);               {init to no error encountered}
  hier_read_line_next := false;        {init to error or different level}

  while true do begin                  {loop until line at or above curr level}
    if rd.lret then begin              {need a new line ?}
      readline (rd, stat);             {read the new line}
      if sys_error(stat) then return;
      end;
    if rd.llev <= rd.level then exit;  {at or above the current level ?}
    rd.lret := true;                   {mark this line as used}
    end;                               {back to get next line}

  if rd.llev = rd.level then begin     {new line is at existing nesting level ?}
    rd.lret := true;                   {remember that this line was returned}
    hier_read_line_next := true;       {this line is at the current level}
    return;                            {return with the new line}
    end;

  if rd.level > 0 then rd.level := rd.level - 1; {pop up one level}
  end;
{
********************************************************************************
*
*   Function HIER_READ_EOL (RD, STAT)
*
*   Checks for end of line enountered as expected.
*
*   If the input line has been exhausted, then the function returns TRUE with
*   STAT set to no error.
*
*   If a token is found, then the function returns FALSE, STAT is set to an
*   appropriate error assuming the extra token is not allowed, and the parse
*   index is restored to before the first extra token.
}
function hier_read_eol (               {check for at end of current input line}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t)             {extra token error if not end of line}
  :boolean;                            {at end of line, no error}
  val_param;

var
  tk: string_var32_t;                  {token}
  p: string_index_t;                   {original parse index}

begin
  tk.max := size_char(tk.str);         {init local var string}

  p := rd.p;                           {save original parse index}
  if not hier_read_tk (rd, tk) then begin {no token here, at end of line ?}
    sys_error_none (stat);             {indicate no error}
    hier_read_eol := true;             {indicate was at end of line}
    return;
    end;

  sys_stat_set (hier_subsys_k, hier_stat_extratk_k, stat); {extra token}
  sys_stat_parm_vstr (tk, stat);       {the extra token}
  hier_err_line_file (rd, stat);       {add line number and file name}
  rd.p := p;                           {restore parse index to before extra token}
  hier_read_eol := false;              {indicate not at end of line}
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_BLOCK_START (RD)
*
*   Go one level down into a subordinate block.  Subsequent lines will be read
*   expecting this hierarchy level.  Encountering content at a lower level is an
*   error, and content at a higher level causes HIER_READ_LINE to return FALSE
*   for each higher nesting level.
}
procedure hier_read_block_start (      {start reading one subordinate level down}
  in out  rd: hier_read_t);            {hierarchy reading state}
  val_param;

begin
  rd.level := rd.level + 1;
  end;
{
********************************************************************************
*
*   Function HIER_READ_TK (RD, TK)
*
*   Read the next token on the current input line.  When a token is found, the
*   function returns TRUE with the token in TK.  Otherwise the function returns
*   FALSE with TK set to the empty string.
}
function hier_read_tk (                {read next token from input line}
  in out  rd: hier_read_t;             {hierarchy reading state}
  in out  tk: univ string_var_arg_t)   {the returned token, empty str on EOL}
  :boolean;                            {token found}
  val_param;

var
  stat: sys_err_t;

begin
  hier_read_tk := true;                {init to indicate returning with token}

  string_token (rd.buf, rd.p, tk, stat); {try to read the next token}
  if sys_error(stat) then begin        {didn't get a token ?}
    tk.len := 0;                       {return the empty string}
    hier_read_tk := false;             {indicate not returning with a token}
    end;
  end;
{
********************************************************************************
*
*   Function HIER_READ_TK_REQ (RD, TK, STAT)
*
*   Read the next token from the input line into TK.  If a token is found, the
*   function returns TRUE and STAT is set to no error.  If no token is found,
*   then the function returns FALSE with STAT set to missing parameter error.
}
function hier_read_tk_req (            {read required token from input line}
  in out  rd: hier_read_t;             {input file reading state}
  in out  tk: univ string_var_arg_t;   {the returned token, empty str on EOL}
  out     stat: sys_err_t)             {completion status}
  :boolean;                            {token found, no error}
  val_param;

begin
  if hier_read_tk (rd, tk)             {try to read the token}
    then begin                         {got it}
      sys_error_none (stat);           {no error}
      hier_read_tk_req := true;
      end
    else begin                         {no parameter}
      hier_err_missing (rd, stat);     {set missing parameter error}
      hier_read_tk_req := false;
      end
    ;
  end;
{
********************************************************************************
*
*   Function HIER_READ_KEYW (RD, KEYW)
*
*   Read the next token on the current input line and return it all upper case
*   in KEYW.  The function returns TRUE when a token is found.  Otherwise, the
*   function returns FALSE.
}
function hier_read_keyw (              {read next token as keyword}
  in out  rd: hier_read_t;             {hierarchy reading state}
  in out  keyw: univ string_var_arg_t) {upper case token, empty str on EOL}
  :boolean;                            {token found}
  val_param;

begin
  hier_read_keyw := hier_read_tk (rd, keyw); {get the raw token}
  string_upcase (keyw);                {return the token in upper case}
  end;
{
********************************************************************************
*
*   Function HIER_READ_KEYW_REQ (RD, KEYW, STAT)
*
*   Get the next token as a keyword into KEYW.  If a token is found, the
*   function returns TRUE and STAT is set to no error.  If no token is found,
*   then the function returns FALSE with STAT set to missing parameter error.
}
function hier_read_keyw_req (          {read required keyword from input line}
  in out  rd: hier_read_t;             {input file reading state}
  in out  keyw: univ string_var_arg_t; {the returned keyword, empty str on EOL}
  out     stat: sys_err_t)             {completion status}
  :boolean;                            {keyword found, no error}
  val_param;

begin
  if hier_read_keyw (rd, keyw)         {try to read the keyword}
    then begin                         {got it}
      sys_error_none (stat);           {no error}
      hier_read_keyw_req := true;
      end
    else begin                         {no parameter}
      hier_err_missing (rd, stat);     {set missing parameter error}
      hier_read_keyw_req := false;
      end
    ;
  end;
{
********************************************************************************
*
*   Function HIER_READ_KEYW_PICK (RD, LIST, STAT)
*
*   Get the next token as a keyword and find which keyword in a supplied list it
*   is.  LIST is the list of possible keywords, upper case and separated by
*   blanks.
*
*   When the keyword read from the file matches a keyword in the list, then the
*   function returns the 1-N number of the matching list entry, and STAT is set
*   to no error.
*
*   The function can also return the following special values:
*
*     0    Keyword did not match any list entry.  STAT set to bad keyword error.
*
*     -1   No keyword was found.  STAT is set to missing parameter error.
}
function hier_read_keyw_pick (         {read keyword, pick from list}
  in out  rd: hier_read_t;             {hierarchy reading state}
  in      list: string;                {keywords, upper case, blank separated}
  out     stat: sys_err_t)             {completion status, no error on match}
  :sys_int_machine_t;                  {1-N list entry, 0 bad keyword, -1 no keyword}
  val_param;

var
  keyw: string_var32_t;                {the keyword read from the file}
  pick: sys_int_machine_t;             {number of matching list entry}

begin
  keyw.max := size_char(keyw.str);     {init local var string}

  if not hier_read_keyw_req (rd, keyw, stat) then begin {no keyword ?}
    hier_read_keyw_pick := -1;
    return;
    end;

  string_tkpick80 (keyw, list, pick);  {pick the keyword from the list}
  if pick = 0 then begin               {no match ?}
    sys_stat_set (hier_subsys_k, hier_stat_badkeyw_k, stat); {bad keyword}
    sys_stat_parm_vstr (keyw, stat);   {the keyword}
    hier_err_line_file (rd, stat);     {add line number and file name}
    hier_read_keyw_pick := 0;          {indicate bad keyword}
    return;
    end;

  hier_read_keyw_pick := pick;         {return 1-N number of matching list entry}
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_INT (RD, II, STAT)
*
*   Read the next token from the current input line and interpret it as an
*   integer.  The result is returned in II.  STAT is set appropriately if no
*   token is available, or the token can not be interpreted as a integer.
}
procedure hier_read_int (              {read next token as integer}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     ii: sys_int_machine_t;       {returned value}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tk: string_var32_t;                  {scratch token}

begin
  tk.max := size_char(tk.str);         {init local var string}

  if not hier_read_tk (rd, tk) then begin {no token ?}
    sys_stat_set (hier_subsys_k, hier_stat_noparm_k, stat);
    hier_err_line_file (rd, stat);
    ii := 0;
    return;
    end;

  string_t_int (tk, ii, stat);         {interpret as integer}
  if sys_error(stat) then begin        {failed to find integer value ?}
    sys_stat_set (hier_subsys_k, hier_stat_badint_k, stat);
    sys_stat_parm_vstr (tk, stat);
    hier_err_line_file (rd, stat);
    end;
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_FP (RD, FP, STAT)
*
*   Read the next token from the current input line and interpret it as a
*   floating point value.  The result is returned in FP.  STAT is set
*   appropriately if no token is available, or the token can not be interpreted
*   as floating point.
}
procedure hier_read_fp (               {read next token as floating point}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     fp: real;                    {returned value}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tk: string_var32_t;                  {scratch token}

begin
  tk.max := size_char(tk.str);         {init local var string}

  if not hier_read_tk (rd, tk) then begin {no token ?}
    sys_stat_set (hier_subsys_k, hier_stat_noparm_k, stat);
    hier_err_line_file (rd, stat);
    fp := 0.0;
    return;
    end;

  string_t_fpm (tk, fp, stat);         {interpret as floating point}
  if sys_error(stat) then begin        {failed to find floating point value ?}
    sys_stat_set (hier_subsys_k, hier_stat_badfp_k, stat);
    sys_stat_parm_vstr (tk, stat);
    hier_err_line_file (rd, stat);
    end;
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_BOOL (RD, TF, STAT)
*
*   Read the next token from the current input line and interpret it as a
*   boolean p value.  The result is returned in TF.  The token is
*   case-insensitive, and can be either TRUE, YES or ON for true, or FALSE, NO
*   or OFF for false.
*
*   STAT is set appropriately if no token is available, or the token can not be
*   interpreted as boolean.
}
procedure hier_read_bool (             {read next token as floating point}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     tf: boolean;                 {returne value}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tk: string_var32_t;                  {scratch token}

begin
  tk.max := size_char(tk.str);         {init local var string}

  if not hier_read_keyw (rd, tk) then begin {no token ?}
    sys_stat_set (hier_subsys_k, hier_stat_noparm_k, stat);
    hier_err_line_file (rd, stat);
    tf := false;
    return;
    end;

  string_t_bool (                      {interpret boolean value of the token}
    tk,                                {input string}
    [ string_tftype_tf_k,              {allow TRUE, FALSE}
      string_tftype_yesno_k,           {allow YES, NO}
      string_tftype_onoff_k],          {allow ON, OFF}
    tf,                                {returned boolean value}
    stat);
  if sys_error(stat) then begin        {failed to find boolean value ?}
    sys_stat_set (hier_subsys_k, hier_stat_badbool_k, stat);
    sys_stat_parm_vstr (tk, stat);
    hier_err_line_file (rd, stat);
    end;
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_STRING (RD, STR)
*
*   Read the remainder of the current line as a string.  The current line is
*   always exhausted by this routine.
}
procedure hier_read_string (           {read remainder of curr line as string}
  in out  rd: hier_read_t;             {hierarchy reading state}
  in out  str: univ string_var_arg_t); {returned string}
  val_param;

var
  n: sys_int_machine_t;                {number of characters to return}
  ii: sys_int_machine_t;               {scratch integer and loop counter}

begin
  n := rd.buf.len - rd.p + 1;          {number of available characters}
  n := min(n, str.max);                {clip to available room to return chars}
  str.len := n;                        {set the returned string length}

  for ii := 1 to n do begin            {once for each character to return}
    str.str[ii] := rd.buf.str[rd.p];   {get this character}
    rd.p := rd.p + 1;                  {update the reading index}
    end;                               {back for next character}

  rd.p := rd.buf.len + 1;              {the current line has been used up}
  end;
