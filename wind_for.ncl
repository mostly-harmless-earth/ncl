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

do in = 0, din-1, 1

    outfilet = addfile("sim_lev100/wind/u_0"+nn(in)+".nc","r")
    ub = outfilet->ua

    outfilet = addfile("sim_lev100/wind/v_0"+nn(in)+".nc","r")
    vb = outfilet->va
    
    outfilet = addfile("sim_lev100/wind/w_0"+nn(in)+".nc","r")
    wb = outfilet->wa

    az = addfile("sim_lev100/height/z0"+nn1(in)+".nc", "r")
    z = az->z

  print(in)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  rms = dimsizes(ub)
  ntimes = rms(0)          ; number of times in the file

  nx = rms(2)
  ny = rms(3)
 
  mdims = new((/ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  printVarSummary(ub)
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
 
 ua  = new((/ntimes,nz,nr/),"float")
 
 va = ua
 wa = ua
  
  do it = 0 , ntimes-1 , 6; TIME LOOP
   
    print("Working on time: " + it )

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 100)
    ;print(hei)

    uu = new((/nz,nx,ny/), "float")
    vv = uu
    ww = uu

    do iz = 0, nz-1

      uu(iz,:,:) = wrf_interp_3d_z(ub(it,:,:,:), z(it,:,:,:), hei(iz))
      vv(iz,:,:) = wrf_interp_3d_z(vb(it,:,:,:), z(it,:,:,:), hei(iz)) 
      ww(iz,:,:) = wrf_interp_3d_z(wb(it,:,:,:), z(it,:,:,:), hei(iz)) 
    
    end do

    uu!0 = "lev"
    uu!1 = "ns"
    uu!2 = "ew"

    copy_VarMeta(uu, vv)
    copy_VarMeta(uu, ww)

    uu := uu(ns|:,ew|:,lev|:)
    vv := vv(ns|:,ew|:,lev|:)
    ww := ww(ns|:,ew|:,lev|:)

     up    = new((/nr,nz/),"float")
 
     vp = up
     wp = up

    CAL::radheight(nz, nr, imin, jmin, uu, nx, ny, up)
    CAL::radheight(nz, nr, imin, jmin, vv, nx, ny, vp)
    CAL::radheight(nz, nr, imin, jmin, ww, nx, ny, wp)

    up!0 = "rad"
    up!1 = "lev"

    copy_VarMeta(up, vp)
    copy_VarMeta(up, wp)

    up := up(lev|:,rad|:)
    vp := vp(lev|:,rad|:)
    wp := wp(lev|:,rad|:)

    ua(it,:,:) = up
    va(it,:,:) = vp
    wa(it,:,:) = wp


delete(up)
delete(vp)
delete(wp)

delete(uu)
delete(vv)

delete(ww)

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 ua!0 = "time"
 ua!1 = "height"
 ua!2 = "Radial"
 ua@long_name = "u wind component"
 ua@units = "K/s"
 ua@_FillValue = 9.96921e+36

 va!0 = "time"
 va!1 = "height"
 va!2 = "Radial"
 va@long_name = "v wind component"
 va@units = "K/s"
 va@_FillValue = 9.96921e+36


 wa!0 = "time"
 wa!1 = "height"
 wa!2 = "Radial"
 wa@long_name = "w wind component"
 wa@units = "K"
 wa@_FillValue = 9.96921e+36
 

outfilet = addfile("sim_lev100/wind/for_u_0"+nn(in)+".nc","c")
outfilet->uu = ua(:,0:90,:)

outfilet = addfile("sim_lev100/wind/for_v_0"+nn(in)+".nc","c")
outfilet->vv = va(:,0:90,:)

outfilet = addfile("sim_lev100/wind/for_w_0"+nn(in)+".nc","c")
outfilet->ww = wa(:,0:90,:)

end do


delete(ua)
delete(va)
delete(wa)

delete(outfilet)
delete(az)

end