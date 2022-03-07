load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    ;files = systemfunc("ls ./sim_lev100/tha/for_tano*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")
    ;t_ano = ano_h[:]->ta
    d = addfile("/user_home/jyyin/dta/sim_lev100/angle/d7_t0_ta.nc","r")
    t_ano = d->ta

    d = addfile("/user_home/jyyin/dta/sim_lev100/d02/rela_d02_t0_tano.nc","r")
    t_d2ano = d->ta

    dim = dimsizes(t_ano)
    print(dim)

    hei = fspan(500, 27500, 100)/1000
    r1 = fspan(0.0,400.0,200)
    hei@units = "m"
    r1@units = "km"
    times =ispan(0, dim(0)-1, 1)

  printVarSummary(t_d2ano)
  print(hei)
  ;print(r1)
  ;print((times))

  ;FirstTime = True
  ;times  = wrf_user_getvar(ano_h,"times",-1)   ; get times in the file
  ;ntimes = dimsizes(times)          ; number of times in the file

  wks = gsn_open_wks("pdf","sim_lev100/hov_theta_d7")
    gsn_define_colormap(wks,"MPL_RdBu")
    ;gsn_reverse_colormap(wks)

  plot = new(12,graphic)

  res = True

  res@gsnDraw = False
  res@gsnFrame = False
  
  res@cnFillOn = True
  res@cnLinesOn = False
  ;res@cnLineThicknessF  = 2.0
  ;res@gsnContourNegLineDashPattern  = 11

  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn      = False

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.4            ; make plot as large as possible.
  
  ;res@pmLabelBarDisplayMode = "Always"
  ;;res@cnLineLabelPerimOn = True
  ;res@cnLineLabelPerimColor = -1
  ;res@cnLineLabelBackgroundColor = -1

  res@gsnLeftString   = ""
  res@lbLabelBarOn        = False           ; turn off individual cb's
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels     = (/ -5, -4, -3,-2,-1, 0, 1, 3, 5, 7, 9,11, 13,15 /)   ; set levels
  res@cnFillColors = (/120,110,100,90,82,73,66,60,50,40,30,20, 10, 9,8/)  ; set the colors to be used

    ;res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    ;res@cnLevelSpacingF = 0.5
    ;res@cnMinLevelValF  = -5
    ;res@cnMaxLevelValF  = 5
  
  res@tiXAxisString  = "Hours"
  res@tmXBMode = "Explicit"
  res@tmXBValues  = times(::12)
  res@tmXBLabels  = times(::12)*60/60.
  
  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/17,24,35,46,53,61/)
  res@tmYLLabels  = (/ 5, 7,10,13,15,17/)

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 7, 14,21,28/)
  ;res@tmYLLabels  = (/12,14,16,18,20/)

  res@tiYAxisString  = "height(km)"
  res@tiMainString = "r = 0 km"

  tp2 = dim_avg_n(t_ano(::6,0:62,0:5),2)
  tp = transpose(tp2)
  plot(0) = gsn_csm_contour(wks, tp, res)

  res@tiMainString = "r = 100 km"

  tp2 = dim_avg_n(t_ano(::6,0:62,50:55),2)
  tp = transpose(tp2)
  plot(1) = gsn_csm_contour(wks, tp, res)

  res@tiMainString = "r = 200 km"

  tp2 = dim_avg_n(t_ano(::6,0:62,100:105),2)
  tp = transpose(tp2)
  plot(2) = gsn_csm_contour(wks, tp, res)

  res@tiMainString = "r = 300 km"

  tp2 = dim_avg_n(t_ano(::6,0:62,150:155),2)
  tp = transpose(tp2)
  plot(3) = gsn_csm_contour(wks, tp, res)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0,40, 80, 120,160,199/)
  res@tmYLLabels  = (/0,80, 160,240,320,400/)

  res@tiYAxisString  = "Radius(Km)"
  res@tiMainString = "h = 13km"

  tmp2 = dim_avg_n(t_ano(::6,45:47,:),1)
  tmp3 = transpose(tmp2)
  plot(4) = gsn_csm_contour(wks, tmp3, res)
 
  res@tiYAxisString  = "Radius(Km)"
  res@tiMainString = "h = 14km"

  tmp2 = dim_avg_n(t_ano(::6,49:51,:),1)
  tmp3 = transpose(tmp2)
  plot(5) = gsn_csm_contour(wks, tmp3, res)

  res@tiMainString = "h = 15km"

  tmp2 = dim_avg_n(t_ano(::6,53:55,:),1)
  tmp3 = transpose(tmp2)
  plot(6) = gsn_csm_contour(wks, tmp3, res)

  res@tiMainString = "h = 16km"

  tmp2 = dim_avg_n(t_ano(::6,56:58,:),1)
  tmp3 = transpose(tmp2)
  plot(7) = gsn_csm_contour(wks, tmp3, res)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/ 20, 40, 60,80 ,100,119/)
  res@tmYLLabels  = (/120,240,320,480,600,720/)

  res@tiYAxisString  = "Radius(Km)"
  res@tiMainString = "h = 13km"

  tmp4 = dim_avg_n(t_d2ano(::6,45:47,:),1)
  tmp5 = transpose(tmp4)
  plot(8) = gsn_csm_contour(wks, tmp5, res)
 
  res@tiYAxisString  = "Radius(Km)"
  res@tiMainString = "h = 14km"

  tmp4 = dim_avg_n(t_d2ano(::6,49:51,:),1)
  tmp5 = transpose(tmp4)
  plot(9) = gsn_csm_contour(wks, tmp5, res)

  res@tiMainString = "h = 15km"

  tmp4 = dim_avg_n(t_d2ano(::6,53:55,:),1)
  tmp5 = transpose(tmp4)
  plot(10) = gsn_csm_contour(wks, tmp5, res)

  res@tiMainString = "h = 16km"

  tmp4 = dim_avg_n(t_d2ano(::6,56:58,:),1)
  tmp5 = transpose(tmp4)
  plot(11) = gsn_csm_contour(wks, tmp5, res)

  gres = True
  gres@gsnPanelLabelBar = True
  gres@txString = "theta anomaly"
   
  gsn_panel(wks, plot, (/3,4/), gres)

end




