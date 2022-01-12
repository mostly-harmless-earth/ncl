load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ;a = addfile("","r")
  ;f = addfile ("", "r")

  smin = asciiread("sim_lev90/slp_min90.txt",(61),"float")
  vmax = asciiread("sim_lev90/wnd_max90.txt",(61),"float")
    
  dims = dimsizes(smin)
  print(dims)
  m = ispan(0,dims-1,1)*2
  m1 = ispan(0,dims-7,1)*2
  v_change_1h = new(dims-6, "float")

  ;print(m)

;do i = 0, dims-7
  ;v_change_1h(i) = vmax(i+6)-vmax(i)
  ;if (v_change_1h(i).ge.3.8175) then
    ;print("time = " + i*2 )
    ;print("tt = " + i )
  ;end if
;end do
  
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

  wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/slp-V10-90s") 
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

  resL@xyLineThicknesses      = 2.5 
  resL@xyLineColor      = "Blue3"

  resL@gsnXRefLine    = (/m(11),m(30)/); four X reference lines 
  resL@gsnXRefLineThicknessF = 3.   
  ;resL@gsnXRefLineColor = "blue"

  resL@tiYAxisString =  "Sea Level Pressure (Pa)"
  resL@tiXAxisString =  "Time (h)" ; axis string

; resources for "right" variable
                      
  resR@xyLineThicknesses      = 2.5                   ; thicker line
  resR@xyLineColor      = "Brown3"
  resR@tiYAxisString = "Max Wind Speed (m/s)" ; axis string

  plot = gsn_csm_xy2(wks,m,smin,vmax,resL,resR)

  res@gsnXRefLine    = m(11)     ; four X reference lines 
  ;res@gsnXRefLineThicknesses = 4.   
  ;res@gsnXRefLineColors = "blue"

  
  plots(0) = gsn_csm_xy(wks,m,smin,res)
  plots(1) = gsn_csm_xy(wks,m,vmax,res)

  gres@gsMarkerIndex = 0
  gres@gsMarkerSizeF = 0.015
  gres@gsMarkerColor = "navy"                 ; color chosen
  gres@gsMarkerThicknessF = 3
  
  gres = True
  
  ;plot3 = gsn_add_polymarker( wks,plot(1), t_c, slp_cho, gres)
  
  gres@gsnCenterString = "Sea Level Pressure(Pa) ~C~ Max Wind Speed(m/s)" 
  gsn_panel(wks, plots, (/1,2/), gres)

  cres = res
  cres@gsnDraw            = True                   ; don't draw
  cres@gsnFrame           = True                   ; don't advance frame
  ;plot_change = gsn_csm_xy(wks,m1,v_change_1h,cres)


end