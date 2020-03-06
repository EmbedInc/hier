{   Routines for setting the completion status according to various error
*   conditions.
}
module hier_err;
define hier_err_line_file;
define hier_err_missing;
define hier_err_badcmd;
%include 'hier2.ins.pas';
{
********************************************************************************
*
*   Subroutine HIER_ERR_LINE_FILE (RD, STAT)
*
*   Add the line number and file name as the next two parameters to STAT.  STAT
*   must already be set to a specific error code.
}
procedure hier_err_line_file (         {add line number and file name to STAT}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t);            {added: line number, file name}
  val_param;

begin
  sys_stat_parm_int (rd.conn.lnum, stat); {add line number}
  sys_stat_parm_vstr (rd.conn.tnam, stat); {add file name}
  end;
{
********************************************************************************
*
*   Subroutine HIER_ERR_MISSING (RD, STAT)
*
*   Set STAT to indicate missing parameter on the current line.
}
procedure hier_err_missing (           {set STAT for missing parameter at curr line}
  in out  rd: hier_read_t;             {hierarchy reading state}
  out     stat: sys_err_t);
  val_param;

begin
  sys_stat_set (hier_subsys_k, hier_stat_noparm_k, stat); {missing parameter}
  hier_err_line_file (rd, stat);       {add line number and file name}
  end;
{
********************************************************************************
*
*   Subroutine HIER_ERR_BADCMD (RD, CMD, STAT)
*
*   Set STAT to indicate the invalid command CMD was encountered on the current
*   line.
}
procedure hier_err_badcmd (            {set STAT for bad command on curr line}
  in out  rd: hier_read_t;             {hierarchy reading state}
  in      cmd: univ string_var_arg_t;  {command name}
  out     stat: sys_err_t);            {added: line number, file name}
  val_param;

begin
  sys_stat_set (hier_subsys_k, hier_stat_badcmd_k, stat); {bad command}
  sys_stat_parm_vstr (cmd, stat);      {command name}
  hier_err_line_file (rd, stat);       {add line number and file name}
  end;
