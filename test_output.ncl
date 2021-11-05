load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  a = addfile("/user_home/jyyin/dta/outputsim5/ta_azi_interp.nc","r")
  b = addfile("/user_home/jyyin/dta/outputsim5/tangential_azi_interp.nc","r")
  c = addfile("/user_home/jyyin/dta/outputsim5/radial_azi_interp.nc","r")
  d = addfile("/user_home/jyyin/dta/outputsim5/w_azi_interp.nc","r")

  ;print(a)
  print(b)
  print(c)
  print(d)

  t = a->ta 
  tangential = b->tanget
  radial = c->radi
  w = d->w

  wks = gsn_open_wks("pdf","sim5/test-output2")
  gsn_define_colormap(wks, "MPL_coolwarm")
  res = True
  res@cnFillOn = True
  res@cnLinesOn = False
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  res@cnLevels     = (/ -2,-1.5, -1,-0.5, 0, 0.5,1.5, 3, 5,  7,  9, 11, 13/)   ; set levels
  res@cnFillColors = (/  2,   8, 16,  24, 32, 0, 80,90,93,  96, 108,120,126,129/)  ; set the colors to be used


  plot = gsn_csm_contour(wks, t(0,0:42,0:80), res)
  ;plot = gsn_csm_contour(wks, tangential(1001,:,:), res)
  ;plot = gsn_csm_contour(wks, radial(1001,:,:), res)
  ;plot = gsn_csm_contour(wks, w(1001,:,:), res)

  res@stLineThicknessF = 1.8
  res@stLevelSelectionMode = "ManualLevels"
  res@stLevelSpacingF = 4.0
  
  ;plot2 = gsn_csm_streamline(wks, radial(1001,0:42,0:80), w(1001,0:42,0:80)*(10.0), res)

  overlay(plot, plot2)
  draw(plot)



end