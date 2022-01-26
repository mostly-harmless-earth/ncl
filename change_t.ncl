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


   files = systemfunc("ls ./sim_lev100/tha/for_tano*")
   ano_h = addfiles(files, "r")
   ListSetType(ano_h, "cat")

    ;ano_h = addfile("/user_home/jyyin/dta/sim_lev100/tha/for_tano312.nc","r")
    t_ano_for = ano_h[:]->ta
    
    ;ano_h = addfile("/user_home/jyyin/dta/sim_lev100/tha/tano312.nc","r")
    ;t_ano = ano_h->ta
      
    ;nr = 120  ;;; 120 * 6 = 720 Km
    ;nz = 100   ; Sigma levels
    ;r = fspan(0.0, 720.0,nr)
    ;r@units = "km"
    
    ;hei = fspan(500, 27500, 100)/1000

    wks=gsn_open_wks("pdf","sim_lev100/t-change-6h") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

    dim = dimsizes(t_ano_for)
    print(dim)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    dt = 12 

    nt = dim(0)/dt
    print(dim(0))
    print(nt)
    plots = new(nt,graphic)
    n = 0
    

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

do it = 36, dim(0)-1, 36

  res                     = True

  gres                    = True
  
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame
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

    ;res@gsnDraw            = False                   ; don't draw
    ;res@gsnFrame           = False                   ; don't advance frame

    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 40, 80, 120,160,199/)
    ;res@tmXBLabels  = (/0, 80, 160,240,320,400/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 17,35,53,61/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)

    res@tmXMajorGrid          = True               ; Add white grid lines
    res@tmXMajorGridLineColor = "gray"
    res@tmYMajorGrid          = True
    res@tmYMajorGridLineColor = "gray"

    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    ;if (it.le.164) then
        res@cnLevelSpacingF = 0.05
        res@cnMinLevelValF  = -2.5
        res@cnMaxLevelValF  = 2.5
      ;else if (it.le.430) then
       ; res@cnLevelSpacingF = 0.8
        ;res@cnMinLevelValF  = -6.
       ; res@cnMaxLevelValF  = 6.
     ; else
         ; res@cnLevelSpacingF = 1.2
        ;  res@cnMinLevelValF  = -12
        ;  res@cnMaxLevelValF  = 12       
     ; end if
   ; end if

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

    res@lbLabelBarOn        = False           ; turn off individual cb's
    
    ;time = it*6/60.
    res@tiMainString = "time = " + (it*10)/60./24. + " day"+" = " + (it*10)/60. + " h"
    ;plots =  gsn_csm_contour(wks,t_ano_for(it,0:61,0:25)-t_ano_for(it-72,0:61,0:25), res)
    plots(n) =  gsn_csm_contour(wks,t_ano_for(it,0:62,0:199)-t_ano_for(it-36,0:62,0:199), res)
    n = n+1

end do
  
  ;res@cnLevelSelectionMode = "AutomaticLevels"   ; set explicit contour levels
  res@tiMainString = "time = " + (it*10)/60./24.+ " day" +" = " + (it*10)/60. + " h"
  ;plots(n) =  gsn_csm_contour(wks,t_ano(nt-1,0:41,:), res)
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@txString = "Theta Anomaly"
  gsn_panel(wks, plots(0:11), (/3,4/), gres_ta)
  gsn_panel(wks, plots(12:23), (/3,4/), gres_ta)
  gsn_panel(wks, plots(24:35), (/3,4/), gres_ta)
  gsn_panel(wks, plots(36:47), (/3,4/), gres_ta)
  gsn_panel(wks, plots(48:59), (/3,4/), gres_ta)
  ;gsn_panel(wks, plots(120:143), (/4,6/), gres_ta)
  ;gsn_panel(wks, plots(143:167), (/4,6/), gres_ta)
  ;gsn_panel(wks, plots(168:191), (/4,6/), gres_ta)
  ;gsn_panel(wks, plots(192:215), (/4,6/), gres_ta)

end












