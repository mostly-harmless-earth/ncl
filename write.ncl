load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")
         
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  ;print(mdims)
  nd = dimsizes(mdims)
  FirstTime = True



  wks = gsn_open_wks("pdf","sim4/temprature-wind-develop-slow")
  gsn_define_colormap(wks, "MPL_coolwarm")
;---------------------------------------------------------------

    ;printVarSummary(t_out)
  
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
  nz = mdims(1)  ; Sigma levels
 

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

 t_pave = new((/ntimes,nz,nr/),"float")
 t_poave = new((/ntimes,nz,nr/),"float")

 t_ano = new((/ntimes,nz,nr/),"float")

 tangential_ave = new((/ntimes,nz,nr/),"float")
 radial_ave = new((/ntimes,nz,nr/),"float")
 w_ave = new((/ntimes,nz,nr/),"float")

  do it = 18 , 18 , 6; TIME LOOP

    print("Working on time: " + times(it) )
    plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
 
    z   = wrf_user_getvar(a, "z",it)     ; grid point height
    p = wrf_user_getvar(a, "pressure", it)
    t   = wrf_user_getvar(a, "tk", it)
    t_out   = wrf_user_getvar(a1, "tk", it)
    u   = wrf_user_getvar(a,"ua",it)
    v   = wrf_user_getvar(a,"va",it)
    w   = wrf_user_getvar(a,"wa",it)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 

 u_p = new((/nz,nr*360/),"float") 
 v_p = new((/nz,nr*360/),"float")
 w_p = new((/nz,nr*360/),"float")
 
 t_p = new((/nz,nr*360/),"float")
 t_po = new((/nz,nr*360/),"float")


  u_p = linint2_points(lat,lon,u,False,lat_p,lon_p,1)
  v_p = linint2_points(lat,lon,v,False,lat_p,lon_p,1)
  w_p = linint2_points(lat,lon,w,False,lat_p,lon_p,1)

  t_p = linint2_points(lat,lon,t,False,lat_p,lon_p,1)

  t_pout = linint2_points(latout,lonout,t_out,False,lat_po,lon_po,1)
 
do lev = 0,nz-1
  do i = 0,nr-1

      sum_t = 0.0
      sum_te = 0.0
      sum_r = 0.0
      sum_w = 0.0
      sum_tout = 0.0

      do j = 0,359,1
         
         tangential= -u_p(lev,i*360+j)*sin(alfa(j))+v_p(lev,i*360+j)*cos(alfa(j))
         radial= u_p(lev,i*360+j)*cos(alfa(j))+v_p(lev,i*360+j)*sin(alfa(j))

         sum_t = sum_t + tangential
         sum_r = sum_r + radial
         sum_w = sum_w + w_p(lev,i*360+j)
         
         sum_te = sum_te + t_p(lev,i*360+j)
         sum_tout = sum_tout + t_pout(lev,i*360+j)

      end do

      tangential_ave(it,lev,i)= sum_t/360.0
      radial_ave(it,lev,i) = sum_r/360.0
      w_ave(it,lev,i)= sum_w/360.0
      t_pave(it,lev,i)= sum_te/360.0
      t_poave(it,lev,i)= sum_tout/360.0
   
    end do
end do

t_temp = t_poave(it,:,100:149)
printVarSummary(t_temp)
t_avg = dim_avg_n(t_temp, 1)

do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(it,lev,i) = t_pave(it,lev,i)-t_avg(lev)
   
    end do
end do

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   

 t_ano!1 = "Press"
 t_ano!2 = "Radial"
 t_ano&Press= p(:,imin,jmin)
 t_ano&Radial = r
 r@units = "km"

 tangential_ave!1 = "Press"
 tangential_ave!2 = "Radial"
 tangential_ave&Press = p(:,imin,jmin)
 tangential_ave&Radial = r

 radial_ave!1 = "Press"
 radial_ave!2 = "Radial"
 radial_ave&Press= p(:,imin,jmin)
 radial_ave&Radial = r

 w_ave!1 = "Press"
 w_ave!2 = "Radial"
 w_ave&Press= p(:,imin,jmin)
 w_ave&Radial = r

 t_ano!1 = "Press"
 t_ano!2 = "Radial"
 t_ano&Press= p(:,imin,jmin)
 t_ano&Radial = r

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; write to file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

write_table("temprature-ano.txt", "w", t_ano, "%16.2f")

end do

end

     
