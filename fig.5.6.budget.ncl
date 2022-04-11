load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    ;files = systemfunc("ls ./sim_lev100/bud_for/for_heat*")
    ;a_heat = addfiles(files, "r")
    ;ListSetType(a_heat, "cat")
    a_heat = addfile("sim_lev100/bud/heat_azi.nc","r")
    t_heat = a_heat->t_heat(:,0:90,:)

    ;files = systemfunc("ls ./sim_lev100/bud_for/for_pbl*")
    ;a_pbl = addfiles(files, "r")
    ;ListSetType(a_pbl, "cat")
    a_pbl = addfile("sim_lev100/bud/pbl_azi.nc","r")
    t_pbl = a_pbl->t_pbl(:,0:90,:)

    ;files = systemfunc("ls ./sim_lev100/bud_for/for_diff*")
    ;a_diff = addfiles(files, "r")
    ;ListSetType(a_diff, "cat")
    a_diff = addfile("sim_lev100/bud/diff_azi.nc","r")
    t_diff1 = a_diff->t_diff(:,0:90,:)

    ;files = systemfunc("ls ./sim_lev100/bud_for/for_3diff*")
    ;a_diff3 = addfiles(files, "r")
    ;ListSetType(a_diff, "cat")
    a_diff3 = addfile("sim_lev100/bud/diff3_azi.nc","r")
    t_diff3 = a_diff3->t_diff(:,0:90,:)

    ;files = systemfunc("ls ./sim_lev100/bud_for/for_adv_v*")
    ;a_v = addfiles(files, "r")
    ;ListSetType(a_v, "cat")
    a_v = addfile("sim_lev100/bud/adv_v_azi.nc","r")
    t_adv_v = a_v->t_adv_v(:,0:90,:)

    ;files = systemfunc("ls ./sim_lev100/bud_for/for_adv_h*")
    ;a_h = addfiles(files, "r")
    ;ListSetType(a_h, "cat")
    a_h = addfile("sim_lev100/bud/adv_h_azi.nc","r")
    t_adv_h = a_h->t_adv_h(:,0:90,:)

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

    b = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/vr_azi.nc.nc","r")
    radial = b->wrad(:,0:90,:)

    c = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/azi_vertical.nc","r")
    wwnd = c->ww(:,0:90,:)

    d = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/d7_t0_ta.nc","r")
    t_ano = d->ta(:,0:90,:)

    t_diff = t_diff1 + t_diff3
    t_adv_h = radve + radvm
    t_adv_v = vadve + vadvm

    printVarSummary(t_adv_h)
    printVarSummary(radve) 

    t_adv_h = runave_n(t_adv_h, 3, 0, 2)
    t_adv_v = runave_n(t_adv_v, 3, 0, 2)
    t_heat  = runave_n(t_heat, 3, 0, 2)
    t_pbl   = runave_n(t_pbl, 3, 0, 2)
    t_diff  = runave_n(t_diff, 3, 0, 2)   

    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl  + t_diff
    t_adv = t_adv_h + t_adv_v 

    ;t_sum = radve + radvm + vadve + vadvm+ t_heat + t_pbl  + t_diff
    ;t_adv = radve + radvm + vadve + vadvm
     
    ;t_sum = smth9(t_sum, 0.50, -0.25, False)
    ;t_sum = runave_n(t_sum, 3, 0, 0)
    ;t_sum = runave_n(t_sum, 3, 0, 0)
    t_sum = runave_n(t_sum, 3, 0, 1)
    ;t_sum = runave_n(t_sum, 3, 0, 1)
    
    ;t_sum = runave_n(t_sum, 3, 0, 2)
    t_sum = runave_n(t_sum, 3, 0, 2)
    
    t_ano = runave_n(t_ano, 3, 0, 2)
    t_ano = runave_n(t_ano, 3, 0, 1)
    

    
    ;t_sum = runave_n(t_sum, 3, 0, 0)
    ;t_sum = runave_n(t_sum, 5, 0, 1)
    ;t_sum = runave_n(t_sum, 5, 0, 2)
    
    printVarSummary(t_ano)
    printVarSummary(t_sum)

    wks=gsn_open_wks("pdf","sim_lev100/wang_fig_56_cal_diff") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 10min 
    ;;; 1h: 6 ;;; 2h: 12

    n = 0
    dims = dimsizes(t_pbl)
    plots = new(12,graphic)

    ip = 0
    ni = 0
    plot5 = new(12,graphic)
    plot6 = new(12,graphic)

    do i = 0,3,1

    ;timi = (/198,276,396,492/) ;;;33h, 46h, 66h, 82h
    ;dtg  = (/29,59,119,59/)

    timi = (/192,276,456,564/) ;;;33h, 46h, 76h, 94h
    dt = 71
    
    it = timi(i)
    ;dt = dtg(i)
    
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

  ares@cnLineLabelsOn = False
  ares@lbLabelBarOn        = False 

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-10,-0.8,-0.6,-0.4,-0.2, 0,   2,  4,  6,  8,10/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,149,152,167,183,199,215/)  ; set the colors to be used

  ;ares@lbLabelBarOn        = False           ; turn off individual cb's
  ;ares@lbOrientation        = "Vertical"
  ;ares@tiMainString = "Total Advection"
  ;plot9(0) = gsn_csm_contour(wks,t_adv_1h(11:41,:)*720, ares)

;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  awwnd = dim_avg_n(wwnd(it-6:it+6,:,:), 0)

  delete(ares@gsnRightString)
  delete(ares@gsnLeftString)

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
  w_windp2 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 
  w_windp3 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 
  w_windp4 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 

  delete(res_w@cnLevels)

  res_w@cnLevelSelectionMode = "ExplicitLevels"
  res_w@cnLevels = (/0.0/)   ; set levels
  res_w@cnLineThicknessF  = 1.3
 
  w_wind01 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 
  w_wind02 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 
  w_wind03 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 
  w_wind04 = gsn_csm_contour(wks,awwnd(36:65,0:199),res_w) 
  
  delete(res_w@cnLevels)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels  
  if (it.le.1000) then 
    ares@cnLevelSpacingF = 0.5
    ares@cnMinLevelValF  = -4.0
    ares@cnMaxLevelValF  = 4.0
  else
    ares@cnLevelSpacingF = 1.
    ares@cnMinLevelValF  = -6.
    ares@cnMaxLevelValF  = 6.
  end if

  ares@gsnRightString = "T = "+ it*10/60. +" h - "+ (it+dt+1)*10/60.+"h ~C~" 
  ares@gsnLeftString = "Sum of RHS"
  plot5(ip) = gsn_csm_contour(wks,t_sum_1h(36:65,0:199)*nmin, ares)

  ares@gsnLeftString = "Actual change"
  plot5(ip+1) = gsn_csm_contour(wks,t_temp(36:65,0:199), ares)

  t_dire = t_sum_1h(36:65,0:199)*nmin-t_temp(36:65,0:199)

  ;ares@gsnLeftString = "diffrence"
  ;plot5(ip+2) = gsn_csm_contour(wks,t_dire(:,:), ares)

  ares@gsnLeftString = "TADV"
  plot6(ni) = gsn_csm_contour(wks,t_adv_1h(36:65,0:199)*nmin, ares)
  
  ares@gsnLeftString = "HEAT"
  plot6(ni+1) = gsn_csm_contour(wks,t_heat_1h(36:65,0:199)*nmin, ares)
  
  ares@gsnLeftString = "Diff + PBL"
  plot6(ni+2) = gsn_csm_contour(wks,t_diff_1h(36:65,0:199)*nmin+t_pbl_1h(36:65,0:199)*nmin, ares)

  mres = ares
  ;mres@gsnDraw            = True                   ; don't draw
  ;mres@gsnFrame           = True                   ; don't advance frame
  mres@cnFillOn                = False
  mres@cnLinesOn               = True 

  mres@gsnLeftString = " "
  mres@gsnRightString = " "

  mres@cnLineThicknessF = 1.8
  mres@cnLineColor = "black"
 
  mres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  mres@cnLevels     = (/-5,-4,-3,-2,-1/)   ; set levels

  cp1 = gsn_csm_contour(wks,t_temp(36:65,0:199), mres)
  cp2 = gsn_csm_contour(wks,t_temp(36:65,0:199), mres)
  cp3 = gsn_csm_contour(wks,t_temp(36:65,0:199), mres)
  cp4 = gsn_csm_contour(wks,t_temp(36:65,0:199), mres)


  ;overlay(plot5(ip), w_windp1)
  ;overlay(plot5(ip), w_wind01)
  ;overlay(plot5(ip+1), w_windp2)
  ;overlay(plot5(ip+1), w_wind02)

  overlay(plot6(ni), cp1)
  overlay(plot6(ni+1), cp2)
  overlay(plot6(ni+2), cp3)
  
  ip = ip+2
  ni = ni+3
  

end do
  
  gres@gsnPanelLabelBar = True
  gres@lbOrientation        = "Vertical"
  gsn_panel(wks, plot5, (/4,2/), gres)
  gsn_panel(wks, plot6, (/4,3/), gres)

end












