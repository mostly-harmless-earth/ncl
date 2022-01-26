load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  

  ano_h = addfile("sim_lev100/envi_base0312.nc","r")
  t_avg = ano_h->te

  dimst = dimsizes(t_avg)
  print(dimst)
  
  time = ispan(0, dimst(0)-1, 1)*6/60.
  hei = fspan(500, 27500, 100)/1000
  
  wks = gsn_open_wks("pdf","sim_lev100/enviorment")
  gsn_define_colormap(wks, "MPL_RdBu")
  gsn_reverse_colormap(wks)

  res = True
  res@cnFillOn = True
  res@cnLinesOn = False
  ;res@vpWidthF         = 0.35            ; Change the aspect ratio, but 
  ;res@vpHeightF        = 0.7            ; make plot as large as possible.

  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = (/0, 40, 80, 120,160,199/)
  ;res@tmXBLabels  = (/0, 80, 160,240,320,400/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = (/0, 17,35,53,61/)
  res@tmYLLabels  = (/0.5,5,10,15,17/)


  do it = 0, dimst(0)-1,6

    res@tiMainString = "time = "+time(it) +"h"
    res@tiXAxisString = "height (Km)"
    res@tiYAxisString = "potential temperature (K)"

    ;plot = gsn_csm_xy(wks,hei,t_avg(it,:), res)
    plot = gsn_csm_contour(wks,t_avg(it,0:62,:), res)

  end do

end

   
