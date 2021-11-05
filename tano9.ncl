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

  ;printVarSummary(t_ano)
  ;print(hei)

  ;FirstTime = True
  ;times  = wrf_user_getvar(ano_h,"times",-1)   ; get times in the file
  ;ntimes = dimsizes(times)          ; number of times in the file

  wks = gsn_open_wks("pdf","sim8/t_ano16")
  gsn_define_colormap(wks, "MPL_coolwarm")

  res = True
  

  res@cnFillOn = True
  res@cnLinesOn = False
  
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevelSpacingF = 0.2
  res@cnLevels     = (/-2.5,-2,-1.5, -1,-0.5, 0,0.5, 1, 2, 3, 5,   7,  9/)   ; set levels
  res@cnFillColors = (/  2,  6,   8, 16,  24,32,  0,80,90,93,96,108,120,126/)  ; set the colors to be used
  res@lbLabelBarOn = False
  
  res@tmXBMode = "Explicit"
  res@tmXBValues  = (/0,20,40,60,80,100,120,140/)
  res@tmXBLabels  = round(r1(::20),3)
  
  res@tmYLMode = "Explicit"
  res@tmYLValues  = (/0,4,12,17,22,28,35,40/)
  res@tmYLLabels   =(/0,2,5,7,9,11,14,16/)

  res@tiYAxisString  = "height(km)"
  res@tiXAxisString  = "radius(km)"
  res@lbLabelBarOn        = False           ; turn off individual cb's

  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn       = False           ; turn off cn info label

  t_c = (/0,240,380,500,760,1140,1340,1560,2300/)
  plot = new(9,graphic)
 
 do itt = 0,8

   it = t_c(itt)
   ; ----------------- set Titles -----------------------------------------------
      ;res@tiMainString    = "theta anomaly (relative to 500-800km)"
      res@tiMainFont      = 22
      res@tiMainFontHeightF      = 0.023
      res@gsnStringFontHeightF   = 0.016
      res@gsnLeftString   = ""
      res@gsnRightString  = "Time:" + it*3/60 +"h"
   ; ----------------------------------------------------------------------------
    plot(itt) = gsn_csm_contour(wks, t_ano(it,0:44,:), res)

 end do
   
   gres = True
   gres@gsnPanelLabelBar = True
   gres@txString = "theta anomaly (relative to 500-800km)"
   
   gsn_panel(wks, plot, (/3,3/), gres)
   frame(wks)
   
end




