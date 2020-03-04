module hier_read_file;
define hier_read_open;
define hier_read_close;
%include 'hier2.ins.pas';
{
********************************************************************************
*
*   Local subroutine RD_RESET (RD)
*
*   Reset the fields of RD except for CONN to initial or default values.
}
procedure rd_reset (                   {reset reading state to init or default}
  in out  rd: hier_read_t);            {all fields reset except CONN}
  val_param; internal;

begin
  rd.level := 0;
  rd.llev := 0;
  rd.buf.max := size_char(rd.buf.str);
  rd.buf.len := 0;
  rd.p := 1;
  rd.lret := true;
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_OPEN (FNAM, SUFF, RD, STAT)
*
*   Open a file for reading hierarchy information from it.  FNAM is the file
*   name and SUFF the list of allowable file name suffixes.  RD is the returned
*   reading state.
}
procedure hier_read_open (             {open file for reading hierarchy}
  in      fnam: univ string_var_arg_t; {file name}
  in      suff: string;                {list of allowed suffixes}
  out     rd: hier_read_t;             {returned hierarchy reading state}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  file_open_read_text (                {open the file}
    fnam, suff,                        {file name and allowed suffixes}
    rd.conn,                           {returned connection to the file}
    stat);
  if sys_error(stat) then return;

  rd_reset (rd);                       {init rest of hierarchy reading state}
  end;
{
********************************************************************************
*
*   Subroutine HIER_READ_CLOSE (RD, STAT)
*
*   End reading hierarchy data from a file and close the file.  RD is the
*   hierarchy reading state, which is returned invalid.
}
procedure hier_read_close (            {end hierarchy reading, close the file}
  in out  rd: hier_read_t;             {hierarchy reading state, returned invalid}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  sys_error_none (stat);               {init to no error encountered}
  if rd.llev >= 0 then begin           {file not already closed ?}
    file_close (rd.conn);              {close the file}
    end;
  rd_reset (rd);                       {reset the remaining fields of RD}
  rd.llev := -1;
  end;
