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


    files = systemfunc("ls ./sim9_v3/tano_*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_wrfv3/tano_d1_00.nc","r")
    t_ano = ano_h[:]->ta

    hei = fspan(500, 27500, 68)/1000
    r1 = fspan(0.0,700.0,150)
    hei@units = "m"
    r1@units = "km"
    print(r1)

    printVarSummary(t_ano)

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9_v3/ta_automatic") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    n = 0
    
    nt = 120*9
    plots = new(nt/5,graphic)
    dt = 5 ;;;30min

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

do it = 0, nt-1, dt

  res                     = True

  gres                    = True
  
  res@gsnDraw            = True                   ; don't draw
  res@gsnFrame           = True                   ; don't advance frame
  res@cnFillOn            = True
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False
  ;res@cnLineThicknesses   = 1.5
  ;gres@gsMarkerIndex = 0
  ;gres@gsMarkerSizeF    = 0.015
  ;gres@gsMarkerColor       = "navy"                 ; color chosen
  ;gres@gsMarkerThicknessF = 3
  ;res@xyLineThicknesses = 2.0
  ;res@tiMainString = "Sea Level Pressure ~c~ Max Wind Speed"
  
  
  ;res@tiYAxisString           = "height(km)"
  ;res@tiXAxisString           = "times(hr)"
  ;res@tiMainString = "Hovmoller 72-96h (r=0km)"

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = (/5,10,15,20/)
 ; res@tmYLValues  = (/12,25,38,51/)

  ;ti = ispan(0, 479, 1)
  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = ti(::40)
  ;res@tmXBLabels   = ti(::40)*3/60+72
  
  ;t_ano2=transpose(t_ano(:,0:44,1))
  ;plots = gsn_csm_contour(wks,t_ano2, res)

    res@gsnDraw            = False                   ; don't draw
    res@gsnFrame           = False                   ; don't advance frame

    res@tmXBMode    = "Explicit"
    res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    res@tmYLMode    = "Explicit"
    res@tmYLValues  = (/0, 11,24,36,40/)
    res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    ;if (n.le.2) then
      ;res@cnLevelSpacingF = 0.2
      ;res@cnMinLevelValF  = -3
      ;res@cnMaxLevelValF  = 3
    ;else
      ;res@cnLevelSpacingF = 0.2
      ;res@cnMinLevelValF  = -7
      ;res@cnMaxLevelValF  = 7
    ;end if

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

    res@lbLabelBarOn        = False           ; turn off individual cb's
    
    time = it*6/60.
    res@tiMainString = "time = " + time + "h"
    plots(n) =  gsn_csm_contour(wks,t_ano(it,0:41,:), res)
    n = n+1

end do
  
  res@cnLevelSelectionMode = "AutomaticLevels"   ; set explicit contour levels
  res@tiMainString = "time = " + (time+1) + "h"
  ;plots(n) =  gsn_csm_contour(wks,t_ano(nt-1,0:41,:), res)
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@txString = "Theta Anomaly"
  gsn_panel(wks, plots(0:23), (/4,6/), gres_ta)
  gsn_panel(wks, plots(24:47), (/4,6/), gres_ta)
  gsn_panel(wks, plots(47:71), (/4,6/), gres_ta)
  gsn_panel(wks, plots(72:95), (/4,6/), gres_ta)
  gsn_panel(wks, plots(96:119), (/4,6/), gres_ta)
  gsn_panel(wks, plots(120:143), (/4,6/), gres_ta)
  gsn_panel(wks, plots(143:167), (/4,6/), gres_ta)
  gsn_panel(wks, plots(168:191), (/4,6/), gres_ta)
  gsn_panel(wks, plots(192:215), (/4,6/), gres_ta)

end












