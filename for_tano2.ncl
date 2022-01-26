load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
external CAL "/user_home/jyyin/dta/radheight_fix.so"                

begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  nn = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518"/)

  din = dimsizes(nn)

do in = 10, din-1, 1 

  at = addfile("sim_lev100/theta/theta0"+nn(in)+".nc", "r")
  az = addfile("sim_lev100/height/z0"+nn(in)+".nc", "r")
  
  outfilet = addfile("sim_lev100/ev/envi0"+nn(in)+".nc","r")
  t_avg = outfilet->te  

  printVarSummary(t_avg)

  tb = at->th
  ;printVarSummary(tb_out)
  z = az->z
  ;printVarSummary(z_out)

  print(in)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  rms = dimsizes(tb)
  ntimes = rms(0)          ; number of times in the file

  nx = rms(2)
  ny = rms(3)
 
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
  print(r)
  r@units = "km"

;;-----------------------------------------------------------------------
 
 t_ano    = new((/ntimes,nz,nr/),"float")

  do it = 0 , ntimes-1 , 6; TIME LOOP
   
    print("Working on time: " + it )

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 100)
    print(hei)
    t       = new((/nz,nx,ny/), "float")

    do iz = 0, nz-1

      t(iz,:,:)       = wrf_interp_3d_z(tb(it,:,:,:), z(it,:,:,:), hei(iz))

    end do

    t!0 = "lev"
    t!1 = "ns"
    t!2 = "ew"

    t := t(ns|:,ew|:,lev|:)

    t_pave = new((/nr,nz/),"float")

    CAL::radheight(nz, nr, imin, jmin, t, nx, ny, t_pave)
    
    printVarSummary(t_pave)
    print(t_pave(40,:))

    t_pave!0 = "rad"
    t_pave!1 = "lev"

    t_pave := t_pave(lev|:,rad|:)

do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(it,lev,i) = t_pave(lev,i)-t_avg(it,lev)
   
    end do
end do

delete(t)
delete(t_pave)

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 t_ano!0 = "time"
 t_ano!1 = "height"
 t_ano!2 = "Radial"
 t_ano@long_name = "temperature anomaly"
 t_ano@units = "K"
 t_ano@_FillValue = 9.96921e+36

outfilet = addfile("sim_lev100/tha/for_tano"+nn(in)+".nc","c")
outfilet->ta = t_ano(0,0:90,:)

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/test_for"+nn(in)) 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

    res  = True
    res@cnFillOn            = True
    res@cnLinesOn           = False
    ;res@cnLineLabelsOn      = False
    res@lbLabelBarOn        = True
    ;print(t_pave(0,40,:))
    plot = gsn_contour(wks, t_ano(0,0:65,:), res)
    ;plot = gsn_contour(wks, t_pave(0:41,:), res)

    delete(t_ano)
    delete(t_avg)
    delete(at)
    delete(az)

end do

end