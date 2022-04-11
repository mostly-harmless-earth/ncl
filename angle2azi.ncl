load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

   files = systemfunc("ls ./sim_lev100/bud/ang_adv_h_*")
   a = addfiles(files, "r")
   ListSetType(a, "cat")
   radial360 = a[:]->t_adv_h
   radial = dim_avg_n(radial360,3)
    delete(a)
   delete(radial360)
 outfilet = addfile("sim_lev100/bud/adv_h_azi.nc","c")
 outfilet->t_adv_h = radial

    files = systemfunc("ls ./sim_lev100/bud/ang_adv_v_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")
    radial360 = a[:]->t_adv_v
    radial = dim_avg_n(radial360,3)
     delete(a)
     delete(radial360)
 outfilet = addfile("sim_lev100/bud/adv_v_azi.nc","c")
 outfilet->t_adv_v = radial

    files = systemfunc("ls ./sim_lev100/bud/ang_diff_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")
    radial360 = a[:]->t_diff
    radial = dim_avg_n(radial360,3)
     delete(a)
     delete(radial360)
 outfilet = addfile("sim_lev100/bud/diff_azi.nc","c")
 outfilet->t_diff = radial

    files = systemfunc("ls ./sim_lev100/bud/ang_diff3_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")
    radial360 = a[:]->t_diff
    radial = dim_avg_n(radial360,3)
     delete(a)
     delete(radial360)
 outfilet = addfile("sim_lev100/bud/diff3_azi.nc","c")
 outfilet->t_diff = radial

    files = systemfunc("ls ./sim_lev100/bud/ang_pbl_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")
    radial360 = a[:]->t_pbl
    radial = dim_avg_n(radial360,3)
     delete(a)
     delete(radial360)
 outfilet = addfile("sim_lev100/bud/pbl_azi.nc","c")
 outfilet->t_pbl = radial

    files = systemfunc("ls ./sim_lev100/bud/ang_heat_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")
    radial360 = a[:]->t_heat
    radial = dim_avg_n(radial360,3)
      delete(a)
     delete(radial360)
 outfilet = addfile("sim_lev100/bud/heat_azi.nc","c")
 outfilet->t_heat = radial

    ;files = systemfunc("ls ./sim_lev100/t_wind_perh/tangential_wind*")
   ;b = addfiles(files, "r")
   ;ListSetType(b, "cat")
   
   ;tangential360 = b[:]->wtan
   ;tangential = dim_avg_n(tangential360,3)

   ;delete(b)
   ;delete(tangential360)

;outfilet = addfile("sim_lev100/t_wind_perh/vt_azi.nc","c")
;outfilet->wtan = tangential

   ;;files = systemfunc("ls ./sim_lev100/t_wind_perh/radial_wind*")
   ;b = addfiles(files, "r")
   ;ListSetType(b, "cat")
   
   ;radial360 = b[:]->wrad
   ;radial = dim_avg_n(radial360,3)

   ;delete(b)
   ;delete(radial360)

;outfilet = addfile("sim_lev100/t_wind_perh/vr_azi.nc","c")
;outfilet->wrad = radial

   ;files1 = systemfunc("ls ./sim_lev100/t_wind_perh/vertical_wind*")
   ;c = addfiles(files1, "r")
   ;ListSetType(c, "cat")

   ;wwnd360 = c[:]->ww
   ;wwnd = dim_avg_n(wwnd360,3)

   ;delete(c)
   ;delete(wwnd360)

;outfilet = addfile("sim_lev100/t_wind_perh/azi_vertical.nc","c")
;outfilet->ww = wwnd

    ;d = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    ;t_d01 = d->th

    ;printVarSummary(t_d01)

    ;files = systemfunc("ls ./sim_lev100/t_wind_perh/cirtano*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ;t_ano_for1 = ano_h[:]->ta
    ;t_ano_for = dim_avg_n(t_ano_for1,3)
    ;printVarSummary(t_ano_for1)

   ;t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    ;printVarSummary(t_ev)

    ;do lev = 0, 90
      ;do i = 0, 199

        ;t_ano_for(:,lev,i) = t_ano_for(:,lev,i)-t_ev(0,lev)
   
      ;end do
    ;end do

   ;dim = dimsizes(t_ano_for)

;outfilet = addfile("sim_lev100/t_wind_perh/d7_t0_ta.nc","c")
;outfilet->ta = t_ano_for

end