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
;---------------------------------------------------------------
 
  do it = 159,159,1 ; TIME LOOP

    ;tn = (/47,71,119,167/)
    ;print(it)         
 
    print("Working on time: " + times(it) )
 
    z   = wrf_user_getvar(a, "z",it)     ; grid point height
    p   = wrf_user_getvar(a,"pressure",it)
    t   = wrf_user_getvar(a, "T", it)
    u   = wrf_user_getvar(a,"ua",it)
    v   = wrf_user_getvar(a,"va",it)
    w   = wrf_user_getvar(a,"wa",it)

    lat = ispan( 0, 1434, 6)
    lon = ispan( 0, 1434, 6)
    
    ;print(lat)
    ;print(xx)
    
    nx = dimsizes(lat)
    lat@units = "km"
    lon@units=  "km"

   ; printVarSummary(z)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------
    imin = 120
    jmin = 120
;;-----------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 150
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

  ;le = 11423.37
  ;k  = 0.7156
  ;print(it)
  ;fi0 = imin(it)*degtorad
  ;theta0 = jmin(it)*degtorad

  ;l0 =((1-sin(fi0))/(sin(fi0)+1))^(k/2)*le
  ;print(l0)
  

  lat_p = new(nr*360,"float")
  lon_p = new(nr*360,"float")


    do i = 0, nr-1, 1
      do j = 0, 359, 1
 
       ;NB = l0-dy(i,j)
       ;lp = sqrt(NB^2+dx(i,j)^2)
       ;sin_fi = (le^(2/k)-lp^(2/k))/(le^(2/k)+lp^(2/k))
       ;lat_p(i*360+j) = radtodeg*asin(sin_fi)
       lat_p(i*360+j) = lat(imin) + dx(i,j)

       ;dtheta = radtodeg*asin(dx(i,j)/lp)
       ;dtheta = dtheta/k
       ;lon_p(i*360+j)= dtheta+jmin(it)
       lon_p(i*360+j) = lon(jmin) + dy(i,j)
      end do
    end do

;  print(lon_p(::360))

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;; interp to pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 nz = mdims(1)  ; Sigma levels

 u_p = new((/nz,nr*360/),"float") 
 v_p = new((/nz,nr*360/),"float")
 w_p = new((/nz,nr*360/),"float")
 t_p = new((/nz,nr*360/),"float")
 p_p = new((/nz,nr*360/),"float")

; tangential = new(151*360,"float")
; radial = new(151*360,"float")

 tangential_ave = new((/nz,nr/),"float")
 radial_ave = new((/nz,nr/),"float")
 w_ave = new((/nz,nr/),"float")
 t_ave = new((/nz,nr/),"float")
 p_ave = new((/nz,nr/),"float")

;printVarSummary(u)
;ii = imin(it)
;jj = jmin(it)
;latp = lat_p(16950:17000)
;print(ii)
;print(jj)
;print(latp)

  u_p = linint2_points(lat,lon,u,False,lat_p,lon_p,1)
  v_p = linint2_points(lat,lon,v,False,lat_p,lon_p,1)
  w_p = linint2_points(lat,lon,w,False,lat_p,lon_p,1)
  t_p = linint2_points(lat,lon,t,False,lat_p,lon_p,1)
  p_p = linint2_points(lat,lon,p,False,lat_p,lon_p,1)

  ;printVarSummary(u_p)


do lev = 0,nz-1
  do i = 0,nr-1

      sum_t = 0.0
      sum_r = 0.0
      sum_w = 0.0
      sum_tk = 0.0
      sum_p = 0.0

      do j = 0,359,1
         tangential= -u_p(lev,i*360+j)*sin(alfa(j))+v_p(lev,i*360+j)*cos(alfa(j))
         radial= u_p(lev,i*360+j)*cos(alfa(j))+v_p(lev,i*360+j)*sin(alfa(j))

         sum_t = sum_t + tangential
         sum_r = sum_r + radial
         sum_w = sum_w + w_p(lev,i*360+j)
         sum_tk = sum_tk + t_p(lev,i*360+j)
         sum_p = sum_p + p_p(lev,i*360+j)

      end do

      tangential_ave(lev,i)= sum_t/360.0
      radial_ave(lev,i) = sum_r/360.0
      w_ave(lev,i)= sum_w/360.0
      t_ave(lev,i)= sum_tk/360.0
      p_ave(lev,i)= sum_p/360.0
   end do

end do



  ;print(w_ave(15,:))
  ;printVarSummary(tangential_ave)
  ;printVarSummary(w_ave)
  r@units = "km"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 print(p_ave(:,0))
 p_ave@units = "hpa"
 
 tangential_ave!0 = "Press"
 tangential_ave!1 = "Radial"
 tangential_ave&Press = p_ave(:,0)
 tangential_ave&Radial = r

 radial_ave!0 = "Press"
 radial_ave!1 = "Radial"
 radial_ave&Press= p_ave(:,0)
 radial_ave&Radial = r

 

 w_ave!0 = "Press"
 w_ave!1 = "Radial"
 w_ave&Press= p_ave(:,0)
 w_ave&Radial = r

 t_ave!0 = "Press"
 t_ave!1 = "Radial"
 t_ave&Press= p_ave(:,0)
 t_ave&Radial = r
 ;print(w_ave&Press)
 
 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  wks = gsn_open_wks("pdf","sim4/wind-vertical_160h")
  gsn_define_colormap(wks, "MPL_coolwarm")

  ;plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0/)
  hlevels = fspan(0.0,25.0,50)

  res = True
  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = r
  ;res@tmXBLabels  = sprintf("%4.1f",r)
  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = sprintf("%4.1f",plevels)
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

  res_radial = res
  res_radial@gsnLeftString  = "Radial Wind (m/s)"
  res_radial@gsnRightString = "Times:"+times(it)
  res_radial@cnFillOn = True
  res_radial@cnLinesOn = True
  res_radial@cnLineThicknessF  = 2.0
  res_radial@gsnContourNegLineDashPattern  = 11
  ;res_radial@cnLevelSelectionMode = "ManualLevels"
  ;res_radial@cnLevelSpacingF   = 2

  ;res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1

  ;res_radial@cnHighLabelsOn = True
  ;res_radial@cnLowLabelsOn  = True
    
   
   radial_wind = gsn_csm_pres_hgt(wks,radial_ave(:,0:100),res_radial) 
   ;
;--------------------------------------------------------------------------------------

;---------------------- tangential wind ----------------------------------------------

  res_tan = res_radial
  ;res_tan@gsnFrame  = False
  ;res_tan@gsnDraw   = False
  res_tan@gsnLeftString = "Tangential Wind (m/s)"
  ;res_tan@cnLevelSpacingF = 2

   tangential_wind = gsn_csm_pres_hgt(wks,tangential_ave(:,0:100),res_tan) 
   ;
;---------------------------------------------------------------------------------------

;---------------------- w wind ----------------------------------------------

  res_w = res_radial
  ;res_w@gsnFrame  = False
  ;res_w@gsnDraw   = False
  res_w@gsnLeftString = "W (m/s)"
  ;res_w@cnLevelSpacingF = 0.3

  w_wind = gsn_csm_pres_hgt(wks,w_ave(:,0:100),res_w) 
;---------------------------------------------------------------------------------------
;---------------------- temprature ----------------------------------------------

  res_t = True
  ;res_w@gsnFrame  = False
  ;res_w@gsnDraw   = False
  res_t@cnFillOn = True
  res_t@gsnLeftString = "temprature Average"
  ;res_w@cnLevelSpacingF = 0.3

  t_k = gsn_csm_pres_hgt(wks,t_ave(:,0:100),res_t) 
;---------------------------------------------------------------------------------------
   
end do

end




     
