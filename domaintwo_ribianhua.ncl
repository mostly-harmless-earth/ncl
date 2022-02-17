load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    a = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    t_d01 = a->th

    printVarSummary(t_d01)

    files = systemfunc("ls ./sim_lev100/d02/afor_d02_t*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    
    t_ano_for = ano_h[:]->ta

    printVarSummary(t_ano_for)
    
    nr = 120  ;;; 100 * 18 = 1800 Km
    nz = 100   ; Sigma levels
    r = fspan(0.0, 720.0,nr)
    print(r)
    r@units = "km"

    t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    printVarSummary(t_ev)

    do lev = 0, 90
      do i = 0, 119

        t_ano_for(:,lev,i) = t_ano_for(:,lev,i)-t_ev(0,lev)
   
      end do
    end do

    dim = dimsizes(t_ano_for)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    dt = 12 

    nt = dim(0)/dt
    print(dim(0))
    print(nt)
    plots = new(nt,graphic)
    n = 0 

    hei = fspan(500, 27500, 100)
    print(hei)

outfilet = addfile("sim_lev100/d02/rela_d02_t0_tano.nc","c")
outfilet->ta = t_ano_for
 
    ;nr = 120  ;;; 120 * 6 = 720 Km
    ;nz = 100   ; Sigma levels
    ;r = fspan(0.0, 720.0,nr)
    ;r@units = "km"
    
    ;hei = fspan(500, 27500, 100)/1000

    wks=gsn_open_wks("pdf","sim_lev100/d02-ta-day") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

do it = 216, dim(0)-1, 144

  t_day = dim_sum_n(t_ano_for(it-36:it,:,:), 0)/6

  res                     = True

  gres                    = True
  
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame
  res@cnFillOn           = True
  res@cnLinesOn          = False
  res@cnLineLabelsOn     = False
  res@cnInfoLabelOn      = False

  res@vpWidthF         = 0.9            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.2            ; make plot as large as possible.
  
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

    res@tmXBMode    = "Explicit"
    res@tmXBValues  = (/0, 20,  40, 60,80,100,119/)
    res@tmXBLabels  = (/0, 120,240,320,480,600,720/)

    res@tmYLMode    = "Explicit"
    res@tmYLValues  = (/0, 7, 14,21,28/)
    res@tmYLLabels  = (/12,14,16,18,20/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 17,35,53,61/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@tmXMajorGrid          = True               ; Add white grid lines
    ;res@tmXMajorGridLineColor = "gray"
    ;res@tmYMajorGrid          = True
    ;res@tmYMajorGridLineColor = "gray"

    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    ;if (it.le.164) then
        ;res@cnLevelSpacingF = 0.5
        ;res@cnMinLevelValF  = -4.
        ;res@cnMaxLevelValF  = 4.
      ;else if (it.le.435) then
        res@cnLevelSpacingF = 0.5
        res@cnMinLevelValF  = -5.
        res@cnMaxLevelValF  = 5.
      ;else
          ;res@cnLevelSpacingF = 1.2
          ;res@cnMinLevelValF  = -12
          ;res@cnMaxLevelValF  = 12       
      ;end if
    ;end if

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

    res@lbLabelBarOn        = False           ; turn off individual cb's
    
    time = (it*10)/60./24.
    res@tiYAxisString = "Day  " + (time-1) + " - " + time
    ;plots =  gsn_csm_contour(wks,t_ano_for(it,0:61,0:25)-t_ano_for(it-72,0:61,0:25), res)
    plots(n) =  gsn_csm_contour(wks,t_day(43:72,0:119), res)
    n = n+1

end do
  
  ;res@cnLevelSelectionMode = "AutomaticLevels"   ; set explicit contour levels
  ;res@tiYAxisString = "time = " + (it*10)/60./24.+ " day" +" = " + (it*10)/60. + " h"
  ;plots(n) =  gsn_csm_contour(wks,t_ano(nt-1,0:41,:), res)
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres@lbOrientation        = "Vertical"
  gres_ta@txString = "Theta Anomaly"
  gsn_panel(wks, plots(0:3), (/4,1/), gres_ta)
  ;gsn_panel(wks, plots(8:15), (/2,4/), gres_ta)
  ;gsn_panel(wks, plots(16:23), (/2,4/), gres_ta)
  ;gsn_panel(wks, plots(24:31), (/2,4/), gres_ta)
  ;gsn_panel(wks, plots(32:39), (/2,4/), gres_ta)
  ;gsn_panel(wks, plots(36:39), (/1,4/), gres_ta)
  ;gsn_panel(wks, plots(120:143), (/4,6/), gres_ta)
  ;gsn_panel(wks, plots(143:167), (/4,6/), gres_ta)
  ;gsn_panel(wks, plots(168:191), (/4,6/), gres_ta)
  ;gsn_panel(wks, plots(192:215), (/4,6/), gres_ta)

end












