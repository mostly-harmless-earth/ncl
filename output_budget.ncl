load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d03_2000-02-01_06:00:00","r")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/ntimes,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    lat = ispan( 0, 838, 2)       ;;;grid = 420
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

  imin0 = 119
  jmin0 = 119

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 100
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

  ;wks=gsn_open_wks("X11","/user_home/jyyin/dta/sim9/lat_lon") 
  ;gsn_define_colormap(wks,"MPL_coolwarm")  ; Change color map.

  ;lat_test = new((/nr*360,2/),"float")
  ;lat_test(:,0) = lat_p(:)
  ;lat_test(:,1) = lon_p(:)

  ;res = True

  ;plot = gsn_contour(wks, lat_test, res)
  ;print("finish plot")

  ;frame(wks)
;;-----------------------------------------------------------------------
 
 ta_adv_v = new((/ntimes,nz,nr/),"float")
 ta_adv_h = new((/ntimes,nz,nr/),"float")
 ;ta_adv = new((/ntimes,nz,nr/),"float")

 ta_diff1  = new((/ntimes,nz,nr/),"float")
 ta_diff3  = new((/ntimes,nz,nr/),"float")

 ta_heat  = new((/ntimes,nz,nr/),"float")
 ta_pbl   = new((/ntimes,nz,nr/),"float")
 ta_cu   = new((/ntimes,nz,nr/),"float")
 ta_ra   = new((/ntimes,nz,nr/),"float")

  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + times(it)  )

    z = wrf_user_getvar(a, "z", it)
 
    tb_adv_h = wrf_user_getvar(a, "T_TEND_ADV_H", it)
    tb_adv_v = wrf_user_getvar(a, "T_TEND_ADV_V", it)
    ;tb_adv = wrf_user_getvar(a, "RTHFTEN", it)

    tb_diff1  = wrf_user_getvar(a, "T_TEND_DIFF", it)
    tb_diff3  = wrf_user_getvar(a, "T_TEND_DIFF3", it)

    tb_cu    = wrf_user_getvar(a, "RTHCUTEN", it)
    tb_ra    = wrf_user_getvar(a, "RTHRATEN", it)
    tb_pbl   = wrf_user_getvar(a, "RTHBLTEN", it)
    tb_heat  = wrf_user_getvar(a, "H_DIABATIC", it)
    
    ;tb_shcu    = wrf_user_getvar(a, "RTHSHTEN", it)
    mu = wrf_user_getvar(a, "MU", it)
    mub = wrf_user_getvar(a, "MUB", it)
    mut = mu+mub

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(100, 27000, 100)

    t_adv_h = tb_adv_h
    t_adv_v = tb_adv_v

    t_diff1  = tb_diff1
    t_diff3  = tb_diff3

    t_heat  = tb_heat
    t_cu    = tb_cu
    t_ra    = tb_ra
    t_pbl   = tb_pbl
    
    do iz = 0, nz-1

      t_adv_v(iz,:,:) = wrf_interp_3d_z(tb_adv_v, z, hei(iz))/mut(:,:)
      t_adv_h(iz,:,:) = wrf_interp_3d_z(tb_adv_h, z, hei(iz))/mut(:,:)

      t_diff1(iz,:,:)  = wrf_interp_3d_z(tb_diff1, z, hei(iz))/mut(:,:)
      t_diff3(iz,:,:)  = wrf_interp_3d_z(tb_diff3, z, hei(iz))/mut(:,:)

      t_heat(iz,:,:)  = wrf_interp_3d_z(tb_heat, z, hei(iz))
      t_pbl(iz,:,:)   = wrf_interp_3d_z(tb_pbl, z, hei(iz))/mut(:,:)
      t_cu(iz,:,:)    = wrf_interp_3d_z(tb_cu, z, hei(iz))/mut(:,:)
      t_ra(iz,:,:)    = wrf_interp_3d_z(tb_ra, z, hei(iz))/mut(:,:)

    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 tp_adv_v = new((/nz,nr*360/),"float")
 tp_adv_h = new((/nz,nr*360/),"float")
 ;tp_adv = new((/nz,nr*360/),"float")
 
 tp_diff1  = new((/nz,nr*360/),"float")
 tp_diff3  = new((/nz,nr*360/),"float")
 
 tp_heat  = new((/nz,nr*360/),"float")
 tp_pbl   = new((/nz,nr*360/),"float")
 tp_cu   = new((/nz,nr*360/),"float")
 tp_ra   = new((/nz,nr*360/),"float")


 tp_adv_v = linint2_points(lat,lon,t_adv_v,False,lat_p,lon_p,1)
 tp_adv_h = linint2_points(lat,lon,t_adv_h,False,lat_p,lon_p,1)


 tp_diff1  = linint2_points(lat,lon,t_diff1,False,lat_p,lon_p,1)
 tp_diff3  = linint2_points(lat,lon,t_diff3,False,lat_p,lon_p,1)

 tp_heat  = linint2_points(lat,lon,t_heat,False,lat_p,lon_p,1)
 tp_pbl   = linint2_points(lat,lon,t_pbl,False,lat_p,lon_p,1)
 tp_cu    = linint2_points(lat,lon,t_cu,False,lat_p,lon_p,1)
 tp_ra    = linint2_points(lat,lon,t_ra,False,lat_p,lon_p,1)
 
do lev = 0,nz-1
  do i = 0,nr-1

      sum_adv_v = 0.0
      sum_adv_h = 0.0
      ;sum_adv = 0.0

      sum_diff1 = 0.0
      sum_diff2 = 0.0
      sum_diff3 = 0.0

      sum_heat = 0.0
      sum_pbl = 0.0
      sum_cu = 0.0
      sum_ra = 0.0

      do j = 0,359,1

         sum_adv_v = sum_adv_v + tp_adv_v(lev,i*360+j)
         sum_adv_h = sum_adv_h + tp_adv_h(lev,i*360+j)
         ;sum_adv = sum_adv + tp_adv(lev,i*360+j)

         sum_diff1  = sum_diff1  + tp_diff1(lev,i*360+j)
         sum_diff3  = sum_diff3  + tp_diff3(lev,i*360+j)

         sum_heat  = sum_heat  + tp_heat(lev,i*360+j)
         sum_pbl   = sum_pbl   + tp_pbl(lev,i*360+j)
         sum_cu    = sum_cu    + tp_cu(lev,i*360+j)
         sum_ra    = sum_ra    + tp_ra(lev,i*360+j)
        
      end do

      ta_adv_v(it,lev,i) = sum_adv_v/360.0
      ta_adv_h(it,lev,i) = sum_adv_h/360.0

      ta_diff1(it,lev,i)  = sum_diff1/360.0
      ta_diff3(it,lev,i)  = sum_diff3/360.0

      ta_heat(it,lev,i)  = sum_heat/360.0
      ta_pbl(it,lev,i)   = sum_pbl/360.0
      ta_cu(it,lev,i)    = sum_cu/360.0
      ta_ra(it,lev,i)    = sum_ra/360.0

    end do
end do
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

 ta_cu!0 = "time"
 ta_cu!1 = "height"
 ta_cu!2 = "Radial"
 ta_cu@long_name = "cu"
 ta_cu@units = "K"
 ta_cu@_FillValue = 9.96921e+36

 ;ta_shcu!0 = "time"
 ;ta_shcu!1 = "height"
 ;ta_shcu!2 = "Radial"
 ;ta_shcu@long_name = "cush"
 ;ta_shcu@units = "K"
 ;ta_shcu@_FillValue = 9.96921e+36

 ;ta_ra!0 = "time"
 ;ta_ra!1 = "height"
 ;ta_ra!2 = "Radial"
 ;ta_ra@long_name = "pbl"
 ;ta_ra@units = "K"
 ;ta_ra@_FillValue = 9.96921e+36

outfilet = addfile("sim_lev100/bud/adv_h_d1_06.nc","c")
outfilet->t_adv_h = ta_adv_h

outfilet = addfile("sim_lev100/bud/adv_v_d1_06.nc","c")
;outfilet = addfile("sim9/bud_d1_06/adv.nc","c")
outfilet->t_adv_v = ta_adv_v

outfilet = addfile("sim_lev100/bud/diff1_d1_06.nc","c")
outfilet->t_diff = ta_diff1
outfilet = addfile("sim_lev100/bud/diff3_d1_06.nc","c")
outfilet->t_diff = ta_diff3

outfilet = addfile("sim_lev100/bud/heat_d1_06.nc","c")
outfilet->t_heat = ta_heat

outfilet = addfile("sim_lev100/bud/pbl_d1_06.nc","c")
outfilet->t_pbl = ta_pbl

outfilet = addfile("sim_lev100/bud/cu_d1_06.nc","c")
outfilet->t_cu = ta_cu


outfilet = addfile("sim_lev100/bud/ra_d1_06.nc","c")
outfilet->t_ra = ta_ra

end