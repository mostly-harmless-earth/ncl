load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
external CAL "/user_home/jyyin/dta/radheight_fix.so"                

begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  nn1 = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18","6_00","6_06","6_12","6_18"/)


  nn = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518","6_00","6_06","6_12","6_18"/)

  din = dimsizes(nn)

  wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/test_for_d5") 

do in = 0, din-1, 1 

  au = addfile("sim_lev100/wind/u_0"+nn1(in)+".nc", "r")
  av = addfile("sim_lev100/wind/v_0"+nn1(in)+".nc", "r")
  aw = addfile("sim_lev100/wind/w_0"+nn1(in)+".nc", "r")

  az = addfile("sim_lev100/height/z0"+nn(in)+".nc", "r")
  
  u = au->ua
  v = av->va
  w = aw->wa
  printVarSummary(ua)
  
  z = az->z
  ;printVarSummary(z_out)

  print(in)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  rms = dimsizes(tb)
  ntimes = rms(0)          ; number of times in the file

  nx = 420
  ny = 420
 
  mdims = new((/ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

  imin = 210
  jmin = 210

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200  ;;; 200 * 2 = 400 Km
  nz = 100   ; Sigma levels
  r = fspan(0.0,400.0,nr)
  ;print(r)
  r@units = "km"
  ;ro@units = "km"

;;-----------------------------------------------------------------------
  
  hei = fspan(100, 27500, 100)
  
  rai_ave  = new((/ntimes,nz,nr/),"float")
  tan_ave  = new((/ntimes,nz,nr/),"float")
  w_ave = new((/ntimes,nz,nr/),"float")

  do it = 0 , ntimes-1 , 6; TIME LOOP
   
    print("Working on time: " + it )

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    
    ;print(hei)
    uu = new((/nz,nx,ny/), float)
    vv = uu
    ww = uu

    do iz = 0, nz-1

      uu(iz,:,:) = wrf_interp_3d_z(u(it,:,:,:), z(it,:,:,:), hei(iz))
      vv(iz,:,:) = wrf_interp_3d_z(v(it,:,:,:), z(it,:,:,:), hei(iz))
      ww(iz,:,:) = wrf_interp_3d_z(w(it,:,:,:), z(it,:,:,:), hei(iz))

    end do

    t_pave = new((/nr,nz/),"float")

    t!0 = "lev"
    t!1 = "ns"
    t!2 = "ew"

    t := t(ns|:,ew|:,lev|:)

    

    CAL::radheight(nz, nr, imin, jmin, t, nx, ny, t_pave)
    
    ;printVarSummary(t_pave)
    print(t_pave(40,:))

    t_pave!0 = "rad"
    t_pave!1 = "lev"

    t_pave := t_pave(lev|:,rad|:)

do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(it,lev,i) = t_pave(lev,i)-t_avg(it,lev)
   
    end do
end do

    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

    res  = True
    res@cnFillOn            = True
    res@cnLinesOn           = False
    ;res@cnLineLabelsOn      = False
    res@lbLabelBarOn        = True
    ;print(t_pave(0,40,:))
    plot = gsn_contour(wks, t_ano(0,2:62,:), res)
    plot = gsn_contour(wks, t_pave(2:62,0:99), res)

    outfilet = addfile("sim_lev100/base0"+nn(in)+".nc","c")
    outfilet->te = t_pave

    outfilet = addfile("sim_lev100/ano0"+nn(in)+".nc","c")
    outfilet->ta = t_ano(:,2:62,:)


delete(t)
delete(t_pave)
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
delete(at)
delete(az)
delete(z)
delete(tb)

end do

end