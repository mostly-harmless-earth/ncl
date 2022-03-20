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
  ta_max = new(dimst(0), float)

 ;t_ano = runave_n(t_ano, 3, 0, 1)
  ;t_ano = runave_n(t_ano, 3, 0, 2)

  ;t_ano = smth9(smth9(t_ano, 0.5, 0.25, False), 0.5, -0.25, False)


  do it = 180, dimst(0)-7, 6

    ;t_ano(it,:,:) = dim_sum_n(t_ano(it-6:it+6,:,:), 0)/3.

    dims = dimsizes(t_ano(it,1:65,1:190))
    x1d = ndtooned(t_ano(it,1:65,1:190))      ; convert 2D array to 1D for use in maxind
    
    ta_max(it) = min(x1d)
    inds = ind_resolve(minind(x1d), dims)    ; convert 1D array back to 2D 
    
    ;printVarSummary(inds)
    ilat(it) = inds(0,0)       ; select the latitude index where the X array is at its' maximum  
    ilon(it) = inds(0,1)    ; select the longitude index where the X array is at its' maximum
 
    ;print("Maximum value located at "+ ilat(it) +", "+ ilon(it) + ", " + ta_max(it))

  end do

  time = ispan(0, dimst(0)-1, 1)*10/60.
  hei = fspan(100, 27500, 100)
  r1 = fspan(0.0,400.0,200)
  ;print(hei)
  ;print(r1)

  wks = gsn_open_wks("pdf","sim_lev100/max_tlc")
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
  res@vpHeightF        = 0.35            ; make plot as large as possible.

  res@xyMonoMarker = True
  res@xyMarkLineMode  = "Markers"
  res@xyMarker         =  16                     ; choose type of marker  
  res@xyMarkerColor     = 11                     ; Marker color
  res@xyMarkerSizeF     = 0.0065                 ; Marker size (default 0.01)

  res@tiYAxisString =  " Temperature Anomaly (K)" ; axis string

  plots(0) = gsn_csm_xy(wks, time(180:1007), ta_max(180:1007), res)

    resh = res

    ;resh@tmYLMode    = "Explicit"
    ;resh@tmYLValues  = (/0, 17,35,53,61/)
    ;resh@tmYLLabels  = (/0.5,5,10,15,17/)

    resh@tmYLMode    = "Explicit"
    resh@tmYLValues  = (/0, 17,36,46,53,60/)
    resh@tmYLLabels  = (/0.5,5,10,13,15,17/)
    resh@xyMarkerColor     = 12                    ; Marker color

    resh@tiYAxisString =  " Height (Km)" ; axis string

    resh@trYMinF          = 36.         ; Set min/max of left Y axis
    resh@trYMaxF          = 65.

  plots(1) = gsn_csm_xy(wks, time(180:1007),ilat(180:1007), resh)

   resr = res
  
   resr@tmYLMode    = "Explicit"
   resr@tmYLValues  = (/0,40, 80, 120,160,199/)
   resr@tmYLLabels  = (/0,80, 160,240,320,400/)
   resr@xyMarkerColor     = 15                    ; Marker color
   resr@tiXAxisString =  "Time (h)" ; axis string

   resr@tiYAxisString =  " Radius (Km)" ; axis string
  
  plots(2) = gsn_csm_xy(wks, time(180:1007),ilon(180:1007), resr)

  gres = True
  ;gres@txString = "time = " + time +"h - "+ (time+2) + "h"
  gsn_panel(wks, plots, (/3,1/), gres)

end
