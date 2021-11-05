load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    files = systemfunc("ls ./sim8/theta_ano*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    t_ano = ano_h[:]->ta

    hei = fspan(500, 26500, 68)/1000
    r1 = fspan(0.0,700.0,150)
    hei@units = "m"
    r1@units = "km"
    times =ispan(0, 2880, 1)

  printVarSummary(t_ano)
  ;print(hei)
  ;print(r1)
  ;print(times)

  ;FirstTime = True
  ;times  = wrf_user_getvar(ano_h,"times",-1)   ; get times in the file
  ;ntimes = dimsizes(times)          ; number of times in the file

  wks = gsn_open_wks("pdf","sim8/hov_theta")
  gsn_define_colormap(wks, "MPL_coolwarm")

  plot = new(2,graphic)

  res = True
  
  res@cnFillOn = True
  ;res@cnLinesOn = True
  ;res@cnLineThicknessF  = 2.0
  ;res@gsnContourNegLineDashPattern  = 11

  res@cnLineLabelsOn    = False
  ;res@pmLabelBarDisplayMode = "Always"
  ;;res@cnLineLabelPerimOn = True
  ;res@cnLineLabelPerimColor = -1
  ;res@cnLineLabelBackgroundColor = -1

  res@gsnLeftString   = ""
  res@lbLabelBarOn        = False           ; turn off individual cb's
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevelSpacingF = 0.2
  res@cnLevels     = (/-4,-2,  0, 1, 3, 5, 7, 9, 11, 13 /)   ; set levels
  res@cnFillColors = (/ 2, 8, 32, 0,80,90,93,96,108,120,126/)  ; set the colors to be used
  
  res@tiXAxisString  = "times(h)"
  res@tmXBMode = "Explicit"
  res@tmXBValues  = times(::240)
  res@tmXBLabels  = times(::240)*3/60
  
  res@tmYLMode = "Explicit"
  res@tmYLValues  = (/0,4,12,17,22,28,35,40/)
  res@tmYLLabels   =(/0,2,5,  7, 9,11,14,16/)
  
  res@tiYAxisString  = "height(km)"
  res@tiMainString = "r=0km"
  
  tmp = transpose(t_ano(:,0:42,1))
  plot(0) = gsn_csm_contour(wks, tmp, res)

  res@tmYLMode = "Explicit"
  res@tmYLValues  = (/0,20,40,60,80,100,120,140/)
  res@tmYLLabels  = round(r1(::20),3)
  
  res@tiYAxisString  = "Radius(Km)"
  res@tiMainString = "h=14km"

  tmp2 = transpose(t_ano(:,35,:))
  plot(1) = gsn_csm_contour(wks, tmp2, res)

  gres = True
  gres@gsnPanelLabelBar = True
  gres@txString = "theta anomaly (relative to 500-800km)"
   
  gsn_panel(wks, plot, (/1,2/), gres)

end




