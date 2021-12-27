load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  a = addfile("/user_home/jyyin/dta/sim9_v3/radial_wind.nc","r")
  b = addfile("/user_home/jyyin/dta/sim9_v3/tangential_wind.nc","r")
  c = addfile("/user_home/jyyin/dta/sim9_v3/vertical_wind.nc","r")
  
  radial = a->wrad
  tangential = b->wtan
  wwnd = c->ww

  files = systemfunc("ls ./sim9_v3/tha/tano_*")
  ano_h = addfiles(files, "r")
  ListSetType(ano_h, "cat")

  ;ano_h = addfile("sim9_wrfv3/tano_d1_00.nc","r")
  t_ano = ano_h[:]->ta


  ;print(a)
  ;print(b)
  ;print(c)
  ;print(d)
  printVarSummary(radial)
  printVarSummary(tangential)
  printVarSummary(wwnd)
  printVarSummary(t_ano)


  wks = gsn_open_wks("pdf","sim9_v3/test-wind")
  gsn_define_colormap(wks, "MPL_coolwarm")
  
  res = True
  res@cnFillOn = True
  res@cnLinesOn = False

  res@tmXBMode    = "Explicit"
  res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
  res@tmXBLabels  = (/0,100,200,300,400,500,600/)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0, 11,24,36,40/)
  res@tmYLLabels  = (/0.5,5,10,15,17/)

  
  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ;res@cnLevels     = (/ -2,-1.5, -1,-0.5, 0, 0.5,1.5, 3, 5,  7,  9, 11, 13/)   ; set levels
  ;res@cnFillColors = (/  2,   8, 16,  24, 32, 0, 80,90,93,  96, 108,120,126,129/)  ; set the colors to be used


  plot = gsn_csm_contour(wks, radial(2,:,:), res)
  plot = gsn_csm_contour(wks, tangential(2,:,:), res)
  plot = gsn_csm_contour(wks, wwnd(2,:,:), res)

  plot = gsn_csm_streamline(wks, radial(2,:,:), wwnd(2,:,:)*10, res)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;plevels = (/1000.0,925.0,850.0,700.0,600.0,500.0,400.0,300.0,200.0,100.0,80.0,50.0,10.0/)
  ;hlevels = fspan(0.0,25.0,50)

  res = True
  res@gsnFrame = False
  res@gsnDraw  = False

  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = r
  ;res@tmXBLabels  = sprintf("%4.1f",r)
  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = sprintf("%4.1f",plevels)
  ;res@tmYLValues  =  plevels
  ;res@gsnRightString = "T = "+it+" h"
  ;res@trYMaxF     =  p(0,imin(it),jmin(it))+25.0
  ;res@trYMinF     =  80.0
  ;res@trXMinF     =  r(0)-2.5
  ;res@trXMaxF     =  r(49)+2.5
  ;res@tmYRTickSpacingF = 2
  
 
  ;res@tmXBMajorOutwardLengthF = 0.0
  ;;res@tmXBMajorLengthF        = 0.01 
  ;res@tmYLMajorOutwardLengthF = 0.0
  ;;res@tmYLMajorLengthF        = 0.01
  ;res@tmYRMajorOutwardLengthF = 0.0
  ;res@tmYRMajorLengthF        = 0.01
 
  res@tiYAxisString           = "height(km)"
  res@tiXAxisString           = "Radius (km)"
  res@tiYAxisFontHeightF      = 0.02
  res@tiXAxisFontHeightF      = 0.02
  res@tmXBLabelFontHeightF    = 0.015
  res@tmYLLabelFontHeightF    = 0.015
  res@tmYRLabelFontHeightF    = 0.015
  res@gsnStringFontHeightF    = 0.015

  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False

;------------------------ radial wind --------------------------------------------------

  res_radial = res
  res_radial@gsnLeftString  = "Temprature Anomaly (shading,K) ~C~Radial wind Speed (contour,black) ~C~Tangential wind Speed (contour,red) ~C~  "
  res_radial@gsnRightString = "T = "+it+" h"
  res_radial@cnFillOn = False
  res_radial@cnLinesOn = True
  res_radial@cnLineThicknessF  = 2.0
  res_radial@gsnContourNegLineDashPattern  = 11
  res_radial@cnLineColor  =  "Black"
  res_radial@cnLevelSelectionMode = "ManualLevels"

  res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1

  ;res_radial@cnHighLabelsOn = True
  ;res_radial@cnLowLabelsOn  = True
   res_radial@cnLevelSpacingF  = 4
   res_radial@cnMaxLevelValF   = -4
   radial_wind_ne= gsn_csm_contour(wks,radial_ave(22:50,0:120),res_radial)
   
   res_radial@cnMinLevelValF = 4
   res_radial@cnMaxLevelValF   = 60
   res_radial@cnLevelSpacingF   = 4
   radial_wind_po= gsn_csm_contour(wks,radial_ave(22:50,0:120),res_radial)

;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  res_w = res
  res_w@gsnFrame  = False
  res_w@gsnDraw   = False

  res_w@cnLineColor  =  "red"
  res_w@cnFillOn = False
  res_w@cnLinesOn = True
  res_w@cnLineThicknessF  = 2.0
  res_w@cnLevelSelectionMode = "ManualLevels"
  res_w@cnLineLabelsOn    = True
  res_w@cnLineLabelBackgroundColor = -1
  res_w@cnMaxLevelValF   = 20
  res_w@cnMinLevelValF   = 0.
  res_w@cnLevelSpacingF = 0.02
  
  w_wind = gsn_csm_contour(wks,w_ave(0:50,0:120),res_w) 

;--------------------------------------------------------------------------------
  res_t = True

  res_t@gsnFrame = False
  res_t@gsnDraw  = False

  
  res_t@cnFillOn = True
  res_t@cnLinesOn = False
  res_t@lbLabelBarOn        = False           ; turn off individual cb's
  res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res_t@cnLevels     = (/ -4, -3,-2,-1,-0.5,-0.3,0.3,0.5,  1,3 ,  5,  7,  9,13/)   ; set levels
  res_t@cnFillColors = (/  2,  8,16,26,  32,  40,  0, 75, 83,95,106,112,120,126,129/)  ; set the colors to be used
  res_t@cnLineLabelsOn = False                    ; turn the line labels off

  plot(kt) = gsn_csm_pres_hgt(wks,t_ano(0:50,0:120),res_t) 
;--------------------------------------------------------------------------------

  ;overlay(t_k, radial_wind_po)
  ;overlay(t_k, radial_wind_ne)
  ;overlay(t_k, w_wind)
  
end do

  mres = True
  mres@gsnPanelLabelBar    = True                ; add common colorbar
  ;mresP@lbLabelFontHeightF  = 0.007               ; make labels smaller
  gsn_panel(wks, plot(:), (/2,3/), mres)
  ;draw(t_k)
  ;frame(wks)



  ;plot = gsn_csm_contour(wks, radial(1001,:,:), res)
  ;plot = gsn_csm_contour(wks, w(1001,:,:), res)

end