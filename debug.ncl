load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin


;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200
  r = fspan(0.0,400.0,nr)
  r@units = "km"

  nz = 100  ; Sigma levels
  hei = fspan(500, 27500, 100)

  degtorad = 2*3.14159/360.0
  radtodeg = 180.0/3.14159
  alfa = fspan(0.0,359.0,360)
  alfa = alfa*degtorad

  dx = new((/nr,360/),"float")
  dy = new((/nr,360/),"float")

 do i = 0,nr-1,1
    do j = 0,359,1
         dx(i,j)= r(i)*cos(alfa(j))
         dy(i,j)= r(i)*sin(alfa(j))
    end do
end do
  
  lat_p = new(nr*360,"float")
  lon_p = new(nr*360,"float")
  
  do i = 0, nr-1, 1
    do j = 0, 359, 1

      lat_p(i*360+j) = dx(i,j)
      lon_p(i*360+j) = dy(i,j)
    
    end do
  end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
         ; "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
         ; "5_00","5_06","5_12","5_18"/)

    ;nn1 = (/"100","106","112","118","200","206","212","218",\
          ;"300","306","312","318","400","406","412","418",\
          ;"500","506","512","518"/)
    
    ;in = 5
  
    files = systemfunc("ls ./sim_lev100/bud/ang_adv_v_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_adv_v = ano_h[:]->t_adv_v

    files = systemfunc("ls ./sim_lev100/bud/ang_adv_h_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_adv_h = ano_h[:]->t_adv_h(:,0:90,:,:)

    printVarSummary(t_adv_h)

    ;files = systemfunc("ls ./sim_lev100/bud/hori/adv_v_02*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")
    ;vhori = ano_h[:]->t_adv_v

    ;files = systemfunc("ls ./sim_lev100/bud/hori/hv_adv_h_02*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")
    ;hhori = ano_h[:]->t_adv_h

    files = systemfunc("ls ./sim_lev100/budget_or/adv_v_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    vhori = ano_h[:]->T_TEND_ADV_V

    files = systemfunc("ls ./sim_lev100/budget_or/adv_h_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    hhori = ano_h[:]->T_TEND_ADV_H

    printVarSummary(hhori)
 
    t_adv_h = runave_n(t_adv_h, 3, 0, 1)
    t_adv_v = runave_n(t_adv_v, 3, 0, 1)

    vhori = runave_n(vhori, 3, 0, 1)
    hhori = runave_n(hhori, 3, 0, 1)

    wks=gsn_open_wks("pdf","sim_lev100/hor_interp_test2") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    ;;; t_sum: 36 X 420 X 420
    ;;; interval 10 min 
    ;;; 1h: 6 ;;; 2h: 12

    n = 0
    dims = dimsizes(t_adv_v)
    plots = new(12,graphic)

    ;do i = 0,3,1

    ;timi = (/198,276,396,492/) ;;;33h, 46h, 66h, 82h
    ;dtg  = (/29,59,119,59/)
    
    ;it = timi(i)
    ;dt = dtg(i)
    
    it = 54
    dt = 36
    nmin = 10*60

    t_adv_h_1h = dim_sum_n(t_adv_h(it:it+dt,:,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(it:it+dt,:,:,:), 0)

    hhori_1h = dim_sum_n(hhori(it:it+dt,:,:,:), 0)/10000.
    vhori_1h = dim_sum_n(vhori(it:it+dt,:,:,:), 0)/10000.

    t_adv_1h = t_adv_h_1h + t_adv_v_1h

  gres                    = True
  plot9 = new(9,graphic)
  plot6 = new(2,graphic)
  vp = new(100, graphic)

  res = True
  res@cnFillOn            = True
  res@cnLinesOn           = False

  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  res@vpWidthF           = .5
  res@vpHeightF          = .5

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 17,35,53/)
  ;res@tmYLLabels  = (/0.5,5,10,15/)

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 7, 14,21,28/)
  ;res@tmYLLabels  = (/10,12,14,16,18/)

  ;res@vpWidthF           = .6
  ;res@vpHeightF          = .4

    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    res@cnLevelSpacingF = 50.
    res@cnMinLevelValF  = -400.
    res@cnMaxLevelValF  = 400.

  bt_adv_v_1h = ndtooned(t_adv_v_1h(48,:,:))
  bt_adv_h_1h = ndtooned(t_adv_h_1h(48,:,:))
  
  res@tiMainString = "Horizontal Advection uninterpolation"
  plot9(0) = gsn_csm_contour(wks,hhori_1h(48,:,:)*nmin, res)
  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*720, ares)
  
  res@tiMainString = "Vertical Advection interpolation"
  plot9(1) = gsn_csm_contour(wks,vhori_1h(48,:,:)*nmin, res)

  ares = True
  
  ares@trGridType        = "TriangularMesh"
  ares@sfXArray = lat_p
  ares@sfYArray = lon_p
  
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame
  
  ares@vpWidthF           = .5
  ares@vpHeightF          = .5
  
  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "height(km)"
  ares@cnFillOn                = True
  ares@cnLinesOn               = False 

  ;ares@tmXMajorGrid          = True               ; Add white grid lines
  ;ares@tmXMajorGridLineColor = "gray"
  ;ares@tmYMajorGrid          = True
  ;ares@tmYMajorGridLineColor = "gray"

  ;ares@tiYAxisFontHeightF      = 0.025
  ;ares@tiXAxisFontHeightF      = 0.025
  ;ares@tmXBLabelFontHeightF    = 0.025
  ;ares@tmYLLabelFontHeightF    = 0.025
  ;ares@tmYRLabelFontHeightF    = 0.025
  ;ares@gsnStringFontHeightF    = 0.025

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;ares@cnLevelSpacingF = 20.
    ;ares@cnMinLevelValF  = -100.
    ;ares@cnMaxLevelValF  = 100.
  ;end if

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ares@cnLevelSpacingF = 50.
  ares@cnMinLevelValF  = -400.
  ares@cnMaxLevelValF  = 400.

  ares@tiMainString = "Horizontal Advection"
  plot9(2) = gsn_csm_contour(wks,bt_adv_h_1h*nmin, ares)
  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*720, ares)
  
  ares@tiMainString = "Vertical Advection"
  plot9(3) = gsn_csm_contour(wks,bt_adv_v_1h*nmin, ares)
  
  ;gres = True
  ;gres@tiMainString = "theta Budget Term 1 hour"
  ;gsn_panel(wks, plot9, (/2,3/), gres)

  ;ares@cnFillOn  = False
  ;ares@cnLinesOn = True 
  ;ares@cnLineThicknessF = 1.5
  ;ares@cnLineColor = "black"
 
  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-5,-4,-3,-2,-1.5,-1/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,148,152,167,183,199,215/)  ; set the colors to be used

  ;ne1 = gsn_csm_contour(wks,t_temp(48,:,:), ares)
  ;ne2 = gsn_csm_contour(wks,t_temp(48,:,:), ares)

  ;overlay(plot9(3), ne1)
  ;overlay(plot9(4), ne2)

  ;gres@gsnPanelLabelBar = True
  gsn_panel(wks, plot9(0:3), (/2,2/), gres)


;end do

end












