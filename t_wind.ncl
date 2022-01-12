load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  a = addfile("/user_home/jyyin/dta/sim_lev100/radial_wind.nc","r")
  b = addfile("/user_home/jyyin/dta/sim_lev100/tangential_wind.nc","r")
  c = addfile("/user_home/jyyin/dta/sim_lev100/vertical_wind.nc","r")
  
  radial = a->wrad
  tangential = b->wtan
  wwnd = c->ww

  ;files = systemfunc("ls ./sim9_v3/tha/tano_*")
  ;ano_h = addfiles(files, "r")
  ;ListSetType(ano_h, "cat")

  ;ano_h = addfile("sim9_wrfv3/tano_d1_00.nc","r")
  ;t_ano = ano_h[:]->ta


  ;print(a)
  ;print(b)
  ;print(c)
  ;print(d)
  printVarSummary(radial)
  printVarSummary(tangential)
  printVarSummary(wwnd)
  ;printVarSummary(t_ano)

  nr = 250
  r = fspan(0.0,2500.0,nr)
  print(r)


  wks = gsn_open_wks("pdf","sim_lev100/test-wind")
  gsn_define_colormap(wks, "MPL_RdBu")
  gsn_reverse_colormap(wks)

  
  res = True
  res@cnFillOn = True
  res@cnLinesOn = False

  res@gsnFrame = False
  res@gsnDraw  = False

  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
  ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0, 11,24,36,40/)
  res@tmYLLabels  = (/0.5,5,10,15,17/)

  
  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ;res@cnLevels     = (/ -2,-1.5, -1,-0.5, 0, 0.5,1.5, 3, 5,  7,  9, 11, 13/)   ; set levels
  ;res@cnFillColors = (/  2,   8, 16,  24, 32, 0, 80,90,93,  96, 108,120,126,129/)  ; set the colors to be used

  do it = 0,49,5

  pls =new(3, graphic)

  pls(0) = gsn_csm_contour(wks, radial(it,:,0:70), res)
  pls(1) = gsn_csm_contour(wks, tangential(it,:,0:70), res)
  pls(2) = gsn_csm_contour(wks, wwnd(it,:,0:70), res)
  

  ;res@tiLeftString         = "Streamline"
  ;res@stArrowLengthF       = 0.015         ; changes the size of the arrows.
  ;res@stLevelSelectionMode = "ManualLevels"
  ;res@stLevelSpacingF      = 1000
  ;res@stLineThicknessF     = 1.5           ; changes the line thickness
  ;res@stLineColor          = "Black"      ; changes color
  ;pls(3) = gsn_csm_streamline(wks, radial(1000,0:41,:), wwnd(1000,0:41,:)*10, res)

  mres = True
  ;mres@gsnPanelLabelBar    = True                ; add common colorbar
  ;mresP@lbLabelFontHeightF  = 0.007               ; make labels smaller
  gsn_panel(wks, pls(:), (/1,3/), mres)

end do


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = (/0, 22, 43, 64, 85,107/)
  ;res@tmXBLabels  = (/0,100,200,300,400,500/)

    res@tmXBMode    = "Explicit"
    res@tmXBValues  = (/0, 10, 20, 30, 40,50,60/)
    res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    res@tmYLMode    = "Explicit"
    res@tmYLValues  = (/0, 17,35,53,60/)
    res@tmYLLabels  = (/0.5,5,10,15,17/)

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 11,24,36,40/)
  ;res@tmYLLabels  = (/0.5,5,10,15,17/)
 
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
  
  res@cnLineThicknessF  = 2.3
  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False

do it = 1000, 1100, 5

;------------------------ radial wind --------------------------------------------------

  res_radial = res
  res_radial@gsnLeftString  = "Temprature Anomaly (shading,K) ~C~Radial wind Speed (contour,black) ~C~Tangential wind Speed (contour,red) ~C~  "
  res_radial@gsnRightString = "T = "+ it*6/60. +" h"
  res_radial@cnFillOn = False
  res_radial@cnLinesOn = True

  res_radial@gsnContourNegLineDashPattern  = 11
  res_radial@cnLineColor  =  "Black"
  ;res_radial@cnLevelSelectionMode = "ManualLevels"

  res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1

  ;res_radial@cnHighLabelsOn = True
  ;res_radial@cnLowLabelsOn  = True
  ;res_radial@cnLevelSpacingF  = 4
  ;res_radial@cnMaxLevelValF   = -4
  ;
   
   res_radial@cnMinLevelValF = -40.
   res_radial@cnMaxLevelValF   = 40.
   res_radial@cnLevelSpacingF   = 5
   ;radial_wind= gsn_csm_contour(wks,radial(it,0:41,0:120),res_radial)

;------------------------ tangential wind --------------------------------------------------
  res_tan = res
  res_tan@cnFillOn = False
  res_tan@cnLinesOn = True
  res_tan@gsnLeftString  = "Temprature Anomaly (shading,K) ~C~Radial wind Speed (contour,black) ~C~Tangential wind Speed (contour,red) ~C~  "
  res_tan@gsnRightString = "T = "+ it*6/60. +" h"
  res_tan@gsnContourNegLineDashPattern  = 11
  res_tan@cnLineColor  =  "red"
  res_tan@cnLevelSelectionMode = "ManualLevels"

  ;res_tan@cnMinLevelValF = 4.
  ;res_tan@cnMaxLevelValF   = 60.
  ;res_tan@cnLevelSpacingF   = 4.
  res_tan@cnLevelSpacingF   = 15.
  
   ;tangential_wind= gsn_csm_contour(wks,tangential(it,0:41,0:120),res_tan)

;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  res_w = res
  res_w@gsnFrame  = False
  res_w@gsnDraw   = False

  res_w@cnLineColor  =  "gray"
  res_w@cnFillOn = False
  res_w@cnLinesOn = True
  ;res_w@cnLevelSelectionMode = "ManualLevels"
  ;res_w@cnLineLabelsOn    = True
  ;res_w@cnLineLabelBackgroundColor = -1
  ;res_w@cnMaxLevelValF   = 20
  ;res_w@cnMinLevelValF   = 0.
  ;res_w@cnLevelSpacingF = 0.02
  
  ;w_wind = gsn_csm_contour(wks,wwnd(it,0:41,0:120),res_w) 

;--------------------------------------------------------------------------------
  res_t = True

  res_t@gsnFrame = False
  res_t@gsnDraw  = False

  res_t@gsnLeftString  = " "
  res_t@gsnRightString  = " "

  res_t@cnLevelSelectionMode = "ManualLevels" 
  res_t@cnLevelSpacingF = 0.5
  res_t@cnMinLevelValF  = -8
  res_t@cnMaxLevelValF  = 8

  res_t@cnFillOn = True
  res_t@cnLinesOn = False
  res_t@lbLabelBarOn        = True           ; turn off individual cb's
  ;res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
 ; res_t@cnLevels     = (/ -4, -3,-2,-1,-0.5,-0.3,0.3,0.5,  1,3 ,  5,  7,  9,13/)   ; set levels
  ;res_t@cnFillColors = (/  2,  8,16,26,  32,  40,  0, 75, 83,95,106,112,120,126,129/)  ; set the colors to be used
  res_t@cnLineLabelsOn = False                    ; turn the line labels off

  ;t_k = gsn_csm_contour(wks,t_ano(it,0:41,0:120),res_t) 
;--------------------------------------------------------------------------------

  ;overlay(t_k, radial_wind)
  ;overlay(t_k, tangential_wind)

  ;draw(t_k)
  ;frame(wks)

  ;t_k = gsn_csm_contour(wks,t_ano(it,0:41,0:120),res_t) 
  ;overlay(t_k, w_wind)
  
  ;draw(t_k)
  ;frame(wks)

end do


end