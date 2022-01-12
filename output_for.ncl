load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
external CAL "/user_home/jyyin/dta/radheight_fix.so"     

begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim9_v3/wrfout_d02_2000-09-03_12:00:00","r")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
  nx = 240
  ny = 240
 
  mdims = new((/480,ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

  imin = 120
  jmin = 120

  imin0 = 80
  jmin0 = 80

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 150
  nz = 68  ; Sigma levels

;;-----------------------------------------------------------------------
 
 ta_adv_v = new((/nr,nz/),"float")
 ta_adv_h = new((/ntimes,nz,nr/),"float")

 ta_diff  = new((/ntimes,nz,nr/),"float")
 ta_heat  = new((/ntimes,nz,nr/),"float")
 ta_pbl   = new((/ntimes,nz,nr/),"float")
 ta_cu   = new((/ntimes,nz,nr/),"float")
 ta_ra   = new((/ntimes,nz,nr/),"float")

  do it = 1 , 2 , 1; TIME LOOP
   
    print("Working on time: " + it )

    z = wrf_user_getvar(a, "z", it)

    mu = wrf_user_getvar(a, "MU", it)
    mub = wrf_user_getvar(a, "MUB", it)
    
    tb_adv_h = wrf_user_getvar(a, "T_TEND_ADV_H", it)
    tb_adv_v = wrf_user_getvar(a, "T_TEND_ADV_V", it)

    tb_diff  = wrf_user_getvar(a, "T_TEND_DIFF", it)
    tb_cu    = wrf_user_getvar(a, "RTHCUTEN", it)
    tb_ra    = wrf_user_getvar(a, "RTHRATEN", it)
    tb_pbl   = wrf_user_getvar(a, "RTHBLTEN", it)
    tb_heat  = wrf_user_getvar(a, "H_DIABATIC", it)

    mut = mu+mub

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 68)

    t_adv_h = tb_adv_h
    t_adv_v = tb_adv_v

    t_diff  = tb_diff
    t_heat  = tb_heat
    t_cu    = tb_cu
    t_ra    = tb_ra
    t_pbl   = tb_pbl
    ;t_shcu    = tb_shcu
    
    do iz = 0, nz-1

      t_adv_v(iz,:,:) = wrf_interp_3d_z(tb_adv_v, z, hei(iz))/mut(:,:)
      t_adv_h(iz,:,:) = wrf_interp_3d_z(tb_adv_h, z, hei(iz))/mut(:,:)
      ;t_adv(iz,:,:)  = wrf_interp_3d_z(tb_adv, z, hei(iz))

      t_diff(iz,:,:)  = wrf_interp_3d_z(tb_diff, z, hei(iz))/mut(:,:)
      t_heat(iz,:,:)  = wrf_interp_3d_z(tb_heat, z, hei(iz))
      t_pbl(iz,:,:)   = wrf_interp_3d_z(tb_pbl, z, hei(iz))/mut(:,:)
      t_cu(iz,:,:)    = wrf_interp_3d_z(tb_cu, z, hei(iz))/mut(:,:)
      t_ra(iz,:,:)    = wrf_interp_3d_z(tb_ra, z, hei(iz))/mut(:,:)
      ;t_shcu(iz,:,:)    = wrf_interp_3d_z(tb_shcu, z, hei(iz))

    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 t_adv_v!0 = "lev"
 t_adv_v!1 = "ns"
 t_adv_v!2 = "ew"

 t_adv_v := t_adv_v(ns|:,ew|:,lev|:)

 CAL::radheight(nz, nr, imin,jmin, t_adv_v, nx, ny, ta_adv_v)
 printVarSummary(ta_adv_v)
 
end do

end