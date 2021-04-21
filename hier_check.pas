{   Check for particular error conditions.
}
module hier_check;
define hier_check_noparm;
%include 'hier2.ins.pas';
{
********************************************************************************
*
*   Function HIER_CHECK_NOPARM (STAT)
*
*   The function returns true iff STAT indicates that an attempt was made to
*   read a parameter or token, but it was not found.  If so, STAT is cleard of
*   the error.
}
function hier_check_noparm (           {check for "no parameter" error}
  in out  stat: sys_err_t)             {status to check, cleared on "no parameter"}
  :boolean;                            {TRUE = STAT indicated "no parm" error}
  val_param;

begin
  hier_check_noparm := sys_stat_match (
    hier_subsys_k, hier_stat_noparm_k, stat);
  end;
