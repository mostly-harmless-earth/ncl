load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim6_budget/wrfout_d02_2000-06-07_00:00:00","r")
 
  aout = addfile("/user_home/jyyin/dta/sim6_budget/wrfout_d01_2000-06-07_00:00:00","r")
         
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/480,68,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    lat = ispan( 0, 1434, 6)
    lon = ispan( 0, 1434, 6)

    latout = ispan( 0, 2864, 18)
    lonout = ispan( 0, 2864, 18)
    
    nx = dimsizes(lat)
    nxo = dimsizes(latout)
    ;print(nxo)

    lat@units = "km"
    lon@units=  "km"
    latout@units = "km"
    lonout@units=  "km"
  
  imin = 120
  jmin = 120

  imin0 = 80
  jmin0 = 80


;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 150
  nz = 68  ; Sigma levels
  r = fspan(0.0,700.0,nr)
  ro = fspan(0.0, 1400.0, nr)
  ;print(r)
  r@units = "km"
  ro@units = "km"

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
 ta_adv_v = new((/ntimes,nz,nr/),"float")
 ta_adv_h = new((/ntimes,nz,nr/),"float")
 ta_diff  = new((/ntimes,nz,nr/),"float")
 ta_heat  = new((/ntimes,nz,nr/),"float")
 ta_pbl   = new((/ntimes,nz,nr/),"float")
 tb_heat  = new((/68,240,240/),"float")

  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + it )

    tb = wrf_user_getvar(a, "th", it)
    z = wrf_user_getvar(a, "z", it)
    tb_out   = wrf_user_getvar(aout, "th", it)
    z_out   = wrf_user_getvar(aout, "z", it)

    tb_adv_h = wrf_user_getvar(a, "T_TEND_ADV_H", it)
    tb_adv_v = wrf_user_getvar(a, "T_TEND_ADV_V", it)
    tb_diff  = wrf_user_getvar(a, "T_TEND_DIFF", it)
    tb_cu    = wrf_user_getvar(a, "RTHCUTEN", it)
    tb_ra    = wrf_user_getvar(a, "RTHRATEN", it)
    tb_pbl   = wrf_user_getvar(a, "RTHBLTEN", it)

    tb_heat = tb_cu + tb_ra


;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 26500, 68)
    t       = tb
    t_out   = tb_out

    t_adv_h = tb_adv_h
    t_adv_v = tb_adv_v
    t_diff  = tb_diff
    t_heat  = tb_heat
    t_pbl   = tb_pbl

    do iz = 0, nz-1

      t(iz,:,:)       = wrf_interp_3d_z(tb, z, hei(iz))
      t_out(iz,:,:)   = wrf_interp_3d_z(tb_out, z_out, hei(iz))  

      t_adv_v(iz,:,:) = wrf_interp_3d_z(tb_adv_v, z, hei(iz))
      t_adv_h(iz,:,:) = wrf_interp_3d_z(tb_adv_h, z, hei(iz))
      t_diff(iz,:,:)  = wrf_interp_3d_z(tb_diff, z, hei(iz))
      t_heat(iz,:,:)  = wrf_interp_3d_z(tb_heat, z, hei(iz))
      t_pbl(iz,:,:)   = wrf_interp_3d_z(tb_pbl, z, hei(iz))
     
    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 tp     = new((/nz,nr*360/),"float")
 tp_out = new((/nz,nr*360/),"float")

 tp_adv_v = new((/nz,nr*360/),"float")
 tp_adv_h = new((/nz,nr*360/),"float")
 tp_diff  = new((/nz,nr*360/),"float")
 tp_heat  = new((/nz,nr*360/),"float")
 tp_pbl   = new((/nz,nr*360/),"float")

 t_pave   = new((/nz,nr/),"float")
 t_poave  = new((/nz,nr/),"float")

 t_p      = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
 t_pout   = linint2_points(latout,lonout,t_out,False,lat_po,lon_po,1)

 tp_adv_v = linint2_points(lat,lon,t_adv_v,False,lat_p,lon_p,1)
 tp_adv_h = linint2_points(lat,lon,t_adv_h,False,lat_p,lon_p,1)
 tp_diff  = linint2_points(lat,lon,t_diff,False,lat_p,lon_p,1)
 tp_heat  = linint2_points(lat,lon,t_heat,False,lat_p,lon_p,1)
 tp_pbl   = linint2_points(lat,lon,t_pbl,False,lat_p,lon_p,1)
 
do lev = 0,nz-1
  do i = 0,nr-1
      sum_te = 0.0
      sum_tout = 0.0

      sum_adv_v = 0.0
      sum_adv_h = 0.0
      sum_diff = 0.0
      sum_heat = 0.0
      sum_pbl = 0.0

      do j = 0,359,1
        
         sum_te    = sum_te    + t_p(lev,i*360+j)
         sum_tout  = sum_tout  + t_pout(lev,i*360+j)

         sum_adv_v = sum_adv_v + tp_adv_v(lev,i*360+j)
         sum_adv_h = sum_adv_h + tp_adv_h(lev,i*360+j)
         sum_diff  = sum_diff  + tp_diff(lev,i*360+j)
         sum_heat  = sum_heat  + tp_heat(lev,i*360+j)
         sum_pbl   = sum_pbl   + tp_pbl(lev,i*360+j)

      end do

      t_pave(lev,i)= sum_te/360.0
      t_poave(lev,i)= sum_tout/360.0

      ta_adv_v(it,lev,i) = sum_adv_v/360.0
      ta_adv_h(it,lev,i) = sum_adv_h/360.0
      ta_diff(it,lev,i)  = sum_diff/360.0
      ta_heat(it,lev,i)  = sum_heat/360.0
      ta_pbl(it,lev,i)   = sum_pbl/360.0

    end do
end do

t_temp = t_poave(:,21:86)
t_avg = dim_avg_n(t_temp, 1)

do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(it,lev,i) = t_pave(lev,i)-t_avg(lev)
   
    end do
end do

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 t_ano!0 = "time"
 t_ano!1 = "height"
 t_ano!2 = "Radial"
 t_ano@long_name = "temperature"
 t_ano@units = "K"
 t_ano@_FillValue = 9.96921e+36

 ta_adv_v!0 = "time"
 ta_adv_v!1 = "height"
 ta_adv_v!2 = "Radial"
 ta_adv_v@long_name = "temperature"
 ta_adv_v@units = "K"
 ta_adv_v@_FillValue = 9.96921e+36

 ta_adv_h!0 = "time"
 ta_adv_h!1 = "height"
 ta_adv_h!2 = "Radial"
 ta_adv_h@long_name = "temperature"
 ta_adv_h@units = "K"
 ta_adv_h@_FillValue = 9.96921e+36


 ta_diff!0 = "time"
 ta_diff!1 = "height"
 ta_diff!2 = "Radial"
 ta_diff@long_name = "temperature"
 ta_diff@units = "K"
 ta_diff@_FillValue = 9.96921e+36
 
 ta_heat!0 = "time"
 ta_heat!1 = "height"
 ta_heat!2 = "Radial"
 ta_heat@long_name = "temperature"
 ta_heat@units = "K"
 ta_heat@_FillValue = 9.96921e+36

 ta_pbl!0 = "time"
 ta_pbl!1 = "height"
 ta_pbl!2 = "Radial"
 ta_pbl@long_name = "temperature"
 ta_pbl@units = "K"
 ta_pbl@_FillValue = 9.96921e+36

outfilet = addfile("sim6_budget/tano_azi_interp07.nc","c")
outfilet->ta = t_ano

outfilet = addfile("sim6_budget/t_adv_h07.nc","c")
outfilet->t_adv_h = ta_adv_h

outfilet = addfile("sim6_budget/t_adv_v07.nc","c")
outfilet->t_adv_v = ta_adv_v

outfilet = addfile("sim6_budget/t_diff07.nc","c")
outfilet->t_diff = ta_diff

outfilet = addfile("sim6_budget/t_heat07.nc","c")
outfilet->t_heat = ta_heat

outfilet = addfile("sim6_budget/t_pbl07.nc","c")
outfilet->t_pbl = ta_pbl


end




     
