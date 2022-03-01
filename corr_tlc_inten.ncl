load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ;a = addfile("","r")
  ;f = addfile ("", "r")

  smin = asciiread("sim_lev100/slp_min.txt",(720),"float")
  vmax = asciiread("sim_lev100/wnd_max.txt",(720),"float")
    
  
  files = systemfunc("ls ./sim_lev100/tha/d5_rela*")
  ano_h = addfiles(files, "r")
  ListSetType(ano_h, "cat")
  
  t_ano = ano_h[:]->ta

  printVarSummary(t_ano)
  printVarSummary(smin)
  printVarSummary(vmax)

  dims = dimsizes(smin)

  t_temp1 = dim_avg_n(t_ano(:,:,1:40), 2)
  t_temp2 = dim_avg_n(t_ano(:,:,40:120), 2)
  t_temp3 = dim_avg_n(t_ano(:,:,1:120), 2)


  time = ispan(0, 719, 1)*10/60.


  t_index = new((/12,dims/),float)

  t_index(0,:) = dim_avg_n(t_temp1(:,46:48),1) ;;;;;;;;; 13.5
  t_index(1,:) = dim_avg_n(t_temp1(:,49:51),1) ;;;;;;;;; 14
  t_index(2,:) = dim_avg_n(t_temp1(:,51:53),1) ;;;;;;;;; 14.5
  t_index(3,:) = dim_avg_n(t_temp1(:,53:55),1) ;;;;;;;;; 15

  t_index(4,:) = dim_avg_n(t_temp2(:,46:48),1) 
  t_index(5,:) = dim_avg_n(t_temp2(:,49:51),1) 
  t_index(6,:) = dim_avg_n(t_temp2(:,51:53),1) 
  t_index(7,:) = dim_avg_n(t_temp2(:,53:55),1) 

  t_index(8,:) = dim_avg_n(t_temp3(:,46:55),1) ;;;;;;;;; 15 - 16.2 km
  t_index(9,:) = dim_avg_n(t_temp1(:,20:30),1)

  ;t_index(7,:) = t_index(0,:) + t_index(1,:)+ t_index(2,:)+ t_index(3,:) + t_index(4,:) + t_index(5,:)
  
  t_index(10,:) = smin
  t_index(11,:) = vmax
  
  hei = fspan(500, 27500, 100)
  r1 = fspan(0.0,400.0,200)
  print(hei)
  print(r1)

  wks=gsn_open_wks("pdf","sim_lev100/corr") 
  gsn_define_colormap(wks,"amwg")  ; Change color map.

  res                     = True
  ;res@gsnMaximize         = True
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.4            ; make plot as large as possible.
  ;res@cnFillOn            = True
  ;res@cnLinesOn           = False
  ;res@cnLineLabelsOn      = False
  ;res@cnLineThicknesses   = 1.5

  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = (/0,600,1200,1800,2400,2880/)
  ;res@tmXBLabels   =(/0, 30,  60,  90, 120, 144/)
  
; resources for "left" variable
  resL                        = res
  resR                        = True  

  ;resL@xyMonoMarker = True
  ;resL@xyMarkLineMode  = "Markers"
  ;resL@xyMarker         =  16                     ; choose type of marker  
  ;resL@xyMarkerColors     = (/3,9,15/)                     ; Marker color
  ;resL@xyMarkerSizeF     = 0.005                 ; Marker size (default 0.01)

  ;esL@xyLineThicknesses      = 2.5 
  ;resL@xyLineColors       = (/3,9,15/) ; colors chosen
  resL@xyDashPatterns   = 0.      ; make all lines solid
  
  resL@gsnYRefLine    = 0. ; four X reference lines 
  resL@gsnYRefLineThicknessF = 1.2   
  ;resL@gsnXRefLineColor = "blue"

  resL@pmLegendDisplayMode    = "Always"            ; turn on legend
  resL@pmLegendSide           = "Bottom"               ; Change location of 
  ;resL@pmLegendParallelPosF   = .80                  ; move units right
  ;resL@pmLegendOrthogonalPosF = 0.08               ; move units down
  resL@pmLegendWidthF         = 0.12                ; Change width and
  resL@pmLegendHeightF        = 0.12                ; height of legend.
  resL@lgPerimOn              = False               ; turn off box around
  resL@lgLabelFontHeightF     = .018                 ; label font height
  resL@xyExplicitLegendLabels = (/" 13.5 km"," 14 km"," 14.5 km"," 15 km"/)         ; create explicit labels

  resL@gsnXRefLine = time(164); four X reference lines 
  resL@gsnXRefLineThicknessF = 1.2 
  resL@xyLineThicknessF = 1.8

  resL@trYMinF          = -5           ; Set min/max of left Y axis
  resL@trYMaxF          = 9.5


  ;resL@tiYAxisString =  "Sea Level Pressure (Pa)"
  

; resources for "right" variable
                      
  resR@xyLineThicknesses      = 1.5                   ; thicker line
  resR@xyLineColor      = "black"
  ;resR@tiYAxisString = "Max Wind Speed (m/s)" ; axis string

  plots = new(4,graphic)
  
  resL@tiMainString =  "Radius = 0 - 80 km"
  resL@tiMainFontHeightF = 0.022

  resL@xyLineColors      = (/2,7,8,9/)
  plots(0) = gsn_csm_xy2(wks,time(::6),t_index(0:3,::6),t_index(10,::6),resL,resR)

  resL@tiMainString =  "Radius = 80 - 240 km"
  resL@xyLineColors      = (/11,12,13,14/)
  plots(1) = gsn_csm_xy2(wks,time(::6),t_index(4:7,::6),t_index(10,::6),resL,resR)

  resL@tiMainString =  "Radius = 0 - 240 km height = 13 - 15.5 km"
  resL@pmLegendDisplayMode    = "NoCreate"            ; turn on legend
  resL@xyLineColors       = (/4,15,1,2/) ; colors chosen
  resL@tiXAxisString =  "Time (h)" ; axis string
  plots(3) = gsn_csm_xy2(wks,time(::6),t_index(8,::6),t_index(10,::6),resL,resR)

  resL@tiMainString =  "Radius = 0 - 80 km height = 5 - 10 km"
  resL@xyLineColors       = (/15,4,1,2/) ; colors chosen
  resL@tiXAxisString =  "Time (h)" ; axis string
  plots(2) = gsn_csm_xy2(wks,time(::6),t_index(9,::6),t_index(10,::6),resL,resR)

  gres = True
  ;gres@txString = "time = " + time +"h - "+ (time+2) + "h"
  gsn_panel(wks, plots, (/2,2/), gres)


  ;res@gsnXRefLine    = m(262)     ; four X reference lines 
  ;res@gsnXRefLineThicknesses = 4.   
  ;res@gsnXRefLineColors = "blue"


  end