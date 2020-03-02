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
