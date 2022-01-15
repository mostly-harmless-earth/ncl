load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
external CAL "/user_home/jyyin/dta/radheight_fix.so"   
external CAL "/user_home/jyyin/dta/outradheight_fix.so"              

begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d03_2000-02-01_06:00:00","r")
  aout = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d02_2000-02-01_06:00:00","r")
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file

  nx = 420
  ny = 420

  nxo = 240
  nyo = 240
 
  mdims = new((/ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

  imin = 210
  jmin = 210

  imin0 = 120
  jmin0 = 120

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 100  ;;; 100 * 6 = 600 Km
  nz = 100   ; Sigma levels
  r = fspan(0.0,500.0,nr)
  ro = fspan(0.0, 1400.0, nr)
  print(r)
  r@units = "km"
  ro@units = "km"

;;-----------------------------------------------------------------------
 
 t_ano    = new((/ntimes,nz,nr/),"float")

  do it = 0 , 0 , 1; TIME LOOP
   
    print("Working on time: " + it )

    tb = wrf_user_getvar(a, "th", it)
    z = wrf_user_getvar(a, "z", it)
    tb_out   = wrf_user_getvar(aout, "th", it)
    z_out   = wrf_user_getvar(aout, "z", it)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 100)
    print(hei)
    t       = tb
    t_out   = tb_out

    do iz = 0, nz-1

      t(iz,:,:)       = wrf_interp_3d_z(tb, z, hei(iz))
      t_out(iz,:,:)   = wrf_interp_3d_z(tb_out, z_out, hei(iz))

    end do

    t!0 = "lev"
    t!1 = "ns"
    t!2 = "ew"

    t_out!0 = "lev"
    t_out!1 = "ns"
    t_out!2 = "ew"

    t := t(ns|:,ew|:,lev|:)
    t_out := t_out(ns|:,ew|:,lev|:)

    t_pave = new((/nr,nz/),"float")
    t_poave = new((/nr,nz/),"float")

    CAL::radheight(nz, nr, imin, jmin, t, nx, ny, t_pave)
    CAL::radheight(nz, nr, imin0,jmin0,t_out, nxo, nyo, t_poave)
    
    printVarSummary(t_pave)
    print(t_pave(40,:))

    t_pave!0 = "rad"
    t_pave!1 = "lev"

    t_pave := t_pave(lev|:,rad|:)

    printVarSummary(t_pave)

    t_poave!0 = "rad"
    t_poave!1 = "lev"

    t_poave := t_poave(lev|:,rad|:)
    
 
t_temp = t_poave(:,:)
t_avg = dim_avg_n(t_temp, 1)
print(t_avg)

do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(it,lev,i) = t_poave(lev,i)-t_avg(lev)
   
    end do
end do


delete(t)
delete(t_out)
delete(t_pave)
delete(t_poave)

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 ;t_ano!0 = "time"
 ;t_ano!1 = "height"
 ;t_ano!2 = "Radial"
 ;t_ano@long_name = "temperature anomaly"
 ;t_ano@units = "K"
 ;t_ano@_FillValue = 9.96921e+36

;outfilet = addfile("sim_lev100/tha/tano_d5_12.nc","c")
;outfilet->ta = t_ano

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/test_for_d1") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

    res  = True
    res@cnFillOn            = True
    res@cnLinesOn           = False
    ;res@cnLineLabelsOn      = False
    res@lbLabelBarOn        = True
    ;print(t_pave(0,40,:))
    plot = gsn_contour(wks, t_ano(0,0:60,:), res)
    ;plot = gsn_contour(wks, t_pave(0:41,:), res)

end