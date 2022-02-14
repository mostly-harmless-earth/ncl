load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    ;files = systemfunc("ls ./sim_lev100/ev/d01_ev*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    files = systemfunc("ls ./sim_lev100/d01/tha*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    th = ano_h[:]->th
    printVarSummary(th)

    dd = dimsizes(th)
    ntimes = dd(0)
    nz = dd(1)
    nr = dd(2)

    ;t_ano    = new((/ntimes,nz,nr/),"float")

    t_ano = dim_avg_n(th(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    dim = dimsizes(t_ano)
    print(dim)

    hei = fspan(500, 27500, 100)/1000
    r1 = fspan(0.0,400.0,200)
    hei@units = "m"
    r1@units = "km"
    times =ispan(0, dim(0)-1, 1)

  printVarSummary(t_ano)
  ;print(hei)
  ;print(r1)
  ;print((times))

  ;FirstTime = True
  ;times  = wrf_user_getvar(ano_h,"times",-1)   ; get times in the file
  ;ntimes = dimsizes(times)          ; number of times in the file

  wks = gsn_open_wks("pdf","sim_lev100/hov_enviroment_d01_1000-1500")
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

  plot = new(2,graphic)

  res = True
  
  res@cnFillOn = True
  res@cnLinesOn = False
  ;res@cnLineThicknessF  = 2.0
  ;res@gsnContourNegLineDashPattern  = 11

  res@cnLineLabelsOn    = False
  ;res@pmLabelBarDisplayMode = "Always"
  ;;res@cnLineLabelPerimOn = True
  ;res@cnLineLabelPerimColor = -1
  ;res@cnLineLabelBackgroundColor = -1

  res@gsnLeftString   = ""
  res@lbLabelBarOn        = True          ; turn off individual cb's
  
  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ;res@cnLevels     = (/-4,-2,  0, 1, 3, 5, 7, 9, 11, 13 /)   ; set levels
  ;res@cnFillColors = (/ 2, 8, 32, 0,80,90,93,96,108,120,126/)  ; set the colors to be used

    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    res@cnLevelSpacingF = 0.1
    res@cnMinLevelValF  = -2.
    res@cnMaxLevelValF  = 2.
  
  res@tiXAxisString  = "times(h)"
  res@tmXBMode = "Explicit"
  res@tmXBValues  = times(::12)
  res@tmXBLabels  = times(::12)*60/60.
  
    res@tmYLMode    = "Explicit"
    res@tmYLValues  = (/0, 17,35,53,61/)
    res@tmYLLabels  = (/0.5,5,10,15,17/)
  
  res@tiYAxisString  = "height(km)"
  res@tiMainString = "r = 1000-1500 km"
  
  tmp = transpose(t_ano(::6,0:62))
  printVarSummary(tmp)
  ttm = new((/63,120/),float)
  ;ttm = runave_n(ttm, 5, 0, 1)
  ;ttm = runave_n(ttm, 5, 0, 0)

  do it = 0,118
    ttm(:,it) = tmp(:,it+1)-tmp(:,it)
  end do

  plot(0) = gsn_csm_contour(wks, ttm, res)

  do it = 0,118
    ttm(:,it) = tmp(:,it+1)-tmp(:,1)
  end do

  plot(1) = gsn_csm_contour(wks, ttm, res)

  gres = True
  gsn_panel(wks, plot, (/1,2/), res)


end




