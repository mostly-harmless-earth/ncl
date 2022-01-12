load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  

  ano_h = addfile("sim9_v3/tha/en_po.nc","r")
  t_avg = ano_h->t_avg

  dimst = dimsizes(t_avg)
  print(dimst)
  
  time = ispan(0, dimst(0)-1, 1)*6/60.
  hei = fspan(500, 27500, 68)/1000
  
  wks = gsn_open_wks("pdf","sim9_v3/enviorment")
  gsn_define_colormap(wks, "MPL_RdBu")
  gsn_reverse_colormap(wks)

  res = True
  res@vpWidthF         = 0.35            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.7            ; make plot as large as possible.

  do it = 0, dimst(0)-1,5



    res@tiMainString = "time = "+time(it) +"h"

    plot = gsn_csm_xy(wks,hei,t_avg(it,:), res)

  end do

end

   
