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

    a1 = addfile("/user_home/jyyin/dta/sim9/bud_d4/heat.nc","r")
    t_heat = a1->t_heat 

    a2 = addfile("/user_home/jyyin/dta/sim9/bud_d4/pbl.nc","r")
    t_pbl = a2->t_pbl

    a3 = addfile("/user_home/jyyin/dta/sim9/bud_d4/diff.nc","r")
    t_diff = a3->t_diff
    
    a4 = addfile("/user_home/jyyin/dta/sim9/bud_d4/adv_v.nc","r")
    t_adv_v = a4->t_adv_v

    a5 = addfile("/user_home/jyyin/dta/sim9/bud_d4/adv_h.nc","r")
    t_adv_h = a5->t_adv_h

    a6 = addfile("/user_home/jyyin/dta/sim9/bud_d4/adv.nc","r")
    t_adv = a6->t_adv
    
    a7 = addfile("/user_home/jyyin/dta/sim9/bud_d4/cu.nc","r")
    t_cu = a7->t_cu
    
    a8 = addfile("/user_home/jyyin/dta/sim9/bud_d4/ra.nc","r")
    t_ra = a8->t_ra
    
    ano_h = addfile("sim9/tano_azi.nc","r")
    t_ano = ano_h->ta

    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl + t_cu + t_ra + t_diff

    hei = fspan(500, 27500, 68)/1000
    r1 = fspan(0.0,700.0,150)
    hei@units = "m"
    r1@units = "km"

    hei = fspan(500, 26500, 68)
    print(hei)
    printVarSummary(t_ano)

    t_sum_1h   = dim_sum_n(t_sum(0:19,:,:), 0)
    t_adv_h_1h = dim_sum_n(t_adv_h(0:19,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(0:19,:,:), 0)
    t_adv_1h   = dim_sum_n(t_adv(0:19,:,:), 0)

    t_heat_1h  = dim_sum_n(t_heat(0:19,:,:), 0)
    t_pbl_1h   = dim_sum_n(t_pbl(0:19,:,:), 0)
    t_cu_1h    = dim_sum_n(t_cu(0:19,:,:), 0)
    t_ra_1h    = dim_sum_n(t_ra(0:19,:,:), 0)
    t_diff_1h  = dim_sum_n(t_diff(0:19,:,:), 0)

    t_temp = t_ano(20,:,:)-t_ano(0,:,:)

  wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9/Budget") 
  gsn_define_colormap(wks,"MPL_coolwarm")  ; Change color map.

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

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = (/5,10,15,20/)
 ; res@tmYLValues  = (/12,25,38,51/)

  ;ti = ispan(0, 479, 1)
  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = ti(::40)
  ;res@tmXBLabels   = ti(::40)*3/60+72
  
  ;t_ano2=transpose(t_ano(:,0:44,1))
  ;plots = gsn_csm_contour(wks,t_ano2, res)

  res@tmXBValues  = (/0,22,42,64,86,107,128,149/)
  res@tmXBLabels   = (/0,100,200,300,400,500,600,700/)

  plots =  gsn_csm_contour(wks,t_ano(20,:,:), res)

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
  ;ares@tmXBValues  = (/0,22,42,64,86,107,128,149/)
  ;ares@tmXBLabels   = (/0,100,200,300,400,500,600,700/)

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0,12,26/)
  ;ares@tmYLLabels  = (/10,15,20/)


  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025

  ares@tiMainString = "Total Advection"
  plot9(0) = gsn_csm_contour(wks,t_adv_1h(0:46,:)*360, ares)

  ares@tiMainString = "Vertical Advection"
  plot9(1) = gsn_csm_contour(wks,t_adv_v_1h(0:46,:)*360, ares)

  ares@tiMainString = "Horizontal Advection"
  plot9(2) = gsn_csm_contour(wks,t_adv_h_1h(0:46,:)*360, ares)
;
  ares@tiMainString = "Diffusion"
  plot9(3) = gsn_csm_contour(wks,t_diff_1h(0:46,:)*360, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot9(4) = gsn_csm_contour(wks,t_heat_1h(0:46,:)*360, ares)

  ares@tiMainString = "PBL"
  plot9(5) = gsn_csm_contour(wks,t_pbl_1h(0:46,:)*360, ares)

  ares@tiMainString = "Cu"
  plot9(6) = gsn_csm_contour(wks,t_cu_1h(0:46,:)*180, ares)

  ares@tiMainString = "Radiation "
  plot9(7) = gsn_csm_contour(wks,t_ra_1h(0:46,:)*180, ares)

  gres = True
  gres@tiMainString = "theta Budget Term"
  gsn_panel(wks, plot9, (/3,3/), gres)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot3 = new(3,graphic)

  ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ares@cnLevels     = (/ -4,-3.5,-3,-2.5,-2,-1.5,-1,-0.5,0.5, 1,1.5,  2/)   ; set levels
  ares@cnFillColors = (/  2,   5, 8,  16,24,  32,48,  64,  0,80, 90,100,110/)  ; set the colors to be used

  ares@tiMainString = "Sum of RHS"
  plot3(0) = gsn_csm_contour(wks,t_sum_1h(0:46,:)*180, ares)

  ares@tiMainString = "Actual change"
  plot3(1) = gsn_csm_contour(wks,t_temp(0:46,:), ares)

  t_dire = t_sum_1h(0:46,:)*180-t_temp(0:46,:)

  ares@tiMainString = "diffrence"
  plot3(2) = gsn_csm_contour(wks,t_dire(:,:), ares)

  gres@tiMainString = ""
  gsn_panel(wks, plot3, (/1,3/), gres)

end












