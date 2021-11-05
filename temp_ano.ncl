load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  a1 = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
         
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  ;print(mdims)
  nd = dimsizes(mdims)
  FirstTime = True
  wks = gsn_open_wks("pdf","sim4/temprature-anomally")
  gsn_define_colormap(wks, "MPL_coolwarm")
;---------------------------------------------------------------
 
  do it = 0,ntimes-1,12; TIME LOOP

    print("Working on time: " + times(it) )
    plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
 
    z   = wrf_user_getvar(a, "z",it)     ; grid point height
    p = wrf_user_getvar(a, "pressure", it)
    t   = wrf_user_getvar(a, "tk", it)
    t_out   = wrf_user_getvar(a1, "tk", it)
    ;printVarSummary(t_out)
  

    lat = ispan( 0, 1434, 6)
    lon = ispan( 0, 1434, 6)
    
    nx = dimsizes(lat)
    lat@units = "km"
    lon@units=  "km"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

    imin = 120
    jmin = 120
;;-----------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 180
  r = fspan(0.0,700.0,nr)
  ;print(r)
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

;  print(lon_p(::360))

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 nz = mdims(1)  ; Sigma levels

 t_p = new((/nz,nr*360/),"float")
 t_pave = new((/nz,nr/),"float")
 t_ano = new((/nz,nr/),"float")


 t_p = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
 t_avg_mid = dim_avg_n(t_out, 2)
 t_avg = dim_avg_n(t_avg_mid, 1)
 ;printVarSummary(t_avg)

do lev = 0,nz-1
  do i = 0,nr-1

      sum_t = 0.0

      do j = 0,359,1
         
         sum_t = sum_t + t_p(lev,i*360+j)

      end do

      t_pave(lev,i)= sum_t/360.0
      t_ano(lev,i)=t_pave(lev,i) - t_avg(lev)
   
    end do

end do

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   

 t_ano!0 = "Press"
 t_ano!1 = "Radial"
 t_ano&Press= p(:,imin,jmin)
 t_ano&Radial = r
 r@units = "km"
 ;print(w_ave&Press)

 ;printVarSummary(t_ano)
 
 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  

  plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
  hlevels = fspan(0.0,25.0,50)

  res = True
  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = r
  ;res@tmXBLabels  = sprintf("%4.1f",r)
  res@tmYLMode    = "Explicit"
  res@tmYLLabels  = sprintf("%4.1f",plevels)
  res@tmYLValues  =  plevels
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
 
  res@tiYAxisString           = "Pressure(hpa)"
  res@tiXAxisString           = "Radius (km)"
  res@tiYAxisFontHeightF      = 0.02
  res@tiXAxisFontHeightF      = 0.02
  ;@tmXBLabelFontHeightF    = 0.015
  ;res@tmYLLabelFontHeightF    = 0.015
  ;res@tmYRLabelFontHeightF    = 0.015
  ;res@gsnStringFontHeightF    = 0.015

  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False


  
 

;------------------------ radial wind --------------------------------------------------

  res_temprature = res
  res_temprature@gsnLeftString  = "Temprature Anomaly (K)"
  res_temprature@gsnRightString = "Times:"+times(it)
  res_temprature@cnFillOn = True
  res_temprature@cnLinesOn = True
  res_temprature@cnLineThicknessF  = 2.0
  res_temprature@gsnContourNegLineDashPattern  = 11
  ;res_temprature@cnLevelSelectionMode = "ManualLevels"
  ;res_temprature@cnLevelSpacingF   = 2

  ;res_temprature@cnLineLabelsOn    = True
  ;res_temprature@cnLineLabelPerimOn = True
  ;res_temprature@cnLineLabelPerimColor = -1
  res_temprature@cnLineLabelBackgroundColor = -1

  ;res_temprature@cnHighLabelsOn = True
  ;res_temprature@cnLowLabelsOn  = True
    
   
  radial_wind = gsn_csm_pres_hgt(wks,t_ano,res_temprature) 
;--------------------------------------------------------------------------------------


end do

end




     
