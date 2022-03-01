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

    files = systemfunc("ls ./sim_lev100/bud_for/for_heat*")
    a_heat = addfiles(files, "r")
    ListSetType(a_heat, "cat")
    t_heat = a_heat[:]->t_heat

    files = systemfunc("ls ./sim_lev100/bud_for/for_pbl*")
    a_pbl = addfiles(files, "r")
    ListSetType(a_pbl, "cat")
    t_pbl = a_pbl[:]->t_pbl

    files = systemfunc("ls ./sim_lev100/bud_for/for_diff*")
    a_diff = addfiles(files, "r")
    ListSetType(a_diff, "cat")
    t_diff = a_diff[:]->t_diff

    files = systemfunc("ls ./sim_lev100/bud_for/for_3diff*")
    a_diff3 = addfiles(files, "r")
    ListSetType(a_diff, "cat")
    t_diff3 = a_diff3[:]->t_diff

    files = systemfunc("ls ./sim_lev100/bud_for/for_adv_v*")
    a_v = addfiles(files, "r")
    ListSetType(a_v, "cat")
    t_adv_v = a_v[:]->t_adv_v

    files = systemfunc("ls ./sim_lev100/bud_for/for_adv_h*")
    a_h = addfiles(files, "r")
    ListSetType(a_h, "cat")
    t_adv_h = a_h[:]->t_adv_h

    files = systemfunc("ls ./sim_lev100/tha/afor_t*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    th = ano_h[:]->ta

    d = addfile("/user_home/jyyin/dta/sim_lev100/angle/angle_t0_tano.nc","r")
    t_ano = d->ta

    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl + t_diff + t_diff3
    t_adv = t_adv_h + t_adv_v

    hei = fspan(500, 27500, 100)/1000
    r1 = fspan(0.0,400.0,200)
    hei@units = "m"
    r1@units = "km"

    dims = dimsizes(th)
    printVarSummary(th)

    wks=gsn_open_wks("pdf","sim_lev100/profile_bud_13.5km") 
    gsn_define_colormap(wks,"amwg")  ; Change color map.

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 6min 
    ;;; 1h: 10 ;;; 2h: 20

    it = 0
  

    do it = 216,dims(0)-19,18

    n = 0
    plots = new(12,graphic)
  
    dt = 17

    t_sum_1h  = dim_sum_n(t_sum(it:it+dt,:,:), 0)
    t_sum_1h  = runave_n(t_sum_1h, 5, 0, 1)
    t_sum_1h  = runave_n(t_sum_1h, 5, 0, 0)

    t_adv_h_1h = dim_sum_n(t_adv_h(it:it+dt,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(it:it+dt,:,:), 0)
    t_adv_1h   = dim_sum_n(t_adv(it:it+dt,:,:), 0)

    t_heat_1h  = dim_sum_n(t_heat(it:it+dt,:,:), 0)
    t_pbl_1h   = dim_sum_n(t_pbl(it:it+dt,:,:), 0)
    ;t_cu_1h    = dim_sum_n(t_cu(it:it+dt,:,:), 0)
    ;t_ra_1h    = dim_sum_n(t_ra(it:it+dt,:,:), 0)
    t_diff_1h  = dim_sum_n(t_diff(it:it+dt,:,:), 0)

    t_adv_1h = t_adv_h_1h + t_adv_v_1h

    pt_sum_1h   = dim_avg_n(t_sum_1h(46:48,0:199),0)
    pt_adv_h_1h = dim_avg_n(t_adv_h_1h(46:48,0:199),0)
    pt_adv_v_1h = dim_avg_n(t_adv_v_1h(46:48,0:199),0)
    pt_adv_1h   = dim_avg_n(t_adv_1h(46:48,0:199),0)

    pt_heat_1h  = dim_avg_n(t_heat_1h(46:48,0:199),0)
    pt_pbl_1h   = dim_avg_n(t_pbl_1h(46:48,0:199),0)
    ;pt_cu_1h    = dim_avg_n(t_cu_1h(46:48,0:199),0)
    pt_diff_1h  = dim_avg_n(t_diff_1h(46:48,0:199),0)

    ;printVarSummary(pt_cu_1h)

    t_temp1 = th(it+dt+1,:,:)-th(it,:,:)
    t_temp  = dim_avg_n(t_temp1(46:48,0:199),0)

    pt = new((/9,200/),float)
    nmin = 10*60

    pt(0,:) = pt_adv_h_1h*nmin
    pt(1,:) = pt_adv_v_1h*nmin
    pt(2,:) = pt_adv_1h*nmin

    pt(3,:) = pt_heat_1h*nmin
    pt(4,:) = 0.
    pt(5,:) = pt_pbl_1h*nmin
    pt(6,:) = pt_diff_1h*nmin

    pt(7,:) = pt_sum_1h*nmin
    pt(8,:) = t_temp

    ;t_temp(:,:) = smth9(t_temp(:,:), 0.5, -0.25, True)
   
  res                     = True
  gres                    = True

  plot2 = new(2,graphic)
  
  ares = True
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame

  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "Theta (K)"
 
  r1 = fspan(0.0,400.0,200)
  ;print(r1)
  
  ;ares@tmXBMode    = "Explicit"
  ;ares@tmXBValues  = (/0, 22, 43, 64, 85/)
  ;ares@tmXBLabels  = (/0,100,200,300,400/)

  ares@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  ares@vpHeightF        = 0.4            ; make plot as large as possible.

  ;ares@trYMinF          = -10           ; Set min/max of left Y axis
  ;ares@trYMaxF          = 10

  ares@xyLineThicknessF = 2.0
  ares@xyLineColors       = (/3,5,6,7,9,10,11,13,15/) ; colors chosen
  ares@xyDashPatterns   = 0.      ; make all lines solid
  
  ares@pmLegendDisplayMode    = "Always"            ; turn on legend
  ares@pmLegendSide           = "Top"               ; Change location of 
  ares@pmLegendParallelPosF   = .80                  ; move units right
  ares@pmLegendOrthogonalPosF = -0.45                ; move units down
  ares@pmLegendWidthF         = 0.15                ; Change width and
  ares@pmLegendHeightF        = 0.15                ; height of legend.
  ares@lgPerimOn              = False               ; turn off box around
  ares@lgLabelFontHeightF     = .01                 ; label font height
  ares@xyExplicitLegendLabels = (/"Horizontal Advection","Vertical Advection"," Total Advection", \
                                 "Nonadiabatic heating","Cu","PBL","Diffusion"/)         ; create explicit labels


  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025

  
  time = (it*10/60.)
  ;ares@tiMainString = "time = " + (time+0.5) + "h"

  plot2(0) = gsn_csm_xy(wks, r1(0:199), pt(0:6,:), ares)

  ares@pmLegendParallelPosF   = .85                  ; move units right
  ares@pmLegendOrthogonalPosF = -0.8              ; move units down
  ares@pmLegendWidthF         = 0.15                ; Change width and
  ares@pmLegendHeightF        = 0.15                ; height of legend.
  ares@lgPerimOn              = False               ; turn off box around
  ;ares@lgLabelFontHeightF     = .03                 ; label font height
  ares@xyExplicitLegendLabels = (/"Sum of RHS","Actual change"," Total Advection", \
                                 "Nonadiabatic heating","Cu","PBL","Diffusion"/)
  
  ares@gsnYRefLine    = 0.0 ; four X reference lines 
  ares@gsnYRefLineThicknessF = 1.5 
  ares@xyLineThicknessF = 2.5

  ares@trYMinF          = -3           ; Set min/max of left Y axis
  ares@trYMaxF          = 3

  plot2(1) = gsn_csm_xy(wks, r1(0:199), pt(7:8,:), ares)

  ;ares@tiMainString = "diffrence"
  ;plot9(8) = gsn_csm_y(wks,r1,t_dire, ares)

  gres@txString = "time = " + time +"h - "+ (time+3) + "h" +" height = 13.5km"
  gsn_panel(wks, plot2, (/2,1/), gres)

  delete(ares@trYMinF)
  delete(ares@trYMaxF)

end do

  
  ;overlay(plot9(0), plot9(1))
  ;overlay(plot9(0), plot9(2))
  ;overlay(plot9(0), plot9(3))
  ;overlay(plot9(0), plot9(4))
  ;overlay(plot9(0), plot9(5))
  ;overlay(plot9(0), plot9(6))
  ;overlay(plot9(0), plot9(7))

  ;draw(plot9(0))


  ;plots(n) =  gsn_csm_contour(wks,th(119,0:41,:), res)




end












