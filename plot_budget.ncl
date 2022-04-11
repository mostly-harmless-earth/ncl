load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    files = systemfunc("ls ./sim_lev100/bud_for/for_heat*")
    a_heat = addfiles(files, "r")
    ListSetType(a_heat, "cat")
    ;a_heat = addfile("sim_lev100/bud/angle/heat_azi.nc","r")
    t_heat = a_heat[:]->t_heat(:,0:90,:)

    files = systemfunc("ls ./sim_lev100/bud_for/for_pbl*")
    a_pbl = addfiles(files, "r")
    ListSetType(a_pbl, "cat")
    ;a_pbl = addfile("sim_lev100/bud/angle/pbl_azi.nc","r")
    t_pbl = a_pbl[:]->t_pbl(:,0:90,:)

    files = systemfunc("ls ./sim_lev100/bud_for/for_diff*")
    a_diff = addfiles(files, "r")
    ListSetType(a_diff, "cat")
    ;a_diff = addfile("sim_lev100/bud/angle/diff_azi.nc","r")
    t_diff1 = a_diff[:]->t_diff(:,0:90,:)

    files = systemfunc("ls ./sim_lev100/bud_for/for_3diff*")
    a_diff3 = addfiles(files, "r")
    ListSetType(a_diff, "cat")
    ;a_diff3 = addfile("sim_lev100/bud/angle/diff3_azi.nc","r")
    t_diff3 = a_diff3[:]->t_diff(:,0:90,:)

    files = systemfunc("ls ./sim_lev100/bud_for/for_adv_v*")
    a_v = addfiles(files, "r")
    ListSetType(a_v, "cat")
    ;a_v = addfile("sim_lev100/bud/angle/adv_v_azi.nc","r")
    t_adv_v = a_v[:]->t_adv_v(:,0:90,:)

    files = systemfunc("ls ./sim_lev100/bud_for/for_adv_h*")
    a_h = addfiles(files, "r")
    ListSetType(a_h, "cat")
    ;a_h = addfile("sim_lev100/bud/angle/adv_h_azi.nc","r")
    t_adv_h = a_h[:]->t_adv_h(:,0:90,:)

    ;files = systemfunc("ls ./sim_lev100/tha/afor_t*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")
    ;th = ano_h[:]->ta

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

    b = addfile("/user_home/jyyin/dta/sim_lev100/angle/vr_azi.nc.nc","r")
    radial = b->wrad(:,0:90,:)

    c = addfile("/user_home/jyyin/dta/sim_lev100/angle/azi_vertical.nc","r")
    wwnd = c->ww(:,0:90,:)

    d = addfile("/user_home/jyyin/dta/sim_lev100/angle/d7_t0_ta.nc","r")
    t_ano = d->ta(:,0:90,:)

    printVarSummary(t_adv_h)
    printVarSummary(radve)

    t_diff = t_diff1 + t_diff3
    t_adv_h = radve + radvm
    t_adv_v = vadve + vadvm

    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl  + t_diff
    t_adv = t_adv_h + t_adv_v 

    ;t_sum = radve + radvm + vadve + vadvm+ t_heat + t_pbl  + t_diff
    ;t_adv = radve + radvm + vadve + vadvm
     
    ;t_sum = smth9(t_sum, 0.50, -0.25, False)
    t_sum = runave_n(t_sum, 3, 0, 0)
    ;t_sum = runave_n(t_sum, 3, 0, 0)
    t_sum = runave_n(t_sum, 3, 0, 1)
    ;t_sum = runave_n(t_sum, 3, 0, 1)
    t_sum = runave_n(t_sum, 5, 0, 2)
    t_sum = runave_n(t_sum, 3, 0, 2)
    
    t_adv_h = runave_n(t_adv_h, 5, 0, 2)
    t_adv_v = runave_n(t_adv_v, 5, 0, 2)
    t_heat  = runave_n(t_heat, 5, 0, 2)
    t_pbl   = runave_n(t_pbl, 5, 0, 2)
    t_diff  = runave_n(t_diff, 5, 0, 2)   
    
    ;t_sum = runave_n(t_sum, 3, 0, 0)
    ;t_sum = runave_n(t_sum, 5, 0, 1)
    ;t_sum = runave_n(t_sum, 5, 0, 2)
    
    printVarSummary(t_ano)
    printVarSummary(t_sum)

    wks=gsn_open_wks("pdf","sim_lev100/stages4_budget_cal") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 10min 
    ;;; 1h: 6 ;;; 2h: 12

    n = 0
    dims = dimsizes(t_pbl)
    plots = new(12,graphic)
  
    do i = 0,3,1

    timi = (/198,276,396,492/) ;;;33h, 46h, 66h, 82h
    dtg  = (/29,59,119,59/)
    
    it = timi(i)
    dt = dtg(i)
    
    nmin = 10*60

    ;th(it,:,:) = dim_sum_n(th(it-6:it+6,:,:), 0)/3.

    t_sum_1h   = dim_sum_n(t_sum(it:it+dt,:,:), 0)
    t_adv_h_1h = dim_sum_n(t_adv_h(it:it+dt,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(it:it+dt,:,:), 0)
    t_adv_1h   = dim_sum_n(t_adv(it:it+dt,:,:), 0)

    t_heat_1h  = dim_sum_n(t_heat(it:it+dt,:,:), 0)
    t_pbl_1h   = dim_sum_n(t_pbl(it:it+dt,:,:), 0)
    ;t_cu_1h    = dim_sum_n(t_cu(it:it+dt,:,:), 0)
    ;t_ra_1h    = dim_sum_n(t_ra(it:it+dt,:,:), 0)
    t_diff_1h  = dim_sum_n(t_diff(it:it+dt,:,:), 0)

    t_adv_1h = t_adv_h_1h + t_adv_v_1h

    t_temp = t_ano(it+dt+1,:,:)-t_ano(it,:,:)
    ;t_temp = th2(it,:,:)-th(it,:,:)
    ;t_temp(:,:) = smth9(t_temp(:,:), 0.5, -0.25, True)
    ;printVarSummary(t_cu_1h)

  gres                    = True
  plot9 = new(9,graphic)
  plot6 = new(2,graphic)

  res = True
  res@cnFillOn            = True
  res@cnLinesOn           = False

  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 17,35,53/)
  ;res@tmYLLabels  = (/0.5,5,10,15/)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0, 7, 14,21,28/)
  res@tmYLLabels  = (/10,12,14,16,18/)

  res@vpWidthF           = .6
  res@vpHeightF          = .4

  ;res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 1.
  ;res@cnMinLevelValF  = -4.
  ;res@cnMaxLevelValF  = 4.

  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevels     = (/ 15, 13, 11,  9,  7, 5, 3, 1,-0.1,-1,-2,-3,-4,-5 /)   ; set levels
  ;res@cnFillColors = (/120,115,110,105,100,95,90,82,  73,65,50,40,30,20,10/)  ; set the colors to be used

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels     = (/-5,-4,-3,-2,-1,-0.5, 1, 3, 5, 7,  9, 11, 13,15 /)   ; set levels
  res@cnFillColors = (/10,20,30,40,50,  60,65,70,80,90,100,110,120,124,128/)
  
  time1 = it*10/60.
  time2 = (it+dt+1)*10/60.

  res@gsnRightString = time1 +"h"
  plot6(0) = gsn_csm_contour(wks, t_ano(it,0:65,:), res)

  res@gsnRightString = time2 +"h"
  plot6(1) = gsn_csm_contour(wks, t_ano(it+dt+1,0:65,:), res)
  
  ;res@gsnRightString = time+4 +"h"
  ;plot6(2) = gsn_csm_contour(wks, t_ano(it+24,0:65,:), res)
  
  ;res@gsnRightString = time+6 +"h"
  ;plot6(3) = gsn_csm_contour(wks, t_ano(it+54,0:65,:), res)
  
  ;res@gsnRightString = time+12 +"h"
  ;plot6(4) = gsn_csm_contour(wks, t_ano(it+72,0:65,:), res)

  gres@txString = "time = " + time1 +"h - "+ time2 + "h"
  gsn_panel(wks, plot6, (/1,2/), gres)

  ares = True
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame
  
  ares@vpWidthF           = .6
  ares@vpHeightF          = .4
  
  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "height(km)"
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels  
  if (it.le.1000) then 
    ares@cnLevelSpacingF = 0.5
    ares@cnMinLevelValF  = -3.0
    ares@cnMaxLevelValF  = 3.0
  else
    ares@cnLevelSpacingF = 1.
    ares@cnMinLevelValF  = -6.
    ares@cnMaxLevelValF  = 6.
  end if

  ares@tiMainString = "Sum of RHS"
  plot9(1) = gsn_csm_contour(wks,t_sum_1h(0:65,0:199)*nmin, ares)

  ares@tiMainString = "Actual change"
  plot9(0) = gsn_csm_contour(wks,t_temp(0:65,0:199), ares)

  t_dire = t_sum_1h(0:65,0:199)*nmin-t_temp(0:65,0:199)

  ares@tiMainString = "diffrence"
  plot9(2) = gsn_csm_contour(wks,t_dire(:,:), ares)

  ares@tiMainString = "Diff"
  plot9(8) = gsn_csm_contour(wks,t_diff_1h(0:65,0:199)*nmin, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot9(7) = gsn_csm_contour(wks,t_heat_1h(0:65,0:199)*nmin, ares)

  ares@tiMainString = "PBL"
  plot9(6) = gsn_csm_contour(wks,t_pbl_1h(0:65,0:199)*nmin, ares)
  
  ares@tiMainString = "ADV"
  plot9(5) = gsn_csm_contour(wks,t_adv_1h(0:65,0:199)*nmin, ares)


  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-100,-80,-60,-40,-20, 0,   20,  40,  60,  80,100/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,149,152,167,183,199,215/)  ; set the colors to be used

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  if (it.le.400) then 
    ares@cnLevelSpacingF = 10.
    ares@cnMinLevelValF  = -50.
    ares@cnMaxLevelValF  = 50.
  else
    ares@cnLevelSpacingF = 20.
    ares@cnMinLevelValF  = -100.
    ares@cnMaxLevelValF  = 100.
  end if

  ares@tiMainString = "Horizontal Advection"
  plot9(3) = gsn_csm_contour(wks,t_adv_h_1h(0:65,0:199)*nmin, ares)
  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*720, ares)
  
  ares@tiMainString = "Vertical Advection"
  plot9(4) = gsn_csm_contour(wks,t_adv_v_1h(0:65,0:199)*nmin, ares)
  
  ;gres = True
  ;gres@tiMainString = "theta Budget Term 1 hour"
  ;gsn_panel(wks, plot9, (/2,3/), gres)

  ares@cnFillOn  = False
  ares@cnLinesOn = True 
  ares@cnLineThicknessF = 1.5
  ares@cnLineColor = "black"
 
  ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ares@cnLevels     = (/-5,-4,-3,-2,-1.5,-1/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,149,152,167,183,199,215/)  ; set the colors to be used

  ne1 = gsn_csm_contour(wks,t_temp(0:65,0:199), ares)
  ne2 = gsn_csm_contour(wks,t_temp(0:65,0:199), ares)

  overlay(plot9(3), ne1)
  overlay(plot9(4), ne2)

  ;gres@gsnPanelLabelBar = True
  gsn_panel(wks, plot9, (/3,3/), gres)

end do

end












