load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    files1 = systemfunc("ls ./sim_lev100/bud/cal/radvm*")
    ano_h1 = addfiles(files1, "r")
    ListSetType(ano_h1, "cat")
    radvm = ano_h1[:]->radvm(:,0:90,:)

    files1 = systemfunc("ls ./sim_lev100/bud/cal/radve*")
    ano_h1 = addfiles(files1, "r")
    ListSetType(ano_h1, "cat")
    radve = ano_h1[:]->radve(:,0:90,:)

    files1 = systemfunc("ls ./sim_lev100/bud/cal/vadvm*")
    ano_h1 = addfiles(files1, "r")
    ListSetType(ano_h1, "cat")
    vadvm = ano_h1[:]->vadvm(:,0:90,:)

    files1 = systemfunc("ls ./sim_lev100/bud/cal/vadve*")
    ano_h1 = addfiles(files1, "r")
    ListSetType(ano_h1, "cat")
    vadve = ano_h1[:]->vadve(:,0:90,:)

    b = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/vr_azi.nc.nc","r")
    radial = b->wrad
  
    c = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/azi_vertical.nc","r")
    wwnd = c->ww

    madv = radvm +vadvm
    eadv = radve +vadve

    wks=gsn_open_wks("pdf","sim_lev100/wang_fig_78_cal") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 10min 
    ;;; 1h: 6 ;;; 2h: 12

    n = 0
    dims = dimsizes(vadve)

    ip = 0
    ni = 0
    plot7 = new(8,graphic)
    plot8 = new(8,graphic)

    do i = 0,3,1

    timi = (/198,276,396,492/) ;;;33h, 46h, 66h, 82h
    dtg  = (/29,59,119,59/)
    
    it = timi(i)
    dt = dtg(i)
    
    nmin = 10*60

    madv_1h = dim_sum_n(madv(it:it+dt,:,:), 0)
    eadv_1h = dim_sum_n(eadv(it:it+dt,:,:), 0)
    radvm_1h = dim_sum_n(radvm(it:it+dt,:,:), 0)
    vadvm_1h = dim_sum_n(vadvm(it:it+dt,:,:), 0)

  gres                    = True
  
  time1 = it*10/60.
  time2 = (it+dt+1)*10/60.

  ares = True
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame
  
  ares@vpWidthF           = .6
  ares@vpHeightF          = .4
  
  ;ares@tiXAxisString           = "Radius(km)"
  ;ares@tiYAxisString           = "height(km)"
  ares@cnFillOn                = True
  ares@cnLinesOn               = False 

  ;ares@tmXMajorGrid          = True               ; Add white grid lines
  ;ares@tmXMajorGridLineColor = "gray"
  ;ares@tmYMajorGrid          = True
  ;ares@tmYMajorGridLineColor = "gray"

  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025

  ;ares@cnLevelSelectionMode = "AutomaticLevels"

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 17,35,53,60/)
  ;ares@tmYLLabels  = (/0.5,5,10,15,17/)

  ares@tmYLMode    = "Explicit"
  ares@tmYLValues  = (/0, 7, 14,21,28/)
  ares@tmYLLabels  = (/10,12,14,16,18/)

  ares@tmXBMode    = "Explicit"
  ares@tmXBValues  = (/0, 40, 80, 120,160,199/)
  ares@tmXBLabels  = (/0, 80, 160,240,320,400/)

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-10,-0.8,-0.6,-0.4,-0.2, 0,   2,  4,  6,  8,10/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,149,152,167,183,199,215/)  ; set the colors to be used

  ;ares@lbLabelBarOn        = False           ; turn off individual cb's
  ;ares@lbOrientation        = "Vertical"
  ;ares@tiMainString = "Total Advection"
  ;plot9(0) = gsn_csm_contour(wks,t_adv_1h(11:41,:)*720, ares)

  ares@cnLineLabelsOn = False
  ares@lbLabelBarOn   = False 
  ares@cnInfoLabelOn = False

  delete(ares@gsnRightString)
  delete(ares@gsnLeftString)
;------------------------ radial wind --------------------------------------------------
  
  aradial = dim_avg_n(radial(it-6:it+6,:,:), 0)
  
  res_radial = ares

  res_radial@cnFillOn = False
  res_radial@cnLinesOn = True

  res_radial@gsnContourNegLineDashPattern  = 11
  res_radial@cnLineColor  =  "black"

  res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1
  res_radial@cnLineThicknessF  = 1.1

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
   poradial_wind= gsn_csm_contour(wks,aradial(36:65,0:199),pores)
   poradial_wind1= gsn_csm_contour(wks,aradial(36:65,0:199),pores)

   neres = res_radial
   neres@cnLevelSelectionMode = "ExplicitLevels"
   ;neres@cnLevels = (/ -0.1,-0.2,-0.3,-0.5,-1,-3,-5/)   ; set levels
   neres@cnLevels = (/ -1,-2,-3,-4/)

   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = -15.
   ;res_radial@cnMaxLevelValF   = 0.0
   ;if (it.le.430) then
     ;res_radial@cnLevelSpacingF   = 0.15
   ;else
     ;res_radial@cnLevelSpacingF   = 0.8
   ;end if
   neradial_wind= gsn_csm_contour(wks,aradial(36:65,0:199),neres)
   neradial_wind1= gsn_csm_contour(wks,aradial(36:65,0:199),neres)

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
   zeradial_wind= gsn_csm_contour(wks,aradial(36:65,0:199),zeres)
   zeradial_wind1= gsn_csm_contour(wks,aradial(36:65,0:199),zeres)
   
;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  awwnd = dim_avg_n(wwnd(it-6:it+6,:,:), 0)

  res_w = ares
  res_w@gsnFrame  = False
  res_w@gsnDraw   = False

  res_w@cnLineColor  =  "black"
  res_w@cnFillOn = False
  res_w@cnLinesOn = True
  
  res_w@cnLevelSelectionMode = "ExplicitLevels"
  ;res_w@cnLevels = (/-0.5,-0.1,-0.01,0.1,0.25,1,2/)   ; set levels
  res_w@cnLevels = (/-0.5,-0.25,-0.1,-0.05,0.5,1,1.5,2.5,3,4,5/)

  res_w@gsnContourNegLineDashPattern  = 11
  ;res_w@cnLineLabelsOn    = True
  ;res_w@cnLineLabelBackgroundColor = -1
  ;res_w@cnMaxLevelValF   = 0.
  ;res_w@cnMinLevelValF   = -5.
  ;res_w@cnLevelSpacingF = 3.
  res_w@cnLineThicknessF  = 0.8

  w_windp1 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 

  delete(res_w@cnLevels)

  res_w@cnLevelSelectionMode = "ExplicitLevels"
  res_w@cnLevels = (/0.0/)   ; set levels
  res_w@cnLineThicknessF  = 1.3
 
  w_wind01 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 

  delete(res_w@cnLevels)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels  
  ;if (it.le.300) then 
    ares@cnLevelSpacingF = 0.5
    ares@cnMinLevelValF  = -4.5
    ares@cnMaxLevelValF  = 4.5
  ;else
    ;ares@cnLevelSpacingF = 1.
    ;ares@cnMinLevelValF  = -6.
    ;ares@cnMaxLevelValF  = 6.
  ;end if

  ares@gsnRightString = "T = "+ it*10/60. +" h - "+ (it+dt+1)*10/60.+"h ~C~" 
  
  ares@gsnLeftString = "MADV"
  plot7(ip) = gsn_csm_contour(wks,madv_1h(36:65,0:199)*nmin, ares)

  ares@gsnLeftString = "EADV"
  plot7(ip+1) = gsn_csm_contour(wks,eadv_1h(36:65,0:199)*nmin, ares)

  ip = ip+2

  ;t_dire = t_sum_1h(36:65,0:199)*nmin-t_temp(36:65,0:199)

  ;ares@tiMainString = "diffrence"
  ;plot9(2) = gsn_csm_contour(wks,t_dire(:,:), ares)
  
  ares@gsnLeftString = "MRADV"
  plot8(ni) = gsn_csm_contour(wks,radvm_1h(36:65,0:199)*nmin, ares)
  
  ares@gsnLeftString = "MVADV"
  plot8(ni+1) = gsn_csm_contour(wks,vadvm_1h(36:65,0:199)*nmin, ares)

  overlay(plot8(ni), poradial_wind)
  overlay(plot8(ni), neradial_wind)

  overlay(plot8(ni+1), w_windp1)
  overlay(plot8(ni+1), w_wind01)

  ni = ni+2

end do

  gres@gsnPanelLabelBar = True
  gres@lbOrientation        = "Vertical"
  
  gsn_panel(wks, plot7, (/4,2/), gres)
  gsn_panel(wks, plot8, (/4,2/), gres)

end












