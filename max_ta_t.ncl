load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  ;files = systemfunc("ls ./sim_lev100/angle/cirtano*")
  ;ano_h = addfiles(files, "r")
  ;ListSetType(ano_h, "cat")

  ano_h = addfile("sim_lev100/angle/d7_t0_ta.nc","r")
  t_ano = ano_h->ta
  
  smin = asciiread("sim_lev100/slp_min.txt",(1008),"float")
  vmax = asciiread("sim_lev100/wnd_max.txt",(1008),"float")
  
  ;a = addfile("sim_lev100/smooth/hourly_d7_t0_ta.nc","c")
  ;a->ta = t_ano(::6,:,:)

  ;a = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
  ;t_d01 = a->th

  ;t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    ;printVarSummary(t_ev)
    ;printVarSummary(t_ano)

  ;do lev = 0, 90
    ;do i = 0, 199
      ;do j = 0, 359

        ;t_ano(:,lev,i,j) = t_ano(:,lev,i,j)-t_ev(0,lev)
        
      ;end do 
    ;end do
  ;end do

  dimst = dimsizes(t_ano)
  print(dimst)
  printVarSummary(t_ano)

  ilat = new(dimst(0), float)
  ilon = new(dimst(0), float)
  ta_max = new((/2,dimst(0)/), float)

  ;t_ano = runave_n(t_ano, 3, 0, 1)
  ;t_ano = runave_n(t_ano, 3, 0, 2)

  ;t_ano = smth9(smth9(t_ano, 0.5, 0.25, False), 0.5, -0.25, False)

  do it = 0, dimst(0)-1, 6

    ;t_ano(it,:,:) = dim_sum_n(t_ano(it-6:it+6,:,:), 0)/3.

    dims = dimsizes(t_ano(it,0:65,0:190))
    x1d = ndtooned(t_ano(it,0:65,0:190))      ; convert 2D array to 1D for use in maxind
    
    ta_max(0,it) = min(x1d)
    ta_max(1,it) = max(x1d)
    inds = ind_resolve(minind(x1d), dims)    ; convert 1D array back to 2D 
    
    ;printVarSummary(inds)
    ilat(it) = inds(0,0)       ; select the latitude index where the X array is at its' maximum  
    ilon(it) = inds(0,1)    ; select the longitude index where the X array is at its' maximum
 
    ;print("Maximum value located at "+ ilat(it) +", "+ ilon(it) + ", " + ta_max(0,it))

  end do

  ;ta_max = runave_n(ta_max, 3, 0, 1)
  vmax = runave(vmax, 3, 0)
  smin = runave(smin, 3, 0)
  
  n = dimsizes(ta_max(0,::6))
  df = n-2
  
  aaa = fspan(1,168,n)
  bbb = fspan(2,169,n)

  corr1 = escorc(ta_max(0,::6), ta_max(1,::6))
  corr2 = escorc(ta_max(0,::6), smin(::6))
  corr3 = escorc(ta_max(1,::6), smin(::6))
  corr4 = 0.99

  print("N =" +n)
  print(corr1+","+corr2+","+corr3+","+corr4)

  t1 = corr1*sqrt((n-2)/(1-corr1^2))
  t2 = corr2*sqrt((n-2)/(1-corr2^2))
  t3 = corr3*sqrt((n-2)/(1-corr3^2))
  t4 = corr4*sqrt((n-2)/(1-corr4^2))

  p1 = rtest(corr1, n, 0)
  p2 = rtest(corr2, n, 0)
  p3 = rtest(corr3, n, 0)
  p4 = rtest(corr4, n, 0)

  print(p1)

  ;gbg = 5
  ;print(gbg^2)

  ;ta = 0.053

  ;rc=ta/sqrt(ta^2+n-2) 
  ;print(rc)

  
  print(t1+","+t2+","+t3+","+t4)
  print(p1+","+p2+","+p3+","+p4)

  time = ispan(0, dimst(0)-1, 1)*10/60.
  hei = fspan(100, 27500, 100)
  r1 = fspan(0.0,400.0,200)
  ;print(hei)
  ;print(r1)

  wks = gsn_open_wks("pdf","sim_lev100/max_tlc2")
  gsn_define_colormap(wks, "MPL_RdBu")
  gsn_reverse_colormap(wks)

  plots = new(3,graphic)

  res = True

  res@tiYAxisString =  "Radius" ; axis string
  ;res@cnFillOn = True
  ;res@cnLinesOnon = False

  ;to =  transpose(t_ano(:,0:61,1))
  ;temp = gsn_csm_contour(wks,to,res) 
  
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  gsn_define_colormap(wks, "amwg")
  gsn_reverse_colormap(wks)

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.4        ; make plot as large as possible.

  resl = res
  resr = res
  
  resl@xyMarkLineMode  = "Markers"
  resl@xyMonoMarker = True
  res@xyMonoMarkerColor = True
  resl@xyMarker         =  1                     ; choose type of marker  
  ;resl@xyMarkerColors     = (/"blue","red"/)                     ; Marker color
  resl@xyMarkerSizeF     = 0.025                ; Marker size (default 0.01)

  resl@tiYAxisString =  " Temperature Anomaly (K)" ; axis string
  
  resr@tiYAxisString =  " SLP (hPa)"
  resr@xyMarkLineMode = "Solid"
  resr@xyLineThicknessF = 2.5

  ;resl@trYAxisType    = "IrregularAxis"
  ;resl@trYCoordPoints = (/-7,-6,-5,-4,-3,-2,-1,0,5,10,15,20/)
  resl@xyMarkerColor  =  "blue"
  plots(0) = gsn_csm_xy2(wks, time(180:1007), ta_max(0,180:1007), smin(180:1007),resl,resr)
  resl@xyMarkerColor  =  "red"
  plots(1) = gsn_csm_xy2(wks, time(180:1007), ta_max(1,180:1007), vmax(180:1007),resl,resr)

  ;delete(resl@trYAxisType)
  ;delete(resl@trYCoordPoints)

    resh = resl

    resh@gsnXRefLine  = time(282); four X reference lines 
    resh@gsnXRefLineThicknessF = 2.3 

    resh@tmXTOn = False

    resh@tmYLMode    = "Explicit"
    resh@tmYLValues  = (/0, 17,35,53,61/)
    resh@tmYLLabels  = (/0.5,5,10,15,17/)

    ;resh@tmYLMode    = "Explicit"
    ;resh@tmYLValues  = (/0, 17,36,46,53,60/)
    ;resh@tmYLLabels  = (/0.5,5,10,13,15,17/)

    resh@xyMarkerColors     = (/12,15/)                     ; Marker color

    resh@tiYAxisString =  " Height (Km)" ; axis string

    resh@trYMinF          = 0.         ; Set min/max of left Y axis
    resh@trYMaxF          = 65.

  ;plots(1) = gsn_csm_xy(wks, time(180:1007),ilat(180:1007), resh)

   resrr = resl
  
    ;resr@tmYLMode    = "Explicit"
   ;resr@tmYLValues  = (/0,40,80, 120,160,199/)
   ;resr@tmYLLabels  = (/0,80,160,240,320,400/)

   resrr@trYMinF          = 0.         ; Set min/max of left Y axis
   resrr@trYMaxF          = 400.

   ;resrr@xyMarkerColor     = 15
   resrr@xyMarkerColors     = (/15,12/)                     ; Marker color
   resh@tiXAxisString =  "Time (h)" ; axis string

   resrr@tiYAxisString =  " Radius (Km)" ; axis string
  
  plots(2) = gsn_csm_xy2(wks, time(180:1007),ilat(180:1007),ilon(180:1007)*2,resh,resrr)

  gres = True
  ;gres@txString = "time = " + time +"h - "+ (time+2) + "h"
  gsn_panel(wks, plots, (/3,1/), gres)

end
