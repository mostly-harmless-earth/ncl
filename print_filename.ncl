load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

    files = systemfunc("ls ./WRF_output/wrfout_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")

    t = wrf_user_getvar(a, "times", -1)
    printVarSummary(t)

    do i = 0,621,1
        print("wrfout_d02_" + t(i))
    end do 
 
end

