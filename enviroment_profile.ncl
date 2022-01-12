load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  files = systemfunc("ls ./sim9_v3/wrfout_d01_*")
  aout = addfiles(files, "r")
  ListSetType(aout, "cat")

  ;aout = addfile("/user_home/jyyin/dta/sim9_v3/wrfout_d01_2000-09-05_12:00:00","r")
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(aout,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/480,ntimes,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    latout = ispan( 0, 2864, 18)
    lonout = ispan( 0, 2864, 18)
    
    nxo = dimsizes(latout)
    ;print(nxo)

    latout@units = "km"
    lonout@units=  "km"

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

      lat_po(i*360+j) = latout(imin0) + dxo(i,j)
      lon_po(i*360+j) = lonout(jmin0) + dyo(i,j)

    end do
  end do
;;-----------------------------------------------------------------------

  t_avg = new((/ntimes,nz/),"float")
 
  do it = 0 , ntimes-1 , 1; TIME LOOP
   
    print("Working on time: " + it )

    tb_out   = wrf_user_getvar(aout, "th", it)
    z_out   = wrf_user_getvar(aout, "z", it)
    ;printVarSummary(tb_out)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 68)
    t_out   = tb_out

    do iz = 0, nz-1

      t_out(iz,:,:)   = wrf_interp_3d_z(tb_out, z_out, hei(iz))

    end do

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 tp_out = new((/nz,nr*360/),"float")
 t_poave  = new((/nz,nr/),"float")
 t_pout   = linint2_points(latout,lonout,t_out,False,lat_po,lon_po,1)

do lev = 0,nz-1
  do i = 0,nr-1

      sum_tout = 0.0

      do j = 0,359,1
        
         sum_tout  = sum_tout  + t_pout(lev,i*360+j)

      end do

      t_poave(lev,i)= sum_tout/360.0

    end do
end do

t_temp = t_poave(:,42:75)
t_a = dim_avg_n(t_temp, 1)

t_avg(it,:) = t_a(:)

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;wks = gsn_open_wks("pdf","sim9_v3/max_tlc")
  ;gsn_define_colormap(wks, "MPL_RdBu")
  ;gsn_reverse_colormap(wks)

  ;res = True
  ;plot = gsn_csm_y(wks, t_avg(5,:), res)
  ;plot = gsn_csm_y(wks, t_avg(105,:), res)
   
 t_avg!0 = "time"
 t_avg!1 = "height"
 t_avg@long_name = "enviroment profile"
 t_avg@units = "K"
 t_avg@_FillValue = 9.96921e+36

outfilet = addfile("sim9_v3/tha/en_po.nc","c")
outfilet->t_avg = t_avg

end