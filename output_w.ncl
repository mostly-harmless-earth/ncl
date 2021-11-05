load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  ;print(mdims)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    lat = ispan( 0, 1434, 6)
    lon = ispan( 0, 1434, 6)
    nx = dimsizes(lat)
  
    lat@units = "km"
    lon@units=  "km"
    
    imin = 120
    jmin = 120
;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 150
  nz = mdims(1)  ; Sigma levels
  r = fspan(0.0,700.0,nr)
  r@units = "km"
  
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
;;-----------------------------------------------------------------------
 
 w_ave = new((/ntimes,nz,nr/),"float")

  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + times(it) )
    plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
 
    z   = wrf_user_getvar(a, "z",it)     ; grid point height
    p = wrf_user_getvar(a, "pressure", it)
    w   = wrf_user_getvar(a,"wa",it)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  w_p = new((/nz,nr*360/),"float")
  w_p = linint2_points(lat,lon,w,False,lat_p,lon_p,1)

  
do lev = 0,nz-1
  do i = 0,nr-1

      sum_w = 0.0
      
      do j = 0,359,1
         
         sum_w = sum_w + w_p(lev,i*360+j)

      end do

      w_ave(it,lev,i)= sum_w/360.0
      
    end do
 end do

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 w_ave!0 = "time"
 w_ave!1 = "height"
 w_ave!2 = "Radial"
 ;w_ave&time = times
 ;w_ave&height= z(:,5,5)/1000
 ;w_ave&Radial = r

 w_ave@long_name = "vertical wind"
 w_ave@units = "m/s"
 w_ave@_FillValue = 9.96921e+36

 z@units = "km"
 r@units = "km"
 
outfilew = addfile("output/w_azi.nc","c")
outfilew->w = w_ave

end




     
