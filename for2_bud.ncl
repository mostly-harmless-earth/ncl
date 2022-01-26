load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
external CAL "/user_home/jyyin/dta/radheight_fix.so"                

begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18"/)

  nn1 = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518"/)

  din = dimsizes(nn)

do in = 12, din-1, 1

    outfilet = addfile("sim_lev100/budget_or/adv_h_0"+nn(in)+".nc","r")
    tb_adv_h = outfilet->T_TEND_ADV_H

    outfilet = addfile("sim_lev100/budget_or/adv_v_0"+nn(in)+".nc","r")
    tb_adv_v = outfilet->T_TEND_ADV_V
    
    outfilet = addfile("sim_lev100/budget_or/diff_0"+nn(in)+".nc","r")
    tb_diff1 = outfilet->T_TEND_DIFF
    
    outfilet = addfile("sim_lev100/budget_or/diff3_0"+nn(in)+".nc","r")
    tb_diff3 = outfilet->T_TEND_DIFF3

    outfilet = addfile("sim_lev100/budget_or/pbl_0"+nn(in)+".nc","r")
    tb_pbl = outfilet->RTHBLTEN
    
    outfilet = addfile("sim_lev100/budget_or/heat_0"+nn(in)+".nc","r")
    tb_heat = outfilet->H_DIABATIC 

    outfilet = addfile("sim_lev100/budget_or/mut_0"+nn(in)+".nc","r")
    mut = outfilet->MUT

    az = addfile("sim_lev100/height/z0"+nn1(in)+".nc", "r")
    z = az->z

  print(in)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  rms = dimsizes(tb_heat)
  ntimes = rms(0)          ; number of times in the file

  nx = rms(2)
  ny = rms(3)
 
  mdims = new((/ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  printVarSummary(tb_heat)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

  imin = nx/2
  jmin = ny/2

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200  ;;; 200 * 2 = 400 Km
  nz = 100   ; Sigma levels
  r = fspan(0.0,400.0,nr)
  ;print(r)
  r@units = "km"

;;-----------------------------------------------------------------------
 
 ta_adv_h    = new((/ntimes,nz,nr/),"float")
 
 ta_adv_v = ta_adv_h
 ta_diff1  = ta_adv_h
 ta_diff3  = ta_adv_h
 ta_heat  = ta_adv_h
 ;ta_cu    = tt_adv_h
 ta_pbl   = ta_adv_h
 ;tt_ra    = tp_adv_h
  
  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + it )

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 100)
    ;print(hei)

    t_adv_h = new((/nz,nx,ny/), "float")
    t_adv_v = t_adv_h

    t_diff1  = t_adv_h
    t_diff3  = t_adv_h

    t_heat  = t_adv_h
    
    ;t_cu    = t_adv_h
    ;t_ra    = tb_adv_h
    
    t_pbl   = t_adv_h

    do iz = 0, nz-1

      t_adv_v(iz,:,:) = wrf_interp_3d_z(tb_adv_v(it,:,:,:), z(it,:,:,:), hei(iz))
      t_adv_h(iz,:,:) = wrf_interp_3d_z(tb_adv_h(it,:,:,:), z(it,:,:,:), hei(iz))
      t_diff1(iz,:,:)  = wrf_interp_3d_z(tb_diff1(it,:,:,:), z(it,:,:,:), hei(iz))
      t_diff3(iz,:,:)  = wrf_interp_3d_z(tb_diff3(it,:,:,:), z(it,:,:,:), hei(iz))

      t_heat(iz,:,:)  = wrf_interp_3d_z(tb_heat(it,:,:,:), z(it,:,:,:), hei(iz))
      t_pbl(iz,:,:)   = wrf_interp_3d_z(tb_pbl(it,:,:,:), z(it,:,:,:), hei(iz))
      ;t_cu(iz,:,:)    = wrf_interp_3d_z(tb_cu(it,:,:,:), z(it,:,:,:), hei(iz))
      ;t_ra(iz,:,:)    = wrf_interp_3d_z(tb_ra(it,:,:,:), z(it,:,:,:), hei(iz))/mut(:,:)

      t_adv_v(iz,:,:) = t_adv_v(iz,:,:)/mut(it,:,:)
      t_adv_h(iz,:,:) = t_adv_h(iz,:,:)/mut(it,:,:)
      t_diff1(iz,:,:) = t_diff1(iz,:,:)/mut(it,:,:)
      t_diff3(iz,:,:) = t_diff3(iz,:,:)/mut(it,:,:)
      t_pbl(iz,:,:) = t_pbl(iz,:,:)/mut(it,:,:)
      ;t_cu(iz,:,:)    = t_cu(it,:,:,:)/mut(it,:,:)
    
    end do

    t_adv_h!0 = "lev"
    t_adv_h!1 = "ns"
    t_adv_h!2 = "ew"

    copy_VarMeta(t_adv_h, t_adv_v)
    copy_VarMeta(t_adv_h, t_diff3)
    copy_VarMeta(t_adv_h, t_diff1)
    copy_VarMeta(t_adv_h, t_pbl)
    ;copy_VarMeta(t_adv_h, t_cu)
    copy_VarMeta(t_adv_h, t_heat)

    t_adv_h := t_adv_h(ns|:,ew|:,lev|:)
    t_adv_v := t_adv_v(ns|:,ew|:,lev|:)
    t_diff1 := t_diff1(ns|:,ew|:,lev|:)
    t_diff3 := t_diff3(ns|:,ew|:,lev|:)
    ;t_cu := t_cu(ns|:,ew|:,lev|:)
    t_pbl := t_pbl(ns|:,ew|:,lev|:)
    t_heat := t_heat(ns|:,ew|:,lev|:)

     tp_adv_h    = new((/nr,nz/),"float")
 
     tp_adv_v = tp_adv_h
     tp_diff1  = tp_adv_h
     tp_diff3  = tp_adv_h
     tp_heat  = tp_adv_h
     ;tp_cu    = tp_adv_h
     tp_pbl   = tp_adv_h
     ;tp_ra    = tp_adv_h

    CAL::radheight(nz, nr, imin, jmin, t_adv_v, nx, ny, tp_adv_v)
    CAL::radheight(nz, nr, imin, jmin, t_adv_h, nx, ny, tp_adv_h)

    ;CAL::radheight(nz, nr, imin, jmin, t_cu, nx, ny, tp_cu)
    CAL::radheight(nz, nr, imin, jmin, t_heat, nx, ny, tp_heat)
    CAL::radheight(nz, nr, imin, jmin, t_pbl, nx, ny, tp_pbl)

    CAL::radheight(nz, nr, imin, jmin, t_diff1, nx, ny, tp_diff1)
    CAL::radheight(nz, nr, imin, jmin, t_diff3, nx, ny, tp_diff3)

    tp_adv_h!0 = "rad"
    tp_adv_h!1 = "lev"

    copy_VarMeta(tp_adv_h, tp_adv_v)
    copy_VarMeta(tp_adv_h, tp_diff3)
    copy_VarMeta(tp_adv_h, tp_diff1)
    copy_VarMeta(tp_adv_h, tp_pbl)
    ;copy_VarMeta(tp_adv_h, tp_cu)
    copy_VarMeta(tp_adv_h, tp_heat)

    tp_adv_h := tp_adv_h(lev|:,rad|:)
    tp_adv_v := tp_adv_v(lev|:,rad|:)
    
    tp_diff1 := tp_diff1(lev|:,rad|:)
    tp_diff3 := tp_diff3(lev|:,rad|:)
    
    tp_pbl := tp_pbl(lev|:,rad|:)
    ;tp_cu := tp_cu(lev|:,rad|:)
    tp_heat := tp_heat(lev|:,rad|:)

    ta_adv_h(it,:,:) = tp_adv_h
    ta_adv_v(it,:,:) = tp_adv_v
    
    ta_diff1(it,:,:) = tp_diff1
    ta_diff3(it,:,:) = tp_diff3
    
    ;ta_cu(it,:,:) = tp_cu
    ta_heat(it,:,:) = tp_heat
    ta_pbl(it,:,:) = tp_pbl

delete(tp_adv_h)
delete(tp_adv_v)

delete(tp_diff3)
delete(tp_diff1)
;delete(tp_cu)
delete(tp_pbl)
delete(tp_heat)

delete(t_adv_h)
delete(t_adv_v)

delete(t_diff3)
delete(t_diff1)
;delete(tp_cu)
delete(t_pbl)
delete(t_heat)


end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 ta_adv_v!0 = "time"
 ta_adv_v!1 = "height"
 ta_adv_v!2 = "Radial"
 ta_adv_v@long_name = "vertical advection"
 ta_adv_v@units = "K/s"
 ta_adv_v@_FillValue = 9.96921e+36

 ta_adv_h!0 = "time"
 ta_adv_h!1 = "height"
 ta_adv_h!2 = "Radial"
 ta_adv_h@long_name = "Horizontal advection"
 ta_adv_h@units = "K/s"
 ta_adv_h@_FillValue = 9.96921e+36


 ta_diff1!0 = "time"
 ta_diff1!1 = "height"
 ta_diff1!2 = "Radial"
 ta_diff1@long_name = "diffusion"
 ta_diff1@units = "K"
 ta_diff1@_FillValue = 9.96921e+36
 
 
 ta_diff3!0 = "time"
 ta_diff3!1 = "height"
 ta_diff3!2 = "Radial"
 ta_diff3@long_name = "diffusion"
 ta_diff3@units = "K"
 ta_diff3@_FillValue = 9.96921e+36

 
 ta_heat!0 = "time"
 ta_heat!1 = "height"
 ta_heat!2 = "Radial"
 ta_heat@long_name = "Nondiabatic heating"
 ta_heat@units = "K"
 ta_heat@_FillValue = 9.96921e+36

 ta_pbl!0 = "time"
 ta_pbl!1 = "height"
 ta_pbl!2 = "Radial"
 ta_pbl@long_name = "pbl"
 ta_pbl@units = "K"
 ta_pbl@_FillValue = 9.96921e+36

 ;ta_cu!0 = "time"
 ;ta_cu!1 = "height"
 ;ta_cu!2 = "Radial"
 ;ta_cu@long_name = "cu"
 ;ta_cu@units = "K"
 ;ta_cu@_FillValue = 9.96921e+36


 ;ta_ra!0 = "time"
 ;ta_ra!1 = "height"
 ;ta_ra!2 = "Radial"
 ;ta_ra@long_name = "pbl"
 ;ta_ra@units = "K"
 ;ta_ra@_FillValue = 9.96921e+36

outfilet = addfile("sim_lev100/bud/for_adv_h_0"+nn(in)+".nc","c")
outfilet->t_adv_h = ta_adv_h

outfilet = addfile("sim_lev100/bud/for_adv_v_0"+nn(in)+".nc","c")
;outfilet = addfile("sim9/bud_d1_06/adv.nc","c")
outfilet->t_adv_v = ta_adv_v

outfilet = addfile("sim_lev100/bud/for_diff_0"+nn(in)+".nc","c")
outfilet->t_diff = ta_diff1

outfilet = addfile("sim_lev100/bud/for_diff3_0"+nn(in)+".nc","c")
outfilet->t_diff = ta_diff3

outfilet = addfile("sim_lev100/bud/for_heat_0"+nn(in)+".nc","c")
outfilet->t_heat = ta_heat

outfilet = addfile("sim_lev100/bud/for_pbl_0"+nn(in)+".nc","c")
outfilet->t_pbl = ta_pbl

;outfilet = addfile("sim_lev100/bud/for_pbl_0"+nn(in)+".nc","c")

end do


delete(ta_adv_h)
delete(ta_adv_v)
delete(ta_diff1)
delete(ta_diff3)
delete(ta_heat)
delete(ta_pbl)

delete(tb_adv_h)
delete(tb_adv_v)
delete(tb_diff1)
delete(tb_diff3)
delete(tb_heat)
delete(tb_pbl)

delete(outfilet)
delete(az)

end