load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

   files = systemfunc("ls ./sim_lev100/bud/azi_adv_v_*")
   a = addfiles(files, "r")
   ListSetType(a, "cat")
   radial360 = a[:]->t_adv_v
   radial = dim_avg_n(radial360,3)

    delete(a)
    delete(radial360)

outfilet = addfile("sim_lev100/bud/adv_v_azi.nc","c")
outfilet->t_adv_v = radial

   ;files = systemfunc("ls ./sim_lev100/angle/tangential_wind*")
   ;b = addfiles(files, "r")
   ;ListSetType(b, "cat")
   
   ;tangential360 = b[:]->wtan
   ;tangential = dim_avg_n(tangential360,3)

   ;delete(b)
   ;delete(tangential360)

;outfilet = addfile("sim_lev100/angle/vt_azi.nc","c")
;outfilet->wtan = tangential

   ;files1 = systemfunc("ls ./sim_lev100/angle/vertical_wind*")
   ;c = addfiles(files1, "r")
   ;ListSetType(c, "cat")

   ;wwnd360 = c[:]->ww
   ;wwnd = dim_avg_n(wwnd360,3)

   ;delete(c)
   ;delete(wwnd360)

;outfilet = addfile("sim_lev100/angle/azi_vertical.nc","c")
;outfilet->ww = wwnd

    ;d = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    ;t_d01 = d->th

    ;printVarSummary(t_d01)

    ;files = systemfunc("ls ./sim_lev100/angle/cirtano*")
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

;outfilet = addfile("sim_lev100/angle/d7_t0_ta.nc","c")
;outfilet->ta = t_ano_for

end