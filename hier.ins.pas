{   Public include file for the HIER library.
*
*   This library manipulates hierarchical data, particularly writing/reading
*   hierarchical data to/from files.
}
const
  hier_subsys_k = -69;                 {HIER library subsyste ID}
  hier_stat_badindent_k = 1;           {invalid indentation}
  hier_stat_lower_k = 2;               {line at unexpected lower level}
  hier_stat_extratk_k = 3;             {extra token, end of line expected}
  hier_stat_noparm_k = 4;              {missing parameter}
  hier_stat_badint_k = 5;              {bad integer parameter}
  hier_stat_badfp_k = 6;               {bad floating point parameter}
  hier_stat_badbool_k = 7;             {bad boolean parameter}

type
  hier_write_p_t = ^hier_write_t;
  hier_write_t = record                {state for writing hierarchy to a file}
    conn: file_conn_t;                 {connection to the file}
    buf: string_var8192_t;             {one line output buffer}
    lev: sys_int_machine_t;            {nesting level, 0 at top}
    end;

  hier_read_p_t = ^hier_read_t;
  hier_read_t = record                 {state for reading hierarchy from a file}
    conn: file_conn_t;                 {connection to the file}
    level: sys_int_machine_t;          {current reading nesting level, 0 = top}
    llev: sys_int_machine_t;           {curr line level, -1 EOF read and file closed}
    buf: string_var8192_t;             {current input line}
    p: string_index_t;                 {parse index into BUF}
    lret: boolean;                     {the current input line has been returned}
    end;
{
*   Functions and subroutines.
}
procedure hier_read_block_start (      {start reading one subordinate level down}
  in out  rd: hier_read_t);            {hierarchy reading state}
  val_param; extern;

procedure hier_read_bool (             {read next token as floating point}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     tf: boolean;                 {returne value}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure hier_read_close (            {end hierarchy reading, close the file}
  in out  rd: hier_read_t;             {hierarchy reading state, returned invalid}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function hier_read_eol (               {check for at end of current input line}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t)             {extra token error if not end of line}
  :boolean;                            {at end of line, no error}
  val_param; extern;

procedure hier_read_fp (               {read next token as floating point}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     fp: real;                    {returned value}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure hier_read_int (              {read next token as integer}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     ii: sys_int_machine_t;       {returned value}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function hier_read_line (              {read next line from input file}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t)             {completion status}
  :boolean;                            {at same nesting level, no error}
  val_param; extern;

function hier_read_line_next (         {read next line at current or higher level}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t)             {completion status}
  :boolean;                            {at same nesting level, no error}
  val_param; extern;

procedure hier_read_open (             {open file for reading hierarchy}
  in      fnam: univ string_var_arg_t; {file name}
  in      suff: string;                {list of allowed suffixes}
  out     rd: hier_read_t;             {returned hierarchy reading state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

function hier_read_tk (                {read next token from input line}
  in out  rd: hier_read_t;             {input file reading state}
  in out  tk: univ string_var_arg_t)   {the returned token, empty str on EOL}
  :boolean;                            {token found}
  val_param; extern;

procedure hier_write_blankline (       {write blank line unless at start of file}
  in out  wr: hier_write_t;            {output file writing state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure hier_write_block_end (       {end the current subordinate block}
  in out  wr: hier_write_t);           {output file writing state}
  val_param; extern;

procedure hier_write_block_start (     {start a new subordinate block}
  in out  wr: hier_write_t);           {output file writing state}
  val_param; extern;

procedure hier_write_file_close (      {end writing hierarchy to file, close file}
  in out  wr: hier_write_t;            {file writing state, returned invalid}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure hier_write_file_open (       {open file for writing hierarchy}
  in      fnam: univ string_var_arg_t; {file name}
  in      suff: string;                {list of allowed suffixes}
  out     wr: hier_write_t;            {returned file writing state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure hier_write_fpf (             {write FP token, N fraction digits}
  in out  wr: hier_write_t;            {output file writing state}
  in      fp: real;                    {the floating point value to write}
  in      fdig: sys_int_machine_t);    {number of fraction digits}
  val_param; extern;

procedure hier_write_fps (             {write FP token, N significant digits}
  in out  wr: hier_write_t;            {output file writing state}
  in      fp: real;                    {the floating point value to write}
  in      sig: sys_int_machine_t);     {number of significant digits to write}
  val_param; extern;

procedure hier_write_int (             {write integer token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      ii: sys_int_machine_t);      {the integer value to write}
  val_param; extern;

procedure hier_write_line (            {write curr line to output file, reset line}
  in out  wr: hier_write_t;            {output file writing state}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure hier_write_onoff (           {write ON or OFF token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      b: boolean);                 {the value to write}
  val_param; extern;

procedure hier_write_str (             {write Pascal string to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      str: string);                {the string to write}
  val_param; extern;

procedure hier_write_tk (              {write Pascal token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      tk: string);                 {the string to write as a single token}
  val_param; extern;

procedure hier_write_vstr (            {write var string to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      vstr: univ string_var_arg_t); {the string to write}
  val_param; extern;

procedure hier_write_vtk (             {write var string token to output line}
  in out  wr: hier_write_t;            {output file writing state}
  in      vtk: univ string_var_arg_t); {the string to write as a single token}
  val_param; extern;


