{   Public include file for the HIER library.
*
*   This library manipulates hierarchical data, particularly writing/reading
*   hierarchical data to/from files.
}
const
  hier_subsys_k = -69;                 {HIER library subsyste ID}

type
  hier_write_p_t = ^hier_write_t;
  hier_write_t = record                {state for writing hierarchy to a file}
    conn: file_conn_t;                 {connection to the file}
    buf: string_var8192_t;             {one line output buffer}
    lev: sys_int_machine_t;            {nesting level, 0 at top}
    end;
{
*   Functions and subroutines.
}
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


