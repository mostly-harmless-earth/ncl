load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  files = systemfunc("ls ./sim9_v3/tha/tano_*")
  ano_h = addfiles(files, "r")
  ListSetType(ano_h, "cat")

  ;ano_h = addfile("sim9_wrfv3/tano_d1_00.nc","r")
  t_ano = ano_h[:]->ta

  dimst = dimsizes(t_ano)
  print(dimst)
  printVarSummary(t_ano)

  ilat = new(dimst(0), float)
  ilon = new(dimst(0), float)
  ta_max = new(dimst(0), float)

  ;t_ano = runave_n(t_ano, 3, 0, 1)
  ;t_ano = runave_n(t_ano, 3, 0, 2)

  do it = 0, dimst(0)-1,5

    dims = dimsizes(t_ano(it,1:46,1:107))
    x1d = ndtooned(t_ano(it,1:46,1:107))      ; convert 2D array to 1D for use in maxind
    
    ta_max(it) = min(x1d)
    inds = ind_resolve(minind(x1d), dims)    ; convert 1D array back to 2D 
    
    ;printVarSummary(inds)
    ilat(it) = inds(0,0)       ; select the latitude index where the X array is at its' maximum  
    ilon(it) = inds(0,1)    ; select the longitude index where the X array is at its' maximum
 
    ;print("Maximum value located at "+ ilat(it) +", "+ ilon(it) + ", " + ta_max(it))

  end do

  time = ispan(0, dimst(0)-1, 1)*6/60.
  hei = fspan(500, 27500, 68)
  r1 = fspan(0.0,700.0,150)
  print(hei)
  print(r1)

  wks = gsn_open_wks("pdf","sim9_v3/max_tlc")
  gsn_define_colormap(wks, "MPL_RdBu")
  gsn_reverse_colormap(wks)

  plots = new(3,graphic)

  res = True

  res@tiXAxisString =  "Time (h)" ; axis string
  res@tiYAxisString =  "Radius" ; axis string
  res@cnFillOn = True
  res@cnLinesOnon = False

  to =  transpose(t_ano(:,0:46,1))
  temp = gsn_csm_contour(wks,to,res) 
  
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  gsn_define_colormap(wks, "amwg")
  gsn_reverse_colormap(wks)

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.35            ; make plot as large as possible.
  
  res@xyMonoMarker = True
  res@xyMarkLineMode  = "Markers"
  res@xyMarker         =  16                     ; choose type of marker  
  res@xyMarkerColor     = 11                     ; Marker color
  res@xyMarkerSizeF     = 0.0065                 ; Marker size (default 0.01)

  res@tiYAxisString =  " Temperature Anomaly (K)" ; axis string

  plots(0) = gsn_csm_xy(wks, time, ta_max, res)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/11,24,31,36,40,45/)
  res@tmYLLabels  = (/5,10,13,15,17,19/)
  res@xyMarkerColor     = 12                    ; Marker color

  res@tiYAxisString =  " Height (Km)" ; axis string

  plots(1) = gsn_csm_xy(wks, time ,ilat, res)
  
  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0, 22, 43, 64, 85,107/)
  res@tmYLLabels  = (/0,100,200,300,400,500/) 
  res@xyMarkerColor     = 15                    ; Marker color

  res@tiYAxisString =  " Radius (Km)" ; axis string
  
  plots(2) = gsn_csm_xy(wks, time,ilon, res)

  gres = True
  ;gres@txString = "time = " + time +"h - "+ (time+2) + "h"
  gsn_panel(wks, plots, (/3,1/), gres)

end
