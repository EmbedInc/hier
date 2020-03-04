module hier_write_file;
define hier_write_file_open;
define hier_write_file_close;
%include 'hier2.ins.pas';
{
********************************************************************************
*
*   Subroutine HIER_WRITE_FILE_OPEN (FNAM, SUFF, WR, STAT)
*
*   Open a file for writing a hierarchy to it.  FNAM is the file name, and SUFF
*   the list of allowed file name suffixes.  WR is the returned writing state.
}
procedure hier_write_file_open (       {open file for writing hierarchy}
  in      fnam: univ string_var_arg_t; {file name}
  in      suff: string;                {list of allowed suffixes}
  out     wr: hier_write_t;            {returned file writing state}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  file_open_write_text (               {open the file}
    fnam, suff,                        {file name}
    wr.conn,                           {returned connection to the file}
    stat);
  if sys_error(stat) then return;

  wr.buf.max := size_char(wr.buf.str); {init rest of writing state}
  wr.buf.len := 0;
  wr.lev := 0;
  end;
{
********************************************************************************
*
*   Subroutine HIER_WRITE_FILE_CLOSE (WR, STAT)
*
*   End writing hierarchy data to a file and close the file.  WR is the file
*   writing state, and is returned invalid.
}
procedure hier_write_file_close (      {end writing hierarchy to file, close file}
  in out  wr: hier_write_t;            {file writing state, returned invalid}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  sys_error_none (stat);               {init to no error encountered}
  file_close (wr.conn);                {close the file}
  wr.buf.len := 0;                     {reset other state}
  wr.lev := 0;
  end;
