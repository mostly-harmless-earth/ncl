load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  f = addfile("/user_home/jyyin/dta/outputsim5/ta_azi_interp.nc","r")

  t_ano = f->ta

  printVarSummary(t_ano)
  nr = 150
  r = fspan(0.0,700.0,nr)
  r@units = "Km"
  t_ano&Radial = r

  hei = fspan(500, 26500, 68)
  hei@units = "m"
  t_ano&height = hei/1000

  print(hei)

  wks = gsn_open_wks("pdf","sim5/int-ta-hov-15")
  gsn_define_colormap(wks, "MPL_coolwarm")

  ;plot = new(9,"graphic")

;------------------------ temprature anomaly -------------------------------------
  res = True

  ;res@gsnDraw = False
  ;res@gsnFrame = False

  res@gsnLeftString  = "T Anomaly (K)"
  ;res@gsnRightString = " Hovmoller "
  res@cnFillOn = True
  res@cnLinesOn = True
  res@cnLineThicknessF  = 1.5
  res@gsnContourNegLineDashPattern  = 11
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels     = (/ -2,-1.5, -1,-0.5, 0, 0.5,1.5, 3, 5,  7,  9, 11, 13/)   ; set levels
  res@cnFillColors = (/  2,   8, 16,  24, 32, 0, 80,90,93,  96, 108,120,126,129/)  ; set the colors to be used
  ;res@cnLevelSelectionMode = "ManualLevels"
  ;res@cnLevelSpacingF   = 2
  ;res@tiYAxisString           = "Radial(km)"
  ;res@tiXAxisString           = "times"
  ;res@cnLineLabelsOn    = True
  ;res@cnLineLabelPerimOn = True
  ;res@cnLineLabelPerimColor = -1
  ;res@cnLineLabelBackgroundColor = -1
  ;res@lbLabelBarOn        = False           ; turn off individual cb's
  
  ;res@tiMainString = "T = 100 h"
  ;temp = gsn_csm_contour(wks,t_ano(100,:,:),res) 

  ;res@tiMainString = "T = 120 h"
  
  ;temp = gsn_csm_contour(wks,t_ano(120,:,:),res) 

  ;res@tiMainString = "T = 150 h"
  ;temp = gsn_csm_contour(wks,t_ano(150,:,:),res) 

  res@tiMainString = "height = 14.7 Km"

  ;ttt = (/80,200,500,700,900,1000,1500,1800,1980/)
  ;do kt = 0, 8
    ;it = ttt(kt)
    ;res@gsnRightString = "T = "+ it*3 +" min"
    t_ano2=transpose(t_ano(:,37,:))
    plot = gsn_csm_contour(wks,t_ano2,res)
  ;end do

  ;mres = True
  ;mres@gsnPanelLabelBar    = True                ; add common colorbar
  ;gsn_panel(wks, plot(:), (/3,3/), mres)




end