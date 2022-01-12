load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ;a = addfile("","r")
  ;f = addfile ("", "r")

  smin = asciiread("sim9_v3/slp_min.txt",(1200),"float")
  vmax = asciiread("sim9_v3/wnd_max.txt",(1200),"float")
    
  
  files = systemfunc("ls ./sim9_v3/tha/tano_d*")
  ano_h = addfiles(files, "r")
  ListSetType(ano_h, "cat")
  
  t_ano = ano_h[:]->ta

  printVarSummary(t_ano)
  printVarSummary(smin)
  printVarSummary(vmax)

  dims = dimsizes(smin)

  t_temp1 = dim_avg_n(t_ano(:,:,1:18), 2)
  t_temp2 = dim_avg_n(t_ano(:,:,18:60), 2)
  t_temp3 = dim_avg_n(t_ano(:,:,1:60), 2)


  time = ispan(0, 1199, 1)*6./60.

  t_index = new((/10,dims/),float)

  t_index(0,:) = dim_avg_n(t_temp1(:,31:33),1) ;;;;;;;;; 13 - 13.7 km
  t_index(1,:) = dim_avg_n(t_temp1(:,34:36),1) ;;;;;;;;; 13.7 - 14.6 km
  t_index(2,:) = dim_avg_n(t_temp1(:,37:39),1) ;;;;;;;;; 14.6 - 15.4 km

  t_index(3,:) = dim_avg_n(t_temp2(:,31:33),1) ;;;;;;;;; 13 - 13.7 km
  t_index(4,:) = dim_avg_n(t_temp2(:,34:36),1) ;;;;;;;;; 13.7 - 14.6 km
  t_index(5,:) = dim_avg_n(t_temp2(:,37:39),1) ;;;;;;;;; 14.6 - 15.4 km

  t_index(6,:) = dim_avg_n(t_temp3(:,31:39),1) ;;;;;;;;; 15 - 16.2 km
  t_index(7,:) = dim_avg_n(t_temp1(:,22:30),1)

  ;t_index(7,:) = t_index(0,:) + t_index(1,:)+ t_index(2,:)+ t_index(3,:) + t_index(4,:) + t_index(5,:)
  
  t_index(8,:) = smin
  t_index(9,:) = vmax
  
  hei = fspan(500, 27500, 68)
  r1 = fspan(0.0,700.0,150)
  print(hei)
  print(r1)

  wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9_v3/corr-test") 
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

  resL@xyLineThicknesses      = 2.5 
  resL@xyLineColors       = (/3,9,15/) ; colors chosen
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
  resL@xyExplicitLegendLabels = (/" 13 - 14 km"," 14 - 15.2 km"," 15.2 - 16.2 km"/)         ; create explicit labels

  resL@gsnXRefLine = 26.1; four X reference lines 
  resL@gsnXRefLineThicknessF = 1.2 
  resL@xyLineThicknessF = 2.5

  resL@trYMinF          = -5           ; Set min/max of left Y axis
  resL@trYMaxF          = 9.5


  ;resL@tiYAxisString =  "Sea Level Pressure (Pa)"
  

; resources for "right" variable
                      
  resR@xyLineThicknesses      = 2.0                   ; thicker line
  resR@xyLineColor      = "black"
  ;resR@tiYAxisString = "Max Wind Speed (m/s)" ; axis string

  plots = new(4,graphic)
  
  resL@tiMainString =  "Radius = 0 - 90 km"
  resL@tiMainFontHeightF = 0.022

  resL@xyLineColors       = (/7,8,9/)
  plots(0) = gsn_csm_xy2(wks,time,t_index(0:2,:),t_index(8,:),resL,resR)

  resL@tiMainString =  "Radius = 90 - 280 km"
  resL@xyLineColors       = (/11,12,13/)
  plots(1) = gsn_csm_xy2(wks,time,t_index(3:5,:),t_index(8,:),resL,resR)

  resL@tiMainString =  "Radius = 0 - 280 km height = 13 - 16 km"
  resL@pmLegendDisplayMode    = "NoCreate"            ; turn on legend
  resL@xyLineColors       = (/4,15,1/) ; colors chosen
  resL@tiXAxisString =  "Time (h)" ; axis string
  plots(3) = gsn_csm_xy2(wks,time,t_index(6,:),t_index(8,:),resL,resR)

  resL@tiMainString =  "Radius = 0 - 90 km height = 9 - 12 km"
  resL@xyLineColors       = (/15,4,1/) ; colors chosen
  resL@tiXAxisString =  "Time (h)" ; axis string
  plots(2) = gsn_csm_xy2(wks,time,t_index(7,:),t_index(8,:),resL,resR)

  gres = True
  ;gres@txString = "time = " + time +"h - "+ (time+2) + "h"
  gsn_panel(wks, plots, (/2,2/), gres)


  ;res@gsnXRefLine    = m(262)     ; four X reference lines 
  ;res@gsnXRefLineThicknesses = 4.   
  ;res@gsnXRefLineColors = "blue"


  end