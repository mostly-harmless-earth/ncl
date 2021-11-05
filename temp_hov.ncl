load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/user_home/jyyin/dta/sim4/wrfout_d02_2000-04-04_00:00:00","r")
  a1 = addfile("/user_home/jyyin/dta/sim4/wrfout_d01_2000-04-04_00:00:00","r")
         
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
  print(ntimes)
 
  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  ;print(mdims)
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
  print(nxo)

  lat@units = "km"
  lon@units=  "km"
  latout@units = "km"
  lonout@units=  "km"

  ;slp = wrf_user_getvar(a,"slp",-1)
  
  imin = 120
  jmin = 120

  imin0 = 80
  jmin0 = 80

;;--------------------------------------------------------------
;---------------------------------------------------------------

  nz = mdims(1)  ; Sigma levels
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

 do i = 0,nr-1,1
    do j = 0,359,1
         dx(i,j)= r(i)*cos(alfa(j))
         dy(i,j)= r(i)*sin(alfa(j))
         dxo(i,j)= ro(i)*cos(alfa(j))
         dyo(i,j)= ro(i)*sin(alfa(j))
    end do
end do

t_anall = new((/nz,nr,37/),"float")
timee = ispan(0, 216, 6)
nmt = 0

;------------------------------------------------------------------------------

do it = 0, ntimes-1, 6 ; TIME LOOP

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

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


    print("Working on time: " + times(it) )
    plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
 
    z   = wrf_user_getvar(a, "z",it)     ; grid point height
    p = wrf_user_getvar(a, "pressure", it)
    
    t   = wrf_user_getvar(a, "tk", it)
    t_out   = wrf_user_getvar(a1, "tk", it)
   

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 

 t_p = new((/nz,nr*360/),"float")
 t_po = new((/nz,nr*360/),"float")

 t_pave = new((/nz,nr/),"float")
 t_poave = new((/nz,nr/),"float")

 t_ano = new((/nz,nr/),"float")

 ;printVarSummary(t_p)
 ;printVarSummary(t_out)
 
 t_p = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
 t_pout = linint2_points(latout,lonout,t_out,False,lat_po,lon_po,1)
 
 ;printVarSummary(t_pout)

do lev = 0,nz-1
  do i = 0,nr-1

      sum_t = 0.0
      sum_tout = 0.0

      do j = 0,359,1
         
         sum_t = sum_t + t_p(lev,i*360+j)
         sum_tout = sum_tout + t_pout(lev,i*360+j)

      end do

      t_pave(lev,i)= sum_t/360.0
      t_poave(lev,i)= sum_tout/360.0
   
    end do

end do

if (it .eq. 0) then

  t_temp = t_poave(:,0:74)
  t_avg = dim_avg_n(t_poave, 1)

end if



do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(lev,i) = t_pave(lev,i)-t_avg(lev)
   
    end do

end do


  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   

 ;t_ano!0 = "height"
 t_ano!1 = "Radial"
 ;t_ano&height= z(:,50,50)/1000
 t_ano&Radial = r
 z@units = "km"
 ;print(w_ave&Press)

 
 t_anall(:,:,nmt) = t_ano
 nmt = nmt+1

 
 end do

 t_anall!2 = "time"
 t_anall&time = timee
 printVarSummary(t_anall)


 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  wks = gsn_open_wks("pdf","sim4/hhovv-r1-initial")
  gsn_define_colormap(wks, "MPL_coolwarm")

  plevels = (/2.0,4.0,6.0,8.0,10.0,12.0,14.0,16.0,18.0,20.0,22.0,24.0,26.0/)
  hlevels = fspan(0.0,27.5,68)

  res = True
  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = sprintf("%3.1f",plevels)
  ;res@tmYLValues  =  plevels
  ;res@trYMaxF     =  p(0,imin(it),jmin(it))+25.0
  ;res@trYMinF     =  80.0
  ;res@trXMinF     =  r(0)-2.5
  ;res@trXMaxF     =  r(49)+2.5
  ;res@tmYRTickSpacingF = 2
  
 
  ;res@tmXBMajorOutwardLengthF = 0.0
  ;;res@tmXBMajorLengthF        = 0.01 
  ;res@tmYLMajorOutwardLengthF = 0.0
  ;;res@tmYLMajorLengthF        = 0.01
  ;res@tmYRMajorOutwardLengthF = 0.0
  ;res@tmYRMajorLengthF        = 0.01
 
  res@tiYAxisString           = "Height(km)"
  res@tiXAxisString           = "times"
  res@tiYAxisFontHeightF      = 0.02
  res@tiXAxisFontHeightF      = 0.02
  ;@tmXBLabelFontHeightF    = 0.015
  ;res@tmYLLabelFontHeightF    = 0.015
  ;res@tmYRLabelFontHeightF    = 0.015
  ;res@gsnStringFontHeightF    = 0.015

  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False


;------------------------ temprature anomaly -------------------------------------

  res_temprature = res
  res_temprature@gsnLeftString  = "T Anomaly (K)"
  res_temprature@gsnRightString = " Hovmoller "
  res_temprature@cnFillOn = True
  res_temprature@cnLinesOn = True
  res_temprature@cnLineThicknessF  = 2.0
  res_temprature@gsnContourNegLineDashPattern  = 11
  res_temprature@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res_temprature@cnLevels     = (/ -2,-1.5, -1, -0.5, 0,  1, 2,  4,  6,  8, 10, 12,14/)   ; set levels
  res_temprature@cnFillColors = (/  2,   8, 16,   24,32,  0,90, 96,102,108,114,120,126,129/)  ; set the colors to be used
  ;res_temprature@cnLevelSelectionMode = "ManualLevels"
  ;res_temprature@cnLevelSpacingF   = 2

  ;res_temprature@cnLineLabelsOn    = True
  ;res_temprature@cnLineLabelPerimOn = True
  ;res_temprature@cnLineLabelPerimColor = -1
  res_temprature@cnLineLabelBackgroundColor = -1

    
 to =  t_anall(0:50,1,:)
 temp = gsn_csm_contour(wks,to,res_temprature) 
 
end




     
