load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  ;files = systemfunc("ls ./sim_lev100/angle/cirtano*")
  ;ano_h = addfiles(files, "r")
  ;ListSetType(ano_h, "cat")

  ;ano_h = addfile("sim_lev100/angle/d7_t0_ta.nc","r")
  ;t_ano = ano_h->ta

  ;a = addfile("/user_home/jyyin/dta/sim_lev100/angle/vt_azi.nc.nc","r")
  ;vt = a->wtan

  ;b = addfile("/user_home/jyyin/dta/sim_lev100/angle/vr_azi.nc.nc","r")
  ;vr = b->wrad

  files = systemfunc("ls ./sim_lev100/wind10/wnd*")
  aw = addfiles(files, "r")
  ListSetType(aw, "cat")

  vv = aw[:]->wnd

  dimst = dimsizes(vv)
  print(dimst)
  printVarSummary(vv)

  ilat = new(dimst(0), float)
  ilon = new(dimst(0), float)
  rr = new(dimst(0), float)
  vv_max = new(dimst(0), float)

  vv = runave_n(vv,3, 0, 0)
  
  do it = 0, dimst(0)-1, 6

    dims = dimsizes(vv(it,150:270,150:270))
    x1d = ndtooned(vv(it,150:270,150:270))      ; convert 2D array to 1D for use in maxind
    
    vv_max(it) = max(x1d)
    inds = ind_resolve(maxind(x1d), dims)    ; convert 1D array back to 2D 
    
    ;printVarSummary(inds)
    ilat(it) = inds(0,0)+150       ; select the latitude index where the X array is at its' maximum  
    ilon(it) = inds(0,1)+150   ; select the longitude index where the X array is at its' maximum

    rr(it) = sqrt((ilat(it)-210)^2+(ilon(it)-210)^2)*2
    print("Maximum value located at "+ ilat(it) +", "+ ilon(it) + ", " + vv_max(it)+ ", " + it*10/60.)
    print("RMW = "+rr(it))

  end do

  time = ispan(0, dimst(0)-1, 1)*10/60.
  hei = fspan(100, 27500, 100)
  r1 = fspan(0.0,400.0,200)
  ;print(hei)
  ;print(r1)

  wks = gsn_open_wks("pdf","sim_lev100/rmw")
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
  res@vpHeightF        = 0.45        ; make plot as large as possible.

  res@xyMonoMarker = True
  res@xyMarkLineMode  = "Markers"
  res@xyMarker         =  1                     ; choose type of marker  
  res@xyMarkerColor     = 11                     ; Marker color
  res@xyMarkerSizeF     = 0.03                ; Marker size (default 0.01)

  res@tiYAxisString =  " Temperature Anomaly (K)" ; axis string

  plots(0) = gsn_csm_xy(wks, time(180:1007), vv_max(180:1007), res)
  plots(1) = gsn_csm_xy(wks, time(180:1007), rr(180:1007), res)

    resh = res

    resh@gsnXRefLine  = time(282); four X reference lines 
    resh@gsnXRefLineThicknessF = 2.3 

    resh@tmXTOn = False

    ;resh@tmYLMode    = "Explicit"
    ;resh@tmYLValues  = (/0, 17,35,53,61/)
    ;resh@tmYLLabels  = (/0.5,5,10,15,17/)

    ;resh@tmYLMode    = "Explicit"
    ;resh@tmYLValues  = (/0, 17,36,46,53,60/)
    ;resh@tmYLLabels  = (/0.5,5,10,13,15,17/)
    resh@xyMarkerColor     = 12                    ; Marker color

    resh@tiYAxisString =  " Height (Km)" ; axis string

    ;resh@trYMinF          = 0.         ; Set min/max of left Y axis
    ;resh@trYMaxF          = 65.

  ;plots(1) = gsn_csm_xy(wks, time(180:1007),ilat(180:1007), resh)

   resr = res
  
    ;resr@tmYLMode    = "Explicit"
   ;resr@tmYLValues  = (/0,40,80, 120,160,199/)
   ;resr@tmYLLabels  = (/0,80,160,240,320,400/)

   ;resr@trYMinF          = 0.         ; Set min/max of left Y axis
   ;resr@trYMaxF          = 400.

   resr@xyMarkerColor     = 15                    ; Marker color
   resr@tiXAxisString =  "Time (h)" ; axis string

   resr@tiYAxisString =  " Radius (Km)" ; axis string
  
  plots(2) = gsn_csm_xy2(wks, time(180:1007),(ilat(180:1007)-210)*2,(ilon(180:1007)-210)*2,resh,resr)

  gres = True
  ;gres@txString = "time = " + time +"h - "+ (time+2) + "h"
  gsn_panel(wks, plots, (/3,1/), gres)

end
