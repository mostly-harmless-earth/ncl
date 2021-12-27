load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/sim9_v3/wrfout_d02_2000-09-01_12:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  files = systemfunc("ls ./sim9_v3/wrfout_d02_*")   
  a = addfiles(files, "r")
  ListSetType(a, "cat")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/ntimes,68,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    lat = ispan( 0, 1434, 6)
    lon = ispan( 0, 1434, 6)

    ;latout = ispan( 0, 2864, 18)
    ;lonout = ispan( 0, 2864, 18)
    
    nx = dimsizes(lat)
    ;nxo = dimsizes(latout)
    ;print(nxo)

    lat@units = "km"
    lon@units=  "km"
    ;latout@units = "km"
    ;lonout@units=  "km"
  
  imin = 120
  jmin = 120

  ;imin0 = 80
  ;jmin0 = 80

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
         ;dxo(i,j)= ro(i)*cos(alfa(j))
         ;dyo(i,j)= ro(i)*sin(alfa(j))
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
      ;lat_po(i*360+j) = latout(imin0) + dxo(i,j)
      ;lon_po(i*360+j) = lonout(jmin0) + dyo(i,j)

    end do
  end do
;;-----------------------------------------------------------------------
 
  rai_ave  = new((/ntimes,nz,nr/),"float")
  tan_ave  = new((/ntimes,nz,nr/),"float")
  w_ave = new((/ntimes,nz,nr/),"float")

  do it = 0 , ntimes-1, 1; TIME LOOP
   
    print("Working on time: " + it )

    z   = wrf_user_getvar(a,"z",it)
    u   = wrf_user_getvar(a,"ua",it)
    v   = wrf_user_getvar(a,"va",it)
    w   = wrf_user_getvar(a,"wa",it)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 68)
    uu = u
    vv = v
    ww = w

    do iz = 0, nz-1

      uu(iz,:,:) = wrf_interp_3d_z(u, z, hei(iz))
      vv(iz,:,:) = wrf_interp_3d_z(v, z, hei(iz)) 
      ww(iz,:,:) = wrf_interp_3d_z(w, z, hei(iz)) 
    
    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;u_p = new((/nz,nr*360/),"float")
 ;v_p = new((/nz,nr*360/),"float")

 u_p = linint2_points(lat,lon,uu,False,lat_p,lon_p,1)
 v_p = linint2_points(lat,lon,vv,False,lat_p,lon_p,1)
 w_p = linint2_points(lat,lon,vv,False,lat_p,lon_p,1)

do lev = 0,nz-1
  do i = 0,nr-1

      sum_t = 0.0
      sum_r = 0.0
      sum_w = 0.0

      do j = 0,359,1
        
         tangential= -u_p(lev,i*360+j)*sin(alfa(j))+v_p(lev,i*360+j)*cos(alfa(j))
         sum_t = sum_t + tangential

         radial= u_p(lev,i*360+j)*cos(alfa(j))+v_p(lev,i*360+j)*sin(alfa(j))
         sum_r = sum_r + radial

         sum_w = sum_w +  w_p(lev,i*360+j)

      end do

      rai_ave(it,lev,i)= sum_r/360.0
      tan_ave(it,lev,i)= sum_t/360.0
      w_ave(it,lev,i)= sum_w/360.0
   
    end do
end do

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   

 rai_ave!0 = "time"
 rai_ave!1 = "height"
 rai_ave!2 = "Radial"

 rai_ave@long_name = "Radial wind"
 rai_ave@units = "m/s"
 rai_ave@_FillValue = 9.96921e+36

 tan_ave!0 = "time"
 tan_ave!1 = "height"
 tan_ave!2 = "Radial"

 tan_ave@long_name = "tangential wind"
 tan_ave@units = "m/s"
 tan_ave@_FillValue = 9.96921e+36

 w_ave!0 = "time"
 w_ave!1 = "height"
 w_ave!2 = "Radial"

 w_ave@long_name = "vertical wind"
 w_ave@units = "m/s"
 w_ave@_FillValue = 9.96921e+36
 
outfilet = addfile("sim9_v3/radial_wind.nc","c")
outfilet->wrad = rai_ave

outfilet = addfile("sim9_v3/tangential_wind.nc","c")            
outfilet->wtan = tan_ave

outfilet = addfile("sim9_v3/vertical_wind.nc","c")            
outfilet->ww = w_ave


end