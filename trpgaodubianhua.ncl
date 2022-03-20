load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.


  ;a = addfile("/user_home/jyyin/dta/sim_lev100/tk/hgtoflapsrate_avg.nc","r")
  a = addfile("/user_home/jyyin/dta/sim_lev100/tk/hgtofcpot.nc","r")
  alti = a->alti(::6,:)

  dims = dimsizes(alti)
  print(dims)

  wks = gsn_open_wks("pdf","sim_lev100/coldp-height-time")
  gsn_define_colormap(wks, "MPL_RdBu")
  ;gsn_reverse_colormap(wks)

  res = True
  res@cnFillOn = True
  res@cnLinesOn = False

  res@gsnFrame = False
  res@gsnDraw  = False

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.4            ; make plot as large as possible.

  res@cnInfoLabelOn = False

  ;res@tiYAxisString           = "height(km)"
  ;res@tiXAxisString           = "Radius (km)"
  res@tiYAxisFontHeightF      = 0.02
  res@tiXAxisFontHeightF      = 0.02
  res@tmXBLabelFontHeightF    = 0.015
  res@tmYLLabelFontHeightF    = 0.015
  res@tmYRLabelFontHeightF    = 0.015
  res@gsnStringFontHeightF    = 0.015
  
  res@cnLineThicknessF  = 1.5
  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False

  ; create explicit labels

  acp = new((/3,dims(0)/), float)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Time loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  acp(0,:) = dim_avg_n(alti(:,2:15), 1)
  acp(1,:) = dim_avg_n(alti(:,15:30), 1)
  acp(2,:) = dim_avg_n(alti(:,30:60), 1)

  acp = runave_n(acp,3,1,1)
  acp = runave_n(acp,3,1,1)
;--------------------------------------------------------------------------------
;---------------------- cold point tropopause -----------------------------------

  res_al = True

  res_al@gsnFrame = True
  res_al@gsnDraw  = True

  nr = 200
  r = fspan(0.0,400.0,nr)
  print(r)
  yyl = ispan(0,100,1)
  hei = fspan(500, 27500, 100)/1000
  print(hei)
  
  res_al@tmYLMode = "Explicit"
  res_al@tmYLValues  = yyl(50:80)
  res_al@tmYLLabels  = hei(50:80)

  ;res_al@xyDashPatterns   = 0.      ; make all lines solid

  res_al@xyLineColors = (/"green","purple","red"/)
  res_al@xyLineThicknessF = 2.3

  res_al@pmLegendDisplayMode    = "Always"            ; turn on legend
  res_al@pmLegendSide           = "Top"               ; Change location of 
  ;res_al@pmLegendParallelPosF   = -.0001                  ; move units right
  res_al@pmLegendOrthogonalPosF = -0.4               ; move units down
  res_al@pmLegendWidthF         = 0.15                ; Change width and
  res_al@pmLegendHeightF        = 0.15                ; height of legend.
  res_al@lgPerimOn              = False               ; turn off box around
  res_al@lgLabelFontHeightF     = .01                 ; label font height
  res_al@xyExplicitLegendLabels = (/" 0-30 km"," 30-60 km"," 60-120 km"/)       

  res_al@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res_al@vpHeightF        = 0.4            ; make plot as large as possible.

  al = gsn_csm_y(wks,acp,res_al)

  ;--------------------------------------------------------------------------------

  gsn_define_colormap(wks,"MPL_autumn")

  colorr = ispan(0, 254, 1)
  ares = True
  ares@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  ares@vpHeightF        = 0.4            ; make plot as large as possible.

  ares@xyLineThicknessF = 2.0
  ares@xyLineColors     = colorr(::20); colors chosen
  ares@xyDashPatterns   = 0.      ; make all lines solid

  ;ares@trYMinF          = 52.           ; Set min/max of left Y axis
  ;ares@trYMaxF          = 66.

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 7, 14,21,28/)
  ;ares@tmYLLabels  = (/10,12,14,16,18/)

  cp = alti
  cp = runave_n(cp, 3, 0, 1)
  ;pk = new(100,graphic)

  do it = 0, dims(0)-73,72

    cp(it,:) = dim_sum_n(alti(it:it+72,:), 0)/12.
    
  end do

;pk = gsn_csm_y(wks,cp(::72,:),ares)


end