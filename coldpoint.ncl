load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.


  a = addfile("/user_home/jyyin/dta/sim_lev100/tk/hgtoflapsrate_avg.nc","r")
  alti = a->alti

  d = addfile("/user_home/jyyin/dta/sim_lev100/angle/angle_t0_tano.nc","r")
  t_ano_for = d->ta

  nr = 200
  r = fspan(0.0,400.0,nr)
  print(r)
  hei = fspan(500, 27500, 100)/1000
  print(hei)

  dims = dimsizes(t_ano_for)
  print(dims)

  wks = gsn_open_wks("pdf","sim_lev100/laps-avg-time")
  gsn_define_colormap(wks, "MPL_RdBu")
  ;gsn_reverse_colormap(wks)

  res = True
  res@cnFillOn = True
  res@cnLinesOn = False

  res@gsnFrame = False
  res@gsnDraw  = False

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.4            ; make plot as large as possible.

  res@cnInfoLabelOn = False

  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ;res@cnLevels     = (/ -2,-1.5, -1,-0.5, 0, 0.5,1.5, 3, 5,  7,  9, 11, 13/)   ; set levels
  ;res@cnFillColors = (/  2,   8, 16,  24, 32, 0, 80,90,93,  96, 108,120,126,129/)  ; set the colors to be used

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 
  ;res@tmXBMajorOutwardLengthF = 0.0
  ;;res@tmXBMajorLengthF        = 0.01 
  ;res@tmYLMajorOutwardLengthF = 0.0
  ;;res@tmYLMajorLengthF        = 0.01
  ;res@tmYRMajorOutwardLengthF = 0.0
  ;res@tmYRMajorLengthF        = 0.01
 
  ;res@tiYAxisString           = "height(km)"
  ;res@tiXAxisString           = "Radius (km)"
  res@tiYAxisFontHeightF      = 0.02
  res@tiXAxisFontHeightF      = 0.02
  res@tmXBLabelFontHeightF    = 0.015
  res@tmYLLabelFontHeightF    = 0.015
  res@tmYRLabelFontHeightF    = 0.015
  res@gsnStringFontHeightF    = 0.015
  
  res@cnLineThicknessF  = 1.0
  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False

  t_k = new(100,graphic)
  win = new(100,graphic)

  n = 0 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Time loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

do it = 0, dims(0)-143, 144

  acp = dim_sum_n(alti(it:it+143,:), 0)/24.-34
  atha  = dim_sum_n(t_ano_for(it:it+143,:,:), 0)/24.

;--------------------------------------------------------------------------------
;---------------------- cold point tropopause -----------------------------------

  res_al = True

  res_al@gsnFrame = False
  res_al@gsnDraw  = False

  res_al@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res_al@vpHeightF        = 0.4            ; make plot as large as possible.

  res_al@xyLineColor = "green"
  res_al@xyLineThicknessF = 1.5

  al = gsn_csm_y(wks,acp,res_al)

;--------------------------------------------------------------------------------
  res_t = res

  res_t@gsnFrame = False
  res_t@gsnDraw  = False

  res_t@gsnLeftString  = " "
  res_t@gsnRightString  = " "
  
  time = (it*10)/60./24.
  res_t@tiYAxisString = "Day  " + time + " - " + (time+1)
  ;res_t@tiMainString  = "T = "+ it*10/60. +" h" 

  res_t@tmYLMode    = "Explicit"
  res_t@tmYLValues  = (/0, 7, 14,21,28/)
  res_t@tmYLLabels  = (/10,12,14,16,18/)

  res_t@tmXBMode    = "Explicit"
  res_t@tmXBValues  = (/0, 50,100,150,199/)
  res_t@tmXBLabels  = (/0,100,200,300,400/)


  res_t@cnFillOn = True
  res_t@cnLinesOn = False
  res_t@lbLabelBarOn        = False           ; turn off individual cb's
  ;res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
 ; res_t@cnLevels     = (/ -4, -3,-2,-1,-0.5,-0.3,0.3,0.5,  1,3 ,  5,  7,  9,13/)   ; set levels
  ;res_t@cnFillColors = (/  2,  8,16,26,  32,  40,  0, 75, 83,95,106,112,120,126,129/)  ; set the colors to be used
  res_t@cnLineLabelsOn = False                    ; turn the line labels off
  
  res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res_t@cnLevels     = (/ -5, -4, -3,-2,-1,-0.5, 1, 3, 5, 7, 9,11, 13,15 /)   ; set levels
  res_t@cnFillColors = (/120,110,100,90,82,73,65,60,50,40,30,20, 10, 9,8/)  ; set the colors to be used

  t_pl = gsn_csm_contour(wks,atha(34:63,0:199),res_t) 
  

;--------------------------------------------------------------------------------

  t_k(n) = t_pl
  ;t_k(n+1) = tangential_wind
  
  overlay(t_k(n), al)
 
  n = n+1

end do
  
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@lbOrientation        = "Vertical"
  gres_ta@txString = "cold point tropopause"
  
  gsn_panel(wks, t_k(0:4), (/2,2/), gres_ta)
  ;gsn_panel(wks, t_k(8:15), (/4,2/), gres_ta)
  ;gsn_panel(wks, t_k(16:32), (/4,4/), gres_ta)
  ;gsn_panel(wks, t_k(32:47), (/4,4/), gres_ta)
  ;gsn_panel(wks, t_k(48:60), (/4,4/), gres_ta)
  ;gsn_panel(wks, win(6:13), (/4,4/), gres_ta)
  ;gsn_panel(wks, win(14:21), (/4,4/), gres_ta)

  ;--------------------------------------------------------------------------------

  gsn_define_colormap(wks,"amwg256")

  colorr = ispan(0, 254, 1)
  ares = True
  ares@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  ares@vpHeightF        = 0.4            ; make plot as large as possible.

  ares@xyLineThicknessF = 2.0
  ares@xyLineColors     = colorr(::20); colors chosen
  ares@xyDashPatterns   = 0.      ; make all lines solid

  ;ares@trYMinF          = 52.           ; Set min/max of left Y axis
  ;ares@trYMaxF          = 66.


  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 7, 14,21,28/)
  ;ares@tmYLLabels  = (/10,12,14,16,18/)

  cp = alti
  cp = runave_n(cp, 3, 0, 1)
  ;pk = new(100,graphic)

  do it = 0, dims(0)-73,72

    cp(it,:) = dim_sum_n(alti(it:it+72,:), 0)/12.
    
  end do

pk = gsn_csm_y(wks,cp(::72,:),ares)


end