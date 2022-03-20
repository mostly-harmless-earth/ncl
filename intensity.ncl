load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ;a = addfile("","r")
  ;f = addfile ("", "r")

  smin = asciiread("sim_lev100/slp_min.txt",(1008),"float")
  vmax = asciiread("sim_lev100/wnd_max.txt",(1008),"float")
    
  dims = dimsizes(smin)
  print(dims)
  m = ispan(0,dims-1,1)*10/60.
  m1 = ispan(0,dims-7,1)
  v_change_12h = new(dims, "float")

do i = 0, dims-73
  v_change_12h(i) = vmax(i+72)-vmax(i)
  if (v_change_12h(i).ge.7.6) then
    print("time = " + m(i) )
    print("tt = " + i )
  end if
end do

  ano_h = addfile("sim_lev100/angle/d7_t0_ta.nc","r")
  t_ano = ano_h->ta

  dimst = dimsizes(t_ano)
  print(dimst)
  printVarSummary(t_ano)

  ta_max = new(dimst(0), float)

  t_ano = smth9(smth9(t_ano, 0.5, -0.25, False), 0.5, -0.25, False)

  do it = 0, dimst(0)-1, 6

    x1d = ndtooned(t_ano(it,36:65,1:180))      ; convert 2D array to 1D for use in maxind
    ta_max(it) = min(x1d)

  end do

  hei = fspan(100, 27500, 100)
  r1 = fspan(0.0,400.0,200)
 
  ;v_change_1h = runave(v_change_1h, 3, 0)
  ;t_c = (/540,640,780,920,1020,1660,1320,1560,2300/)
  ;slp_cho = new(9, float)

  ;do itt = 0, 8
   ; tmid = t_c(itt)
   ; slp_cho(itt) = slp(tmid,120,120)
  ;end do
  ;print(slp_cho)

; Graphics section
  ;printVarSummary(slp)

  wks=gsn_open_wks("pdf","sim_lev100/slp-V10-tamax") 
  gsn_define_colormap(wks,"MPL_BuGn")  ; Change color map.

  plots = new(2,graphic)
  res                     = True
  gres                    = True
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame
  ;res@cnFillOn            = True
  ;res@cnLinesOn           = False
  ;res@cnLineLabelsOn      = False
  ;res@cnLineThicknesses   = 1.5

  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = (/0,600,1200,1800,2400,2880/)
  ;res@tmXBLabels   =(/0, 30,  60,  90, 120, 144/)
  
; resources for "left" variable


  resL                        = True 
  resR                        = True  

  resL@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  resL@vpHeightF        = 0.35            ; make plot as large as possible.
  
  resL@xyLineThicknesses      = 3 
  resL@xyLineColor      = "Blue3"

  resL@gsnXRefLine  = m(282); four X reference lines 
  resL@gsnXRefLineThicknessF = 2.8   
  ;resL@gsnXRefLineColor = "blue"

  resL@tiYAxisString =  "Sea Level Pressure (Pa)"

; resources for "right" variable
                      
  resR@xyLineThicknesses      = 3                   ; thicker line
  resR@xyLineColor      = "Brown3"
  resR@tiYAxisString = "Max Wind Speed (m/s)" ; axis string

  resL@tmXBOn = False
  resL@tmXTOn = False

  plots(0) = gsn_csm_xy2(wks,m,smin,vmax,resL,resR)

  res = True

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.35            ; make plot as large as possible.
  
  res@tiYAxisString =  "Radius" ; axis string
  res@cnFillOn = True
  res@cnLinesOnon = False

  res@gsnDraw            = True                   ; don't draw
  res@gsnFrame           = True                   ; don't advance frame

  gsn_define_colormap(wks, "amwg")
  
  res@xyMonoMarker = True
  res@xyMarkLineMode  = "Markers"
  res@xyMarker         =  16                     ; choose type of marker  
  res@xyMarkerColor     = 7                     ; Marker color
  res@xyMarkerSizeF     = 0.0065                 ; Marker size (default 0.01)

  ;res@xyLineThicknesses      = 3                   ; thicker line
  ;res@xyLineColor      = 11
  res@tmXTOn = False
  res@tiYAxisString =  " Temperature Anomaly (K)" ; axis string
  res@tiXAxisString =  "Time (h)" ; axis string

  plots(1) = gsn_csm_xy(wks, m(::6), ta_max(::6), res)

  ;overlay(plot, tamax)
  ;draw(plot)

  ;plots(0) = gsn_csm_xy(wks,m,smin,res)
  ;plots(1) = gsn_csm_xy(wks,m,vmax,res)

  ;gres@gsMarkerIndex = 0
  ;gres@gsMarkerSizeF = 0.015
  ;gres@gsMarkerColor = "navy"                 ; color chosen
  ;gres@gsMarkerThicknessF = 3
  
  gres = True
  
  ;plot3 = gsn_add_polymarker( wks,plot(1), t_c, slp_cho, gres)
  
  ;gres@gsnCenterString = "Sea Level Pressure(Pa) ~C~ Max Wind Speed(m/s)" 
  gsn_panel(wks, plots, (/2,1/), gres)

  cres = res
  cres@gsnDraw            = True                   ; don't draw
  cres@gsnFrame           = True                   ; don't advance frame
  ;plot_change = gsn_csm_xy(wks,m1,v_change_1h,cres)


end