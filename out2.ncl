load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  ;a = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d03_2000-02-01_06:00:00","r")
  ;aout = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d02_2000-02-01_06:00:00","r")

  nn = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518"/)

  din = dimsizes(nn)

 do in = 19, din-1, 1 

  print(in)
    
  ;tb = at[:]->th
  ;printVarSummary(tb)
  ;z = az[:]->z
  ;printVarSummary(z)
  
  at = addfile("sim_lev100/theta/theta0"+nn(in)+".nc", "r")
  az = addfile("sim_lev100/height/z0"+nn(in)+".nc", "r")
  
  outfilet = addfile("sim_lev100/envi0"+nn(in)+".nc","r")
  t_avg = outfilet->te  

  printVarSummary(t_avg)

  tb = at->th
  ;printVarSummary(tb_out)
  z = az->z
  ;printVarSummary(z_out)

    ;p1     = wrf_user_getvar(f,"p",-1)
    ;t1     = wrf_user_getvar(f,"tk",-1)  ;

    ;times = wrf_user_getvar(a, "times", -1) ; get all time values on file
    ;p     = wrf_user_getvar(a,"p",-1)  ; calculate pressure across all time, levels
    ;t     = wrf_user_getvar(a,"tk",-1) ;
    ;hz     = wrf_user_getvar(f,"z",1)  ;
    
  ;tb = at[:]->th
  ;printVarSummary(tb)
  ;z = az[:]->z
  ;printVarSummary(z)

  ;tb = wrf_user_getvar(a, "th", it)
  ;z = wrf_user_getvar(a, "z", it)
  ;tb_out   = wrf_user_getvar(aout, "th", it)
  ;z_out   = wrf_user_getvar(aout, "z", it)
;
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  
  ndims = dimsizes(tb)
  ntimes = ndims(0)          ; number of times in the file
  nx = 420
  ny = 420

  nxo = 240
  nyo = 240
 
 
  mdims = new((/ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    lat = ispan( 0, 838, 2)      ;;;grid = 420
    lon = ispan( 0, 838, 2)      ;;;domain = 840 km

    latout = ispan( 0, 1434, 6)  ;;; grid = 240 
    lonout = ispan( 0, 1434, 6)  ;;; domain 1440 km
    
    nx = dimsizes(lat)
    nxo = dimsizes(latout)
    ;print(nxo)

    lat@units = "km"
    lon@units=  "km"
    latout@units = "km"
    lonout@units=  "km"
  
  imin = 209
  jmin = 209

  imin0 = 120
  jmin0 = 120

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200
  r = fspan(0.0,400.0,nr)
  ro = fspan(0.0, 700, nr)
  ;print(r)
  r@units = "km"
  ro@units = "km"
  
  nz = 100  ; Sigma levels
  hei = fspan(500, 27500, 100)
  ;print(hei)

  degtorad = 2*3.14159/360.0
  radtodeg = 180.0/3.14159
  alfa = fspan(0.0,359.0,360)
  alfa = alfa*degtorad

  dx = new((/nr,360/),"float")
  dy = new((/nr,360/),"float")
  dxo = dx
  dyo = dy

 do i = 0,nr-1,1
    do j = 0,359,1
         dx(i,j)= r(i)*cos(alfa(j))
         dy(i,j)= r(i)*sin(alfa(j))
         dxo(i,j)= ro(i)*cos(alfa(j))
         dyo(i,j)= ro(i)*sin(alfa(j))
    end do
end do

;------------------- calculate the lat/lon of the pole coordinate ---------------

  lat_p = new(nr*360,"float")
  lon_p = new(nr*360,"float")
  lat_po = lat_p
  lon_po = lon_p

  do i = 0, nr-1, 1
    do j = 0, 359, 1

      lat_p(i*360+j) = lat(imin) + dx(i,j)
      lon_p(i*360+j) = lon(jmin) + dy(i,j)
      lat_po(i*360+j) = latout(imin0) + dxo(i,j)
      lon_po(i*360+j) = lonout(jmin0) + dyo(i,j)

    end do
  end do
;;-----------------------------------------------------------------------
 
 t_ano    = new((/ntimes,nz,nr/),"float")
 print(ntimes)

  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + it )
;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;


    t = new((/nz,nx,ny/),"float")

    do iz = 0, nz-1

      t(iz,:,:)       = wrf_interp_3d_z(tb(it,:,:,:), z(it,:,:,:), hei(iz))
      ;t_out(iz,:,:)   = wrf_interp_3d_z(tb_out(it,:,:,:), z_out(it,:,:,:), hei(iz))

    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 tp     = new((/nz,nr*360/),"float")
 ;tp_out = new((/nz,nr*360/),"float")

 t_pave   = new((/nz,nr/),"float")
 ;t_poave  = new((/nz,nr/),"float")

 t_p      = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
 ;t_pout   = linint2_points(latout,lonout,t_out,False,lat_po,lon_po,1)

do lev = 0,nz-1
  do i = 0,nr-1
      sum_te = 0.0
      ;sum_tout = 0.0

      do j = 0,359,1
        
         sum_te    = sum_te    + t_p(lev,i*360+j)
         ;sum_tout  = sum_tout  + t_pout(lev,i*360+j)

      end do

      t_pave(lev,i)= sum_te/360.0
      ;t_poave(lev,i)= sum_tout/360.0

    end do
end do


do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(it,lev,i) = t_pave(lev,i)-t_avg(it,lev)
   
    end do
end do

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 t_ano!0 = "time"
 t_ano!1 = "height"
 t_ano!2 = "Radial"
 t_ano@long_name = "temperature anomaly"
 t_ano@units = "K"
 t_ano@_FillValue = 9.96921e+36

 ;t_avg!0 = "time"
 ;t_avg!1 = "height"
 ;t_avg@long_name = "temperature anomaly"
 ;t_avg@units = "K"
 ;t_avg@_FillValue = 9.96921e+36

  outfilet = addfile("sim_lev100/tha/tano"+nn(in)+".nc","c")
  outfilet->ta = t_ano

  delete(outfilet)
  delete(at)
  delete(az)
  
  delete(tb)
  delete(z)

end do



end