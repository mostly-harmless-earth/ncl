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

    a1 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/heat.nc","r")
    t_heat = a1->t_heat 

    a2 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/pbl.nc","r")
    t_pbl = a2->t_pbl

    a3 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/diff.nc","r")
    t_diff = a3->t_diff
    
    a4 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/adv_v.nc","r")
    t_adv_v = a4->t_adv_v

    a5 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/adv_h.nc","r")
    t_adv_h = a5->t_adv_h

    a6 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/adv.nc","r")
    t_adv = a6->t_adv
    
    a7 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/cu.nc","r")
    t_cu = a7->t_cu
    
    a8 = addfile("/user_home/jyyin/dta/sim9/bud_d1_00/ra.nc","r")
    t_ra = a8->t_ra
    
    ;files = systemfunc("ls ./sim9/tano_d2*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ano_h = addfile("sim9/tano_d1_00.nc","r")
    t_ano = ano_h->ta


    t_adv_v = t_adv_v*0.98
    t_adv = t_adv_h + t_adv_v
    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl + t_ra + t_diff

    hei = fspan(500, 27500, 68)/1000
    r1 = fspan(0.0,700.0,150)
    hei@units = "m"
    r1@units = "km"
    print(hei)
    print(r1)

    printVarSummary(t_ano)
    printVarSummary(t_sum)

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9/local_7-10h_30min") 
    gsn_define_colormap(wks,"MPL_coolwarm")  ; Change color map.

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 6min 
    ;;; 1h: 10 ;;; 2h: 20

    n = 0
    plots = new(12,graphic)
  
    do it = 59,109,10

    t_sum_1h   = dim_sum_n(t_sum(it:it+9,:,:), 0)
    t_adv_h_1h = dim_sum_n(t_adv_h(it:it+9,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(it:it+9,:,:), 0)
    t_adv_1h   = dim_sum_n(t_adv(it:it+9,:,:), 0)

    t_heat_1h  = dim_sum_n(t_heat(it:it+9,:,:), 0)
    t_pbl_1h   = dim_sum_n(t_pbl(it:it+9,:,:), 0)
    t_cu_1h    = dim_sum_n(t_cu(it:it+9,:,:), 0)
    t_ra_1h    = dim_sum_n(t_ra(it:it+9,:,:), 0)
    t_diff_1h  = dim_sum_n(t_diff(it:it+9,:,:), 0)

    t_temp = t_ano(it+10,:,:)-t_ano(it,:,:)
    t_adv_1h = t_adv_h_1h + t_adv_v_1h

  res                     = True
  gres                    = True
  
  res@gsnDraw            = True                   ; don't draw
  res@gsnFrame           = True                   ; don't advance frame
  res@cnFillOn            = True
  res@cnLinesOn           = True
  res@cnLineLabelsOn      = False
  ;res@cnLineThicknesses   = 1.5
  ;gres@gsMarkerIndex = 0
  ;gres@gsMarkerSizeF    = 0.015
  ;gres@gsMarkerColor       = "navy"                 ; color chosen
  ;gres@gsMarkerThicknessF = 3
  ;res@xyLineThicknesses = 2.0
  ;res@tiMainString = "Sea Level Pressure ~c~ Max Wind Speed"
  
  
  ;res@tiYAxisString           = "height(km)"
  ;res@tiXAxisString           = "times(hr)"
  ;res@tiMainString = "Hovmoller 72-96h (r=0km)"

  ;ti = ispan(0, 479, 1)
  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = ti(::40)
  ;res@tmXBLabels   = ti(::40)*3/60+72
  
  ;t_ano2=transpose(t_ano(:,0:44,1))
  ;plots = gsn_csm_contour(wks,t_ano2, res)

    res@gsnDraw            = False                   ; don't draw
    res@gsnFrame           = False                   ; don't advance frame

    res@tmXBMode    = "Explicit"
    res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    res@tmYLMode    = "Explicit"
    res@tmYLValues  = (/0, 11,24,36,40/)
    res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.8,-1.4,-1.0,-0.6,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

    res@lbLabelBarOn        = False           ; turn off individual cb's
 
    res@tiMainString = "time = " + ((it+1)*6/60.) + "h"
    plots(n) =  gsn_csm_contour(wks,t_ano(it,0:41,:), res)
    n = n+1
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw budget term ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot9 = new(9,graphic)
  
  ares = True
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame

  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "height(km)"
  ares@cnFillOn            = True
  ares@cnLinesOn           = True
  
  ares@tmXBMode = "Explicit"
  r1 = fspan(0.0,700.0,150)
  ;print(r1)
  ares@tmXBMode    = "Explicit"
  ares@tmXBValues  = (/0, 22, 43, 64, 85/)
  ares@tmXBLabels  = (/0,100,200,300,400/)

  ares@tmYLMode    = "Explicit"
  ares@tmYLValues  = (/1,3,5,7,10/)
  ares@tmYLLabels  = (/13,14,15,16,17/)

  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025

  ares@cnLevelSelectionMode     = "AutomaticLevels"

  ;ares@tiMainString = "Total Advection"
  ;plot9(0) = gsn_csm_contour(wks,t_adv_1h(11:41,:)*360, ares)

  ares@tiMainString = "Vertical Advection"
  plot9(0) = gsn_csm_contour(wks,t_adv_v_1h(31:41,0:85)*360, ares)

  ares@tiMainString = "Horizontal Advection"
  plot9(1) = gsn_csm_contour(wks,t_adv_h_1h(31:41,0:85)*360, ares)
;
  ares@tiMainString = "Total Advection"
  plot9(2) = gsn_csm_contour(wks,t_adv_1h(31:41,0:85)*360, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot9(3) = gsn_csm_contour(wks,t_heat_1h(31:41,0:85)*360, ares)

  ares@tiMainString = "PBL + Diffusion"
  plot9(4) = gsn_csm_contour(wks,(t_pbl_1h(31:41,0:85)+t_diff_1h(31:41,0:85))*360, ares)

  ares@tiMainString = "Cu"
  plot9(5) = gsn_csm_contour(wks,t_cu_1h(31:41,0:85)*360, ares)

  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*360, ares)

  ;gres = True
  ;gres@tiMainString = "theta Budget Term 1 hour"
  ;gsn_panel(wks, plot9, (/2,3/), gres)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;plot3 = new(3,graphic)

  ares@tmYLMode    = "Explicit"
  ares@tmYLValues  = (/1,3,5,7,10/)
  ares@tmYLLabels  = (/13,14,15,16,17/)

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ;ares@cnLevels     = (/ -1.1,-0.9,-0.7,-0.5,-0.4,-0.3,-0.2,-0.1,0.1, 0.2,0.5,0.8/)   ; set levels
  ;ares@cnFillColors = (/    2,   5,   8,  16,  24,  32,  48,  64,  0,  80, 90,100,110/)  ; set the colors to be used

  ares@tiMainString = "Sum of RHS"
  plot9(6) = gsn_csm_contour(wks,t_sum_1h(31:41,0:85)*360, ares)

  ares@tiMainString = "Actual change"
  plot9(7) = gsn_csm_contour(wks,t_temp(31:41,0:85), ares)

  t_dire = t_sum_1h(31:41,0:85)*360-t_temp(31:41,0:85)

  time = ((it+1)*6/60.)

  ares@tiMainString = "diffrence"
  plot9(8) = gsn_csm_contour(wks,t_dire(:,:), ares)

  gres@txString = "time = " + time +"h - "+ (time+1) + "h"
  gsn_panel(wks, plot9, (/3,3/), gres)

end do

  res@tiMainString = "time = " + (time+0.5) + "h"
  plots(n) =  gsn_csm_contour(wks,t_ano(119,0:41,:), res)
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@txString = "Theta Anomaly"
  gsn_panel(wks, plots, (/3,4/), gres_ta)

end












