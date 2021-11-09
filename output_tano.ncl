load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim9/wrfout_d02_2000-09-02_00:00:00","r")
  aout = addfile("/user_home/jyyin/dta/sim9/wrfout_d01_2000-09-02_00:00:00","r")
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/480,ntimes,240,240/), integer)
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
  
  imin = 119
  jmin = 122

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

  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + it )

    tb = wrf_user_getvar(a, "th", it)
    z = wrf_user_getvar(a, "z", it)
    tb_out   = wrf_user_getvar(aout, "th", it)
    z_out   = wrf_user_getvar(aout, "z", it)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 68)
    t       = tb
    t_out   = tb_out

    do iz = 0, nz-1

      t(iz,:,:)       = wrf_interp_3d_z(tb, z, hei(iz))
      t_out(iz,:,:)   = wrf_interp_3d_z(tb_out, z_out, hei(iz))

    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 tp     = new((/nz,nr*360/),"float")
 tp_out = new((/nz,nr*360/),"float")

 t_pave   = new((/nz,nr/),"float")
 t_poave  = new((/nz,nr/),"float")

 t_p      = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
 t_pout   = linint2_points(latout,lonout,t_out,False,lat_po,lon_po,1)

do lev = 0,nz-1
  do i = 0,nr-1
      sum_te = 0.0
      sum_tout = 0.0

      do j = 0,359,1
        
         sum_te    = sum_te    + t_p(lev,i*360+j)
         sum_tout  = sum_tout  + t_pout(lev,i*360+j)

      end do

      t_pave(lev,i)= sum_te/360.0
      t_poave(lev,i)= sum_tout/360.0

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
 t_ano@long_name = "temperature anomaly"
 t_ano@units = "K"
 t_ano@_FillValue = 9.96921e+36

outfilet = addfile("sim9/tano_azi_d2_00.nc","c")
outfilet->ta = t_ano

end