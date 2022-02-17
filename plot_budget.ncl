load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    ;files = systemfunc("ls ./sim9/heat*")
    ;a_heat = addfiles(files, "r")
    ;ListSetType(a_heat, "cat")
    ;t_heat = a_heat[:]->t_heat

    ;files = systemfunc("ls ./sim8/bud/uncp_pbl*")
    ;a_pbl = addfiles(files, "r")
    ;ListSetType(a_pbl, "cat")

    ;files = systemfunc("ls ./sim8/bud/diff*")
    ;a_diff = addfiles(files, "r")
    ;ListSetType(a_diff, "cat")

    ;files = systemfunc("ls ./sim8/bud/adv_v*")
    ;a_v = addfiles(files, "r")
    ;ListSetType(a_v, "cat")

    ;files = systemfunc("ls ./sim8/bud/adv_h*")
    ;a_h = addfiles(files, "r")
    ;ListSetType(a_h, "cat")

    ;files = systemfunc("ls ./sim8/theta_ano0804.nc")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    a1 = addfile("sim_lev100/bud/for_heat_03_00.nc","r")
    t_heat = a1->t_heat 

    a2 = addfile("sim_lev100/bud/for_pbl_03_00.nc","r")
    t_pbl = a2->t_pbl

    a3 = addfile("sim_lev100/bud/for_diff_03_00.nc","r")
    t_diff = a3->t_diff

    a33 = addfile("sim_lev100/bud/for_diff3_03_00.nc","r")
    t_diff3 = a3->t_diff
    
    a4 = addfile("sim_lev100/bud/for_adv_v_03_00.nc","r")
    t_adv_v = a4->t_adv_v

    a5 = addfile("sim_lev100/bud/for_adv_h_03_00.nc","r")
    t_adv_h = a5->t_adv_h

    ;a6 = addfile("/user_home/jyyin/dta/sim9/bud_d3_12/adv.nc","r")
    ;t_adv = a6->t_adv
    
    ;a7 = addfile("sim_lev100/bud/cu_d1_12.nc","r")
    ;t_cu = a7->t_cu
    
    ;a8 = addfile("/user_home/jyyin/dta/sim9/bud_d3_12/ra.nc","r")
    ;t_ra = a8->t_ra
    
    ;files = systemfunc("ls ./sim_lev100/tha/tano218")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ano_h = addfile("sim_lev100/tha/afor_t300.nc","r")
    t_ano = ano_h->ta

    ano_h = addfile("sim_lev100/tha/afor_t518.nc","r")
    t_ano2 = ano_h->ta

    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl  + t_diff
    t_adv = t_adv_h + t_adv_v
    t_sum = runave_n(t_sum, 5, 0, 1)
    t_sum = runave_n(t_sum, 5, 0, 2)
    

    printVarSummary(t_ano)
    printVarSummary(t_sum)

    wks=gsn_open_wks("pdf","sim_lev100/budget_test_512_3h") 
    gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 10min 
    ;;; 1h: 6 ;;; 2h: 12

    n = 0
    plots = new(12,graphic)
  
    do it = 0,6,10

    dt = 17
    nmin = 10*60

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
    ;t_temp = t_ano2(it,:,:)-t_ano(it,:,:)
    ;t_temp(:,:) = smth9(t_temp(:,:), 0.5, -0.25, True)
    ;printVarSummary(t_cu_1h)

  gres                    = True
  plot9 = new(9,graphic)
  plot2 = new(2,graphic)


  res = True
  res@cnFillOn            = True
  res@cnLinesOn           = True

  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0, 17,35,53/)
  res@tmYLLabels  = (/0.5,5,10,15/)

  ;res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 1.
  ;res@cnMinLevelValF  = -4.
  ;res@cnMaxLevelValF  = 4.
  
  plot2(0) = gsn_csm_contour(wks, t_ano2(it,0:61,:), res)
  plot2(1) = gsn_csm_contour(wks, t_ano(it,0:61,:), res)
 
  ;gsn_panel(wks, plot2, (/1,2/), gres)

  ares = True
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame
  
  ares@vpWidthF           = .6
  ares@vpHeightF          = .4
  
  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "height(km)"
  ares@cnFillOn            = True
  ares@cnLinesOn           = True
  
  ;ares@tmXBMode = "Explicit"
  ;r1 = fspan(0.0,700.0,150)
  ;print(r1)
  ;ares@tmXBMode    = "Explicit"
  ;ares@tmXBValues  = (/0, 22, 43, 64, 85/)
  ;ares@tmXBLabels  = (/0,100,200,300,400/)

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 11,24,36,40/)
  ;ares@tmYLLabels  = (/0.5,5,10,15,17/)

  ;ares@tmXMajorGrid          = True               ; Add white grid lines
  ;ares@tmXMajorGridLineColor = "gray"
  ;ares@tmYMajorGrid          = True
  ;ares@tmYMajorGridLineColor = "gray"

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0,14,21,26,30/)
  ;ares@tmYLLabels  = (/5,10,13,15,17/)

  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025
  ares@cnLinesOn               = False

  ;ares@cnLevelSelectionMode = "AutomaticLevels"

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ares@cnLevelSpacingF = 2.
  ares@cnMinLevelValF  = -16.
  ares@cnMaxLevelValF  = 16.

  
  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 17,35,53,61/)
  ;ares@tmYLLabels  = (/0.5,5,10,15,17/)

  ares@tmYLMode    = "Explicit"
  ares@tmYLValues  = (/0, 17,35,53,61/)
  ares@tmYLLabels  = (/0.5,5,10,15,17/)

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


  ares@tiMainString = "Diff"
  plot9(6) = gsn_csm_contour(wks,t_diff_1h(0:61,0:39)*nmin, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot9(4) = gsn_csm_contour(wks,t_heat_1h(0:61,0:39)*nmin, ares)

  ares@tiMainString = "PBL"
  plot9(5) = gsn_csm_contour(wks,t_pbl_1h(0:61,0:39)*nmin, ares)
  
  ares@tiMainString = "ADV"
  plot9(3) = gsn_csm_contour(wks,t_adv_1h(0:61,0:39)*nmin, ares)
  
  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-100,-80,-60,-40,-20, 0,   20,  40,  60,  80,100/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,149,152,167,183,199,215/)  ; set the colors to be used

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ares@cnLevelSpacingF = 8.
  ares@cnMinLevelValF  = -80.
  ares@cnMaxLevelValF  = 80.
  
  ares@tiMainString = "Horizontal Advection"
  plot9(7) = gsn_csm_contour(wks,t_adv_h_1h(0:61,0:39)*nmin, ares)
  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*720, ares)
  
  ares@tiMainString = "Vertical Advection"
  plot9(8) = gsn_csm_contour(wks,t_adv_v_1h(0:61,0:39)*nmin, ares)
  
  ;gres = True
  ;gres@tiMainString = "theta Budget Term 1 hour"
  ;gsn_panel(wks, plot9, (/2,3/), gres)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;plot3 = new(3,graphic)

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/1,14,21,26,30/)
  ;ares@tmYLLabels  = (/5,10,13,15,17/)

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-1,-0.8,-0.6,-0.4,-0.2, 0,   0.2,  0.4, 0.6,  0.8,1/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,149,152,167,183,199,215/)  ; set the colors to be used

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ares@cnLevelSpacingF = 1.
  ares@cnMinLevelValF  = -5.
  ares@cnMaxLevelValF  = 5.

  ares@tiMainString = "Sum of RHS"
  plot9(1) = gsn_csm_contour(wks,t_sum_1h(0:61,0:39)*nmin, ares)

  ares@tiMainString = "Actual change"
  plot9(0) = gsn_csm_contour(wks,t_temp(0:61,0:39), ares)

  t_dire = t_sum_1h(0:61,0:39)*nmin-t_temp(0:61,0:39)

  time = (it*10/60.)+96
  ;time = 100.
  
  ares@tiMainString = "diffrence"
  plot9(2) = gsn_csm_contour(wks,t_dire(:,:), ares)

  ;gres@gsnPanelLabelBar = True
  gres@txString = "time = " + time +"h - "+ (time+6) + "h"
  gsn_panel(wks, plot9, (/3,3/), gres)

end do

end












