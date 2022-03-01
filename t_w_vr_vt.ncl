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
          "500","506","512","518","6_00","6_06","6_12","6_18"/)

  nn1 = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18","6_00","6_06","6_12","6_18"/)

  din = dimsizes(nn)

 do in = 0, din-1, 1000 

  print(in)
    
  ;tb = at[:]->th
  ;printVarSummary(tb)
  ;z = az[:]->z
  ;printVarSummary(z)
  
  at = addfile("sim_lev100/theta/theta0"+nn(in)+".nc", "r")
  az = addfile("sim_lev100/height/z0"+nn(in)+".nc", "r")
  au = addfile("sim_lev100/wind/u_0"+nn1(in)+".nc", "r")
  av = addfile("sim_lev100/wind/v_0"+nn1(in)+".nc", "r")
  aw = addfile("sim_lev100/wind/w_0"+nn1(in)+".nc", "r")
  
  u   = au->ua
  v   = av->va
  w   = aw->wa

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
 
 t_ano    = new((/ntimes,nz,nr,360/),"float")
 rai_ave  = new((/ntimes,nz,nr,360/),"float")
 tan_ave  = new((/ntimes,nz,nr,360/),"float")
 w_ave = new((/ntimes,nz,nr,360/),"float")
 

  do it = 0 , ntimes-1 , 6; TIME LOOP
   
    print("Working on time: " + it )
;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;


    t = new((/nz,nx,ny/),"float")
    uu = t
    vv = t
    ww = t

    do iz = 0, nz-1

      t(iz,:,:)  = wrf_interp_3d_z(tb(it,:,:,:), z(it,:,:,:), hei(iz))
      uu(iz,:,:) = wrf_interp_3d_z(u(it,:,:,:), z(it,:,:,:), hei(iz))
      vv(iz,:,:) = wrf_interp_3d_z(v(it,:,:,:), z(it,:,:,:), hei(iz)) 
      ww(iz,:,:) = wrf_interp_3d_z(w(it,:,:,:), z(it,:,:,:), hei(iz)) 

    end do


;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 tp     = new((/nz,nr*360/),"float")

 t_pave   = new((/nz,nr/),"float")

 t_p = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
 u_p = linint2_points(lat,lon,uu,False,lat_p,lon_p,1)
 v_p = linint2_points(lat,lon,vv,False,lat_p,lon_p,1)
 w_p = linint2_points(lat,lon,ww,False,lat_p,lon_p,1)

 do lev = 0,nz-1

    tt_po_level = onedtond(t_p(lev,:),(/nr,360/)) 
    ww_po_level = onedtond(w_p(lev,:),(/nr,360/)) 

    t_ano(it,lev,:,:) = tt_po_level
    w_ave(it,lev,:,:) = ww_po_level
   
end do

  do lev = 0,90
    do i = 0,nr-1
      do j = 0,359,1
        
         tangential= -u_p(lev,i*360+j)*sin(alfa(j))+v_p(lev,i*360+j)*cos(alfa(j))
         radial= u_p(lev,i*360+j)*cos(alfa(j))+v_p(lev,i*360+j)*sin(alfa(j))
         rai_ave(it,lev,i,j) = radial
         tan_ave(it,lev,i,j) = tangential
     
      end do
    end do
  end do


end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 t_ano!0 = "time"
 t_ano!1 = "height"
 t_ano!2 = "Radial"
 t_ano!3 = "Angles"
 t_ano@long_name = "temperature anomaly"
 t_ano@units = "K"
 t_ano@_FillValue = 9.96921e+36

 rai_ave!0 = "time"
 rai_ave!1 = "height"
 rai_ave!2 = "Radial"
 rai_ave!3 = "Angles"
 rai_ave@long_name = "Radial wind"
 rai_ave@units = "m/s"
 rai_ave@_FillValue = 9.96921e+36

 tan_ave!0 = "time"
 tan_ave!1 = "height"
 tan_ave!2 = "Radial"
 tan_ave!3 = "Angles"
 tan_ave@long_name = "tangential wind"
 tan_ave@units = "m/s"
 tan_ave@_FillValue = 9.96921e+36

 w_ave!0 = "time"
 w_ave!1 = "height"
 w_ave!2 = "Radial"
 w_ave!3 = "Angles"
 w_ave@long_name = "vertical wind"
 w_ave@units = "m/s"
 w_ave@_FillValue = 9.96921e+36

  outfilet = addfile("sim_lev100/angle/cirtano"+nn(in)+".nc","c")
  outfilet->ta = t_ano(:,0:90,:,:)

  outfilet = addfile("sim_lev100/angle/radial_wind"+nn(in)+".nc","c")
  outfilet->wrad = rai_ave(:,0:90,:,:)

  outfilet = addfile("sim_lev100/angle/tangential_wind"+nn(in)+".nc","c")            
  outfilet->wtan = tan_ave(:,0:90,:,:)

  outfilet = addfile("sim_lev100/angle/vertical_wind"+nn(in)+".nc","c")            
  outfilet->ww = w_ave(:,0:90,:,:)

  print("Finish output")

  delete(outfilet)
  delete(at)
  delete(az)
  delete(au)
  delete(av)
  delete(aw)
 
  delete(tb)
  delete(z)
  delete(u)
  delete(v)
  delete(w)

end do



end