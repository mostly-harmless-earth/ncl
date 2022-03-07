load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

   ;files = systemfunc("ls ./sim_lev100/angle/radial_wind*")
   ;a = addfiles(files, "r")
   ;ListSetType(a, "cat")
   ;radial360 = a[:]->wrad
   ;radial = dim_avg_n(radial360,3)

    ;delete(a)
    ;delete(radial360)

;outfilet = addfile("sim_lev100/angle/vr_azi.nc","c")
;outfilet->wrad = radial

   ;files = systemfunc("ls ./sim_lev100/angle/tangential_wind*")
   ;b = addfiles(files, "r")
   ;ListSetType(b, "cat")
   
   ;tangential360 = b[:]->wtan
   ;tangential = dim_avg_n(tangential360,3)

   ;delete(b)
   ;delete(tangential360)

;outfilet = addfile("sim_lev100/angle/vt_azi.nc","c")
;outfilet->wtan = tangential

   ;files1 = systemfunc("ls ./sim_lev100/angle/vertical_wind*")
   ;c = addfiles(files1, "r")
   ;ListSetType(c, "cat")

    ;wwnd360 = c[:]->ww
    ;wwnd = dim_avg_n(wwnd360,3)

    ;delete(c)
    ;delete(wwnd360)

;outfilet = addfile("sim_lev100/angle/azi_vertical.nc","c")
;outfilet->ww = wwnd

    ;d = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    ;t_d01 = d->th

    ;printVarSummary(t_d01)

    ;files = systemfunc("ls ./sim_lev100/angle/cirtano4*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ;t_ano_for1 = ano_h[:]->ta
    ;t_ano_for = dim_avg_n(t_ano_for1,3)

    ;t_ano_for = ano_h[:]->ta

    ;printVarSummary(t_ano_for1)

    ;t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    ;printVarSummary(t_ev)

    ;do lev = 0, 90
      ;do i = 0, 199

        ;t_ano_for(:,lev,i) = t_ano_for(:,lev,i)-t_ev(0,lev)
   
      ;end do
    ;end do

    ;dim = dimsizes(t_ano_for)

;outfilet = addfile("sim_lev100/angle/angle_t0_tano.nc","c")
;outfilet->ta = t_ano_for

  a = addfile("/user_home/jyyin/dta/sim_lev100/angle/vt_azi.nc.nc","r")
  tangential = a->wtan
   
  b = addfile("/user_home/jyyin/dta/sim_lev100/angle/vr_azi.nc.nc","r")
  radial = b->wrad
  
  c = addfile("/user_home/jyyin/dta/sim_lev100/angle/azi_vertical.nc","r")
  wwnd = c->ww

  d = addfile("/user_home/jyyin/dta/sim_lev100/angle/d7_t0_ta.nc","r")
  t_ano_for = d->ta

  radial = runave_n(radial, 5, 0, 1)
  radial = runave_n(radial, 5, 0, 2)
 
  tangential = runave_n(tangential, 5, 0, 1)
  tangential = runave_n(tangential, 5, 0, 2)

  wwnd = runave_n(wwnd, 5, 0, 1)
  wwnd = runave_n(wwnd, 5, 0, 2)

  nr = 200
  r = fspan(0.0,400.0,nr)
  print(r)
  hei = fspan(500, 27500, 100)/1000
  print(hei)

  dims = dimsizes(radial)
  print(dims)


  wks = gsn_open_wks("pdf","sim_lev100/wendu_allwind_d7")
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

  t_k = new(400,graphic)
  win = new(100,graphic)

  n = 1 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Time loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

do it = 6, dims(0)-7, 6

  aradial = dim_sum_n(radial(it-6:it+6,:,:), 0)/3.
  atangential = dim_sum_n(tangential(it-6:it+6,:,:), 0)/3.
  awwnd = dim_sum_n(wwnd(it-6:it+6,:,:), 0)/3.
  atha  = dim_sum_n(t_ano_for(it-6:it+6,:,:), 0)/3.

;------------------------ radial wind --------------------------------------------------

  res_radial = res
  res_radial@gsnLeftString  = "Temprature Anomaly (shading,K) ~C~Vr(contour,black) ~C~W(contour,green)"
  res_radial@gsnRightString = " ~C~-0.2,-0.5,-0.8,-1.5,1,3,5,7,11,15,20,25 ~C~-0.1,-0.01,0.1,0.25,2" 
  res_radial@cnFillOn = False
  res_radial@cnLinesOn = True

  res_radial@gsnContourNegLineDashPattern  = 11
  res_radial@cnLineColor  =  "black"

  res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1

  ;res_radial@cnHighLabelsOn = True
  ;res_radial@cnLowLabelsOn  = True
  ; res_radial@cnLevelSelectionMode = "AutomaticLevels"

   pores = res_radial
   pores@cnLevelSelectionMode = "ExplicitLevels"
   ;pores@cnLevels = (/ 0.2,0.5,0.8,1,3,5,7,9,11,15,20/)   ; set levels
   pores@cnLevels = (/ 1,3,5,7,11,15,20,25/)   ; set levels
   
   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = 0.0
   ;res_radial@cnMaxLevelValF   = 20.0
   ;if (it.le.181) then
     ;res_radial@cnLevelSpacingF   = 0.5
   ;else
     ;res_radial@cnLevelSpacingF   = 1.5
   ;end if
   poradial_wind= gsn_csm_contour(wks,aradial(34:63,0:199),pores)
   poradial_wind1= gsn_csm_contour(wks,aradial(34:63,0:199),pores)

   neres = res_radial
   neres@cnLevelSelectionMode = "ExplicitLevels"
   ;neres@cnLevels = (/ -0.1,-0.2,-0.3,-0.5,-1,-3,-5/)   ; set levels
   neres@cnLevels = (/ -0.2,-0.5,-0.8,-1.5/)

   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = -15.
   ;res_radial@cnMaxLevelValF   = 0.0
   ;if (it.le.430) then
     ;res_radial@cnLevelSpacingF   = 0.15
   ;else
     ;res_radial@cnLevelSpacingF   = 0.8
   ;end if
   neradial_wind= gsn_csm_contour(wks,aradial(34:63,0:199),neres)
   neradial_wind1= gsn_csm_contour(wks,aradial(34:63,0:199),neres)

   zeres = res_radial
   zeres@cnLevelSelectionMode = "ExplicitLevels"
   zeres@cnLevels = (/ 0.0 /)   ; set levels
   zeres@cnLineThicknessF  = 1.6
   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = -15.
   ;res_radial@cnMaxLevelValF   = 0.0
   ;if (it.le.430) then
     ;res_radial@cnLevelSpacingF   = 0.15
   ;else
     ;res_radial@cnLevelSpacingF   = 0.8
   ;end if
   zeradial_wind= gsn_csm_contour(wks,aradial(34:63,0:199),zeres)
   zeradial_wind1= gsn_csm_contour(wks,aradial(34:63,0:199),zeres)
   
;------------------------ tangential wind --------------------------------------------------
  res_tan = res
  res_tan@cnFillOn = False
  res_tan@cnLinesOn = True
  ;res_tan@gsnLeftString  = "Vertical wind speed (contour,green) ~C~Tangential wind Speed (contour,red) ~C~"
  ;res_tan@gsnRightString =  it
  res_tan@gsnContourNegLineDashPattern  = 11
  res_tan@cnLineColor  =  18
  
  res_tan@cnLevelSelectionMode = "ManualLevels"
  ;res_tan@cnLevelSelectionMode = "AutomaticLevels"
  res_tan@cnMinLevelValF = -10.
  res_tan@cnMaxLevelValF   = 80.
  ;res_tan@cnLevelSpacingF   = 8.

  res_tan@tmXBMode    = "Explicit"
  res_tan@tmXBValues  = (/0, 50,100,150,199/)
  res_tan@tmXBLabels  = (/0,100,200,300,400/)

  res_tan@tmYLMode    = "Explicit"
  res_tan@tmYLValues  = (/0, 17,35,53,60/)
  res_tan@tmYLLabels  = (/0.5,5,10,15,17/)
  
  tangential_wind= gsn_csm_contour(wks,atangential(0:63,0:199),res_tan)

;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  res_w = res
  res_w@gsnFrame  = False
  res_w@gsnDraw   = False

  res_w@cnLineColor  =  "green"
  res_w@cnFillOn = False
  res_w@cnLinesOn = True
  
  res_w@cnLevelSelectionMode = "ExplicitLevels"
  res_w@cnLevels = (/-0.1,-0.01,0.1,0.25,1,2,3,4/)   ; set levels

  res_w@gsnContourNegLineDashPattern  = 11
  ;res_w@cnLineLabelsOn    = True
  ;res_w@cnLineLabelBackgroundColor = -1
  ;res_w@cnMaxLevelValF   = 0.
  ;res_w@cnMinLevelValF   = -5.
  ;res_w@cnLevelSpacingF = 3.
  res_w@cnLineThicknessF  = 1.0
  
  w_wind = gsn_csm_contour(wks,awwnd(34:63,0:199),res_w) 
  w_wind1 = gsn_csm_contour(wks,awwnd(34:63,0:199),res_w) 

;--------------------------------------------------------------------------------
  res_t = res

  res_t@gsnFrame = False
  res_t@gsnDraw  = False

  res_t@gsnLeftString  = " "
  res_t@gsnRightString  = " "
  
  time = (it*10)/60./24.
  ;res_t@tiYAxisString = "Day  " + (time-1) + " - " + time
  res_t@tiMainString  = "T = "+ it*10/60. +" h" 

  res_t@tmYLMode    = "Explicit"
  res_t@tmYLValues  = (/0, 7, 14,21,28/)
  res_t@tmYLLabels  = (/10,12,14,16,18/)

  res_t@tmXBMode    = "Explicit"
  res_t@tmXBValues  = (/0, 50,100,150,199/)
  res_t@tmXBLabels  = (/0,100,200,300,400/)

    ;res_t@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    ;if (it.le.164) then
        ;res_t@cnLevelSpacingF = 0.05
        ;res_t@cnMinLevelValF  = -0.7
        ;res_t@cnMaxLevelValF  = 0.7
      ;else if (it.le.430) then
       ; res_t@cnLevelSpacingF = 0.8
       ; res_t@cnMinLevelValF  = -6.
       ; res_t@cnMaxLevelValF  = 6.
      ;else
          ;res_t@cnLevelSpacingF = 1.2
          ;res_t@cnMinLevelValF  = -12
          ;res_t@cnMaxLevelValF  = 12       
      ;end if
    ;end if



  res_t@cnFillOn = True
  res_t@cnLinesOn = False
  res_t@lbLabelBarOn        = False           ; turn off individual cb's
  ;res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
 ; res_t@cnLevels     = (/ -4, -3,-2,-1,-0.5,-0.3,0.3,0.5,  1,3 ,  5,  7,  9,13/)   ; set levels
  ;res_t@cnFillColors = (/  2,  8,16,26,  32,  40,  0, 75, 83,95,106,112,120,126,129/)  ; set the colors to be used
  res_t@cnLineLabelsOn = False                    ; turn the line labels off

  ;print(n)

  ;res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res_t@cnLevels     = (/-1.5,-1.2,-0.9,-0.6,-0.3,-0.05,0, 0.05,0.3,0.6,0.9,1.2,1.5,1.8/)   ; set levels
  ;res_t@cnFillColors = (/ 120, 110, 100,  90,  82,  73,  65,64,   60, 50, 40, 30, 20, 10, 9/)  ; set the colors to be used


  ;dtdh = new((/91,200/), float)
  ;do ih = 0, 80
    ;dtdh(ih,:) = atha(ih+2,:)-atha(ih,:)
  ;end do
  
  ;t_gr = gsn_csm_contour(wks,dtdh(34:63,0:199),res_t) 
  
  res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res_t@cnLevels     = (/ -5, -4, -3,-2,-1,-0.5,0, 1, 3, 5, 7, 9,11, 13,15 /)   ; set levels
  res_t@cnFillColors = (/120,115,110,100,90,82,73,65,60,50,40,30,20, 10, 9,8/)  ; set the colors to be used

  t_pl = gsn_csm_contour(wks,atha(34:63,0:199),res_t) 
  

;--------------------------------------------------------------------------------

  
  t_k(n) = t_pl
  ;t_k(n+1) = t_gr
  t_k(n+1) = tangential_wind
  
  overlay(t_k(n), poradial_wind)
  overlay(t_k(n), neradial_wind)
  ;overlay(t_k(n), zeradial_wind)
  overlay(t_k(n), tangential_wind)
  overlay(t_k(n), w_wind)
  ;overlay(t_k(n+1), poradial_wind1)
  ;overlay(t_k(n+1), neradial_wind1)
  ;overlay(t_k(n+1), zeradial_wind1)
  ;overlay(t_k(n+1), w_wind1)

  ;t_k(n+4) = gsn_csm_contour(wks,t_ano(it,0:62,0:199),res_t) 
  ;overlay(t_k(n+4), w_wind)

  n = n+1

end do
  
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@lbOrientation        = "Vertical"
  
  gsn_panel(wks, t_k(0:23), (/6,4/), gres_ta)
  gsn_panel(wks, t_k(24:47), (/6,4/), gres_ta)
  gsn_panel(wks, t_k(48:71), (/6,4/), gres_ta)
  gsn_panel(wks, t_k(72:95), (/6,4/), gres_ta)
  gsn_panel(wks, t_k(96:119), (/6,4/), gres_ta)
  gsn_panel(wks, t_k(120:143), (/6,4/), gres_ta)
  gsn_panel(wks, t_k(144:167), (/6,4/), gres_ta)

  ;--------------------------------------------------------------------------------
  ;do it = 0,49,5

    ;pls =new(3, graphic)

    ;pls(0) = gsn_csm_contour(wks, radial(it,:,0:199), res)
    ;pls(1) = gsn_csm_contour(wks, tangential(it,:,0:199), res)
    ;pls(2) = gsn_csm_contour(wks, wwnd(it,:,0:199), res)
  

    ;res@tiLeftString         = "Streamline"
    ;res@stArrowLengthF       = 0.015         ; changes the size of the arrows.
    ;res@stLevelSelectionMode = "ManualLevels"
    ;res@stLevelSpacingF      = 1000
    ;res@stLineThicknessF     = 1.5           ; changes the line thickness
    ;res@stLineColor          = "Black"      ; changes color
    ;pls(3) = gsn_csm_streamline(wks, radial(1000,0:41,:), wwnd(1000,0:41,:)*10, res)

    ;mres = True
    ;mres@gsnPanelLabelBar    = True                ; add common colorbar
    ;mresP@lbLabelFontHeightF  = 0.007               ; make labels smaller
    ;gsn_panel(wks, pls(:), (/1,3/), mres)

  ;end do

end