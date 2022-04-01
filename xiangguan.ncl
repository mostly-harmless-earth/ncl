load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

  ;a = addfile("/user_home/jyyin/dta/sim_lev100/tk/hgtoflapsrate_avg.nc","r")
  a = addfile("/user_home/jyyin/dta/sim_lev100/tk/hgtoflapsrate_avg.nc","r")
  alti = a->alti(::6,:)

  b = addfile("/user_home/jyyin/dta/sim_lev100/tk/tk_azi.nc","r")
  tk = b->tk(::6,:,:)

  ;smin_all = asciiread("sim_lev100/slp_min.txt",(1008),"float")
  ;smin = smin_all(::6)

  printVarSummary(alti)
  printVarSummary(tk)
  ;printVarSummary(smin)
  
  dims = dimsizes(tk)
  print(dims)
  

  t_prf = new((/3,dims(0),dims(1)/), float)

  t_avg_time = dim_avg_n(tk,0)
  t_en = dim_avg_n(t_avg_time(:,100:199),1)
  t_avg = conform(tk, t_en, 1)

  tk = tk - t_avg

  t_prf(0,:,:) = dim_avg_n(tk(:,:,0:16), 2)
  t_prf(1,:,:) = dim_avg_n(tk(:,:,20:45), 2)
  t_prf(2,:,:) = dim_avg_n(tk(:,:,50:180), 2)

  t_alltime_avg = dim_avg_n(t_prf, 1)

  printVarSummary(t_prf)

  wks = gsn_open_wks("pdf","sim_lev100/pro_tk")
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
  res_al@tmYLLabels  = sprintf("%4.2f", hei(50:80)) 

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

  res_al@vpWidthF         = 0.4            ; Change the aspect ratio, but 
  res_al@vpHeightF        = 0.7            ; make plot as large as possible.
  res_al@tmYLMode = "Automatic"
  delete(res_al@pmLegendDisplayMode)  


  ;do it = 0, dims(0)-1,12
    
    pl=gsn_csm_xy(wks,t_alltime_avg,hei(0:90),res_al)

  ;end do


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



;pk = gsn_csm_y(wks,cp(::72,:),ares)


end