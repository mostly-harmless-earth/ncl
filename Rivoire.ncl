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

  wks = gsn_open_wks("pdf","sim4/Rivoire-Nowind")
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
 
  do it = 100 , 100 , 6; TIME LOOP

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

 nz = mdims(1)  ; Sigma levels

 u_p = new((/nz,nr*360/),"float") 
 v_p = new((/nz,nr*360/),"float")
 w_p = new((/nz,nr*360/),"float")
 
 t_p = new((/nz,nr*360/),"float")
 t_po = new((/nz,nr*360/),"float")

 t_pave = new((/nz,nr/),"float")
 t_poave = new((/nz,nr/),"float")

 t_ano = new((/nz,nr/),"float")

 tangential_ave = new((/nz,nr/),"float")
 radial_ave = new((/nz,nr/),"float")
 w_ave = new((/nz,nr/),"float")


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

      tangential_ave(lev,i)= sum_t/360.0
      radial_ave(lev,i) = sum_r/360.0
      w_ave(lev,i)= sum_w/360.0
      t_pave(lev,i)= sum_te/360.0
      t_poave(lev,i)= sum_tout/360.0
   
    end do
end do

t_temp = t_poave(:,100:149)
t_avg = dim_avg_n(t_temp, 1)

do lev = 0,nz-1
  do i = 0,nr-1

    t_ano(lev,i) = t_pave(lev,i)-t_avg(lev)
   
    end do
end do

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   

 t_ano!0 = "Press"
 t_ano!1 = "Radial"
 t_ano&Press= p(:,imin,jmin)
 t_ano&Radial = r
 r@units = "km"

 tangential_ave!0 = "Press"
 tangential_ave!1 = "Radial"
 tangential_ave&Press = p(:,imin,jmin)
 tangential_ave&Radial = r

 radial_ave!0 = "Press"
 radial_ave!1 = "Radial"
 radial_ave&Press= p(:,imin,jmin)
 radial_ave&Radial = r

 w_ave!0 = "Press"
 w_ave!1 = "Radial"
 w_ave&Press= p(:,imin,jmin)
 w_ave&Radial = r

 t_ano!0 = "Press"
 t_ano!1 = "Radial"
 t_ano&Press= p(:,imin,jmin)
 t_ano&Radial = r

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
  hlevels = fspan(0.0,25.0,50)

  res = True
  res@gsnFrame = False
  res@gsnDraw  = False

  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = r
  ;res@tmXBLabels  = sprintf("%4.1f",r)
  res@tmYLMode    = "Explicit"
  res@tmYLLabels  = sprintf("%4.1f",plevels)
  res@tmYLValues  =  plevels
  res@gsnRightString = "T = "+it+" h"
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
  res@tmXBLabelFontHeightF    = 0.015
  res@tmYLLabelFontHeightF    = 0.015
  res@tmYRLabelFontHeightF    = 0.015
  res@gsnStringFontHeightF    = 0.015

  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False

;------------------------ radial wind --------------------------------------------------

  res_radial = res
  res_radial@gsnLeftString  = "Temprature Anomaly (shading,K) ~C~Tangential wind Speed (contour,black)"
  res_radial@gsnRightString = "T = "+it+" h"
  res_radial@cnFillOn = False
  res_radial@cnLinesOn = True
  res_radial@cnLineThicknessF  = 1.0
  res_radial@gsnContourNegLineDashPattern  = 11
  res_radial@cnLineColor  =  "gray"
  res_radial@cnLevelSelectionMode = "ManualLevels"

  res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1

  
   res_radial@cnLevelSpacingF  = 10
   tangential_wind= gsn_csm_pres_hgt(wks,tangential_ave(22:58,0:135),res_radial)

;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  res_w = res
  res_w@gsnFrame  = False
  res_w@gsnDraw   = False

  res_w@cnLineColor  =  "red"
  res_w@cnFillOn = False
  res_w@cnLinesOn = True
  res_w@cnLineThicknessF  = 2.0
  res_w@cnLevelSelectionMode = "ManualLevels"
  res_w@cnLineLabelsOn    = True
  res_w@cnLineLabelBackgroundColor = -1
  res_w@cnMaxLevelValF   = 20
  res_w@cnMinLevelValF   = 0.
  res_w@cnLevelSpacingF = 0.02
  
  ;w_wind = gsn_csm_pres_hgt(wks,w_ave(0:50,0:120),res_w) 

;--------------------------------------------------------------------------------
  res_t = True

  res_t@gsnFrame = False
  res_t@gsnDraw  = False

  
  res_t@cnFillOn = True
  res_t@cnLinesOn = False
  res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res_t@cnLevels     = (/ -4, -3,-2,-1,-0.5,0.5,  1,3  ,  5,  7, 9/)   ; set levels
  res_t@cnFillColors = (/  2,  8,16,26,  40,  0,75,106,112,120, 126,129/)  ; set the colors to be used
  res_t@cnLineLabelsOn = False                    ; turn the line labels off

  t_k = gsn_csm_pres_hgt(wks,t_ano(22:58,0:135),res_t) 
;--------------------------------------------------------------------------------

  ;overlay(t_k, tangential_wind)
  draw(t_k)
  frame(wks)
end do

end




     
