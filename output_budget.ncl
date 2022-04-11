load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

    nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18","6_00","6_06","6_12","6_18","7_00","7_06","7_12","7_18"/)

    nn1 = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518","600","606","612","618","700","706","712","718"/)

 din = dimsizes(nn)

 do in = 20, 27, 1

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

    outfilet = addfile("sim_lev100/height/z0"+nn1(in)+".nc","r")
    z = outfilet->z  

    printVarSummary(tb_adv_h)
    printVarSummary(z)
    printVarSummary(mut)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  ndimen = dimsizes(tb_adv_h)  
  ntimes = ndimen(0)        ; number of times in the file
  print(ntimes)
 
  nx = 420
  ny = nx
  
  mdims = new((/ntimes,420,420/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    lat = ispan( 0, 838, 2)       ;;;grid = 420
    lon = ispan( 0, 838, 2)      ;;;domain = 840 km

    ;latout = ispan( 0, 1434, 6)  ;;; grid = 240 
    ;lonout = ispan( 0, 1434, 6)  ;;; domain 1440 km
    
    lat@units = "km"
    lon@units=  "km"
    ;latout@units = "km"
    ;lonout@units=  "km"
  
  imin = 210
  jmin = 210

  ;imin0 = 119
  ;jmin0 = 119

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

 do i = 0,nr-1,1
    do j = 0,359,1
         dx(i,j)= r(i)*cos(alfa(j))
         dy(i,j)= r(i)*sin(alfa(j))
    end do
end do

;------------------- calculate the lat/lon of the pole coordinate ---------------

  lat_p = new(nr*360,"float")
  lon_p = new(nr*360,"float")

  do i = 0, nr-1, 1
    do j = 0, 359, 1

      lat_p(i*360+j) = lat(imin) + dx(i,j)
      lon_p(i*360+j) = lon(jmin) + dy(i,j)

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
 
 ta_adv_v = new((/ntimes,nz,nr,360/),"float")
 ta_adv_h = new((/ntimes,nz,nr,360/),"float")
 ;ta_adv = new((/ntimes,nz,nr/),"float")

 ta_diff1  = new((/ntimes,nz,nr,360/),"float")
 ta_diff3  = new((/ntimes,nz,nr,360/),"float")

 ta_heat  = new((/ntimes,nz,nr,360/),"float")
 ta_pbl   = new((/ntimes,nz,nr,360/),"float")
 ta_cu   = new((/ntimes,nz,nr,360/),"float")
 ta_ra   = new((/ntimes,nz,nr,360/),"float")

  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + it )

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    t_adv_h = new((/nz,nx,ny/), "float")
    t_adv_v = new((/nz,nx,ny/), "float")

    t_diff1  = new((/nz,nx,ny/), "float")
    t_diff3  = new((/nz,nx,ny/), "float")

    t_heat  = new((/nz,nx,ny/), "float")
    
    ;t_cu    = tb_adv_h
    ;t_ra    = tb_adv_h
    
    t_pbl   = new((/nz,nx,ny/), "float")
    
    do iz = 0, nz-1

      t_adv_v(iz,:,:) = wrf_interp_3d_z(tb_adv_v(it,:,:,:), z(it,:,:,:), hei(iz))
      t_adv_h(iz,:,:) = wrf_interp_3d_z(tb_adv_h(it,:,:,:), z(it,:,:,:), hei(iz))
      t_diff1(iz,:,:)  = wrf_interp_3d_z(tb_diff1(it,:,:,:), z(it,:,:,:), hei(iz))
      t_diff3(iz,:,:)  = wrf_interp_3d_z(tb_diff3(it,:,:,:), z(it,:,:,:), hei(iz))

      t_heat(iz,:,:)  = wrf_interp_3d_z(tb_heat(it,:,:,:), z(it,:,:,:), hei(iz))
      t_pbl(iz,:,:)   = wrf_interp_3d_z(tb_pbl(it,:,:,:), z(it,:,:,:), hei(iz))
      ;t_cu(iz,:,:)    = wrf_interp_3d_z(tb_cu(it,:,:,:), z(it,:,:,:), hei(iz))/mut(:,:)
      ;t_ra(iz,:,:)    = wrf_interp_3d_z(tb_ra(it,:,:,:), z(it,:,:,:), hei(iz))/mut(:,:)

      t_adv_v(iz,:,:) = t_adv_v(iz,:,:)/mut(it,:,:)
      t_adv_h(iz,:,:) = t_adv_h(iz,:,:)/mut(it,:,:)
      t_diff1(iz,:,:) = t_diff1(iz,:,:)/mut(it,:,:)
      t_diff3(iz,:,:) = t_diff3(iz,:,:)/mut(it,:,:)
      t_pbl(iz,:,:) = t_pbl(iz,:,:)/mut(it,:,:)

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
 ;tp_cu   = new((/nz,nr*360/),"float")
 ;tp_ra   = new((/nz,nr*360/),"float")


; how to check?
 tp_adv_v = linint2_points(lat,lon,t_adv_v,False,lat_p,lon_p,1)
 tp_adv_h = linint2_points(lat,lon,t_adv_h,False,lat_p,lon_p,1)


 tp_diff1  = linint2_points(lat,lon,t_diff1,False,lat_p,lon_p,1)
 tp_diff3  = linint2_points(lat,lon,t_diff3,False,lat_p,lon_p,1)

 tp_heat  = linint2_points(lat,lon,t_heat,False,lat_p,lon_p,1)
 tp_pbl   = linint2_points(lat,lon,t_pbl,False,lat_p,lon_p,1)
 ;tp_cu    = linint2_points(lat,lon,t_cu,False,lat_p,lon_p,1)
 ;tp_ra    = linint2_points(lat,lon,t_ra,False,lat_p,lon_p,1)
 
  do lev = 0,nz-1

    advh_po_level = onedtond(tp_adv_h(lev,:),(/nr,360/)) 
    advv_po_level = onedtond(tp_adv_v(lev,:),(/nr,360/)) 
    diff_po_level = onedtond(tp_diff1(lev,:),(/nr,360/)) 
    diff3_po_level = onedtond(tp_diff3(lev,:),(/nr,360/)) 
    heat_po_level = onedtond(tp_heat(lev,:),(/nr,360/)) 
    pbl_po_level = onedtond(tp_pbl(lev,:),(/nr,360/)) 

    ta_adv_v(it,lev,:,:) = advv_po_level
    ta_adv_h(it,lev,:,:) = advh_po_level
    ta_diff1(it,lev,:,:) = diff_po_level
    ta_diff3(it,lev,:,:) = diff3_po_level
    ta_heat(it,lev,:,:)  = heat_po_level
    ta_pbl(it,lev,:,:)   = pbl_po_level

  end do

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ta_adv_v!0 = "time"
 ta_adv_v!1 = "height"
 ta_adv_v!2 = "Radial"
 ta_adv_v!3 = "angle"
 ta_adv_v@long_name = "vertical advection"
 ta_adv_v@units = "K/s"
 ta_adv_v@_FillValue = 9.96921e+36

 ta_adv_h!0 = "time"
 ta_adv_h!1 = "height"
 ta_adv_h!2 = "Radial"
 ta_adv_h!3 = "angle"
 ta_adv_h@long_name = "Horizontal advection"
 ta_adv_h@units = "K/s"
 ta_adv_h@_FillValue = 9.96921e+36

 ta_diff1!0 = "time"
 ta_diff1!1 = "height"
 ta_diff1!2 = "Radial"
 ta_diff1!3 = "angle"
 ta_diff1@long_name = "diffusion"
 ta_diff1@units = "K/s"
 ta_diff1@_FillValue = 9.96921e+36
 
 ta_diff3!0 = "time"
 ta_diff3!1 = "height"
 ta_diff3!2 = "Radial"
 ta_diff3!3 = "angle"
 ta_diff3@long_name = "diffusion"
 ta_diff3@units = "K/s"
 ta_diff3@_FillValue = 9.96921e+36

 ta_heat!0 = "time"
 ta_heat!1 = "height"
 ta_heat!2 = "Radial"
 ta_heat!3 = "angle"
 ta_heat@long_name = "Nondiabatic heating"
 ta_heat@units = "K/s"
 ta_heat@_FillValue = 9.96921e+36

 ta_pbl!0 = "time"
 ta_pbl!1 = "height"
 ta_pbl!2 = "Radial"
 ta_pbl!3 = "angle"
 ta_pbl@long_name = "pbl"
 ta_pbl@units = "K/s"
 ta_pbl@_FillValue = 9.96921e+36

 ;ta_cu!0 = "time"
 ;ta_cu!1 = "height"
 ;ta_cu!2 = "Radial"
 ;ta_cu@long_name = "cu"
 ;ta_cu@units = "K"
 ;ta_cu@_FillValue = 9.96921e+36

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

outfilet = addfile("sim_lev100/bud/ang_adv_h_0"+nn(in)+".nc","c")
outfilet->t_adv_h = ta_adv_h(:,0:90,:,:)

outfilet = addfile("sim_lev100/bud/ang_adv_v_0"+nn(in)+".nc","c")
;outfilet = addfile("sim9/bud_d1_06/adv.nc","c")
outfilet->t_adv_v = ta_adv_v(:,0:90,:,:)

outfilet = addfile("sim_lev100/bud/ang_diff_0"+nn(in)+".nc","c")
outfilet->t_diff = ta_diff1(:,0:90,:,:)

outfilet = addfile("sim_lev100/bud/ang_diff3_0"+nn(in)+".nc","c")
outfilet->t_diff = ta_diff3(:,0:90,:,:)

outfilet = addfile("sim_lev100/bud/ang_heat_0"+nn(in)+".nc","c")
outfilet->t_heat = ta_heat(:,0:90,:,:)

outfilet = addfile("sim_lev100/bud/ang_pbl_0"+nn(in)+".nc","c")
outfilet->t_pbl = ta_pbl(:,0:90,:,:)

end do
end
