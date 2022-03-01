load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


;;;;;;;;;;;;;;; read files ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nn = (/1,2,3,4,5/)
in = 1


  t_k = new(100,graphic)
  win = new(100,graphic)

  n = 0 


  wks = gsn_open_wks("pdf","sim_lev100/angle_height_5d")
  gsn_define_colormap(wks, "MPL_RdBu")
  ;gsn_reverse_colormap(wks)


do in = 0, 4

   files = systemfunc("ls ./sim_lev100/angle/radial_wind"+nn(in)+"*")
   a = addfiles(files, "r")
   ListSetType(a, "cat")
   
   radial = a[:]->wrad

   files = systemfunc("ls ./sim_lev100/angle/tangential_wind"+nn(in)+"*")
   b = addfiles(files, "r")
   ListSetType(b, "cat")
   
   tangential = b[:]->wtan

   delete(b)

   files1 = systemfunc("ls ./sim_lev100/angle/vertical_wind"+nn(in)+"*")
   c = addfiles(files1, "r")
   ListSetType(c, "cat")

    wwnd = c[:]->ww

    delete(c)

   files = systemfunc("ls ./sim_lev100/angle/cirtano"+nn(in)+"*")
   ano_h = addfiles(files, "r")
   ListSetType(ano_h, "cat")

   t_ano = ano_h[:]->ta

    d = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    t_d01 = d->th

    t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    printVarSummary(t_ev)

    do lev = 0, 90
      do i = 0, 199
        do j = 0,359

          t_ano(:,lev,i,j) = t_ano(:,lev,i,j)-t_ev(0,lev)
        
        end do
      end do
    end do
  
  ;a = addfile("/user_home/jyyin/dta/sim_lev100/angle/vt_azi.nc.nc","r")
  ;tangential = a->wtan
   
  ;b = addfile("/user_home/jyyin/dta/sim_lev100/angle/vr_azi.nc.nc","r")
  ;radial = b->wrad
  
  ;c = addfile("/user_home/jyyin/dta/sim_lev100/angle/azi_vertical.nc","r")
  ;wwnd = c->ww

  ;d = addfile("/user_home/jyyin/dta/sim_lev100/angle/angle_t0_tano.nc","r")
  ;t_ano = d->ta

  radial = runave_n(radial, 5, 0, 1)
  radial = runave_n(radial, 5, 0, 2)
  radial = runave_n(radial, 3, 0, 3)
 
  tangential = runave_n(tangential, 5, 0, 1)
  tangential = runave_n(tangential, 5, 0, 2)
  tangential = runave_n(tangential, 3, 0, 3)

  wwnd = runave_n(wwnd, 5, 0, 1)
  wwnd = runave_n(wwnd, 5, 0, 2)
  wwnd = runave_n(wwnd, 3, 0, 3)

  nr = 200
  r = fspan(0.0,400.0,nr)
  print(r)
  hei = fspan(500, 27500, 100)/1000
  print(hei)

  dims = dimsizes(radial)
  print(dims)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Plotting Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  res = True
  res@cnFillOn = True
  res@cnLinesOn = False

  res@gsnFrame = False
  res@gsnDraw  = False

  res@vpWidthF         = 0.7            ; Change the aspect ratio, but 
  res@vpHeightF        = 0.4            ; make plot as large as possible.

  res@cnInfoLabelOn    = False

  ;res@tmXBMajorOutwardLengthF = 0.0
  ;;res@tmXBMajorLengthF        = 0.01 
  ;res@tmYLMajorOutwardLengthF = 0.0
  ;;res@tmYLMajorLengthF        = 0.01
  ;res@tmYRMajorOutwardLengthF = 0.0
  ;res@tmYRMajorLengthF        = 0.01
 
  ;res@tiYAxisString           = "height(km)"
  ;res@tiXAxisString           = "Radius (km)"
  res@tiYAxisFontHeightF      = 0.02
  res@tiXAxisFontHeightF      = 0.02
  res@tmXBLabelFontHeightF    = 0.015
  res@tmYLLabelFontHeightF    = 0.015
  res@tmYRLabelFontHeightF    = 0.015
  res@gsnStringFontHeightF    = 0.015
  
  res@cnLineThicknessF  = 1.0
  ;res@tmXTOn                  = False
  ;res@tmYROn                  = False

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Time loop ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

do it = 0, dims(0)-13, 36

  aradial = dim_sum_n(radial(it:it+12,:,:,:), 0)/3.
  atangential = dim_sum_n(tangential(it:it+12,:,:,:), 0)/3.
  awwnd = dim_sum_n(wwnd(it:it+12,:,:,:), 0)/3.
  atha  = dim_sum_n(t_ano(it:it+12,:,:,:), 0)/3.

  do ir = 0,3

  rr = (/15,50,100,150/) ;;;20km,50km,100km,200km,300km

  bradial = dim_avg_n(aradial(:,rr(ir)+5:rr(ir)-5,:), 1)
  btangential = dim_avg_n(atangential(:,rr(ir)+5:rr(ir)-5,:), 1)
  bwwnd = dim_avg_n(awwnd(:,rr(ir)+5:rr(ir)-5,:), 1)
  btha  = dim_avg_n(atha(:,rr(ir)+5:rr(ir)-5,:), 1)

;------------------------ radial wind --------------------------------------------------

  res_radial = res
  res_radial@gsnLeftString  = "Temprature Anomaly (shading,K) ~C~Radial wind Speed (contour,black) ~C~"
  res_radial@gsnRightString = it 
  res_radial@cnFillOn = False
  res_radial@cnLinesOn = True

  res_radial@gsnContourNegLineDashPattern  = 11
  res_radial@cnLineColor  =  "black"

  res_radial@cnLineLabelsOn    = True
  ;res_radial@cnLineLabelPerimOn = True
  ;res_radial@cnLineLabelPerimColor = -1
  res_radial@cnLineLabelBackgroundColor = -1

  ;res_radial@cnHighLabelsOn = True
  ;res_radial@cnLowLabelsOn  = True
  ; res_radial@cnLevelSelectionMode = "AutomaticLevels"

   pores = res_radial
   pores@cnLevelSelectionMode = "ExplicitLevels"
   ;pores@cnLevels = (/ 0.2,0.5,0.8,1,2,3,5,7,9,11,15,20/)   ; set levels
   pores@cnLevels = (/ 3,11,18/)   ; set levels
   
   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = 0.0
   ;res_radial@cnMaxLevelValF   = 20.0
   ;if (it.le.181) then
     ;res_radial@cnLevelSpacingF   = 0.5
   ;else
     ;res_radial@cnLevelSpacingF   = 1.5
   ;end if
   poradial_wind= gsn_csm_contour(wks,bradial(0:62,:),pores)


   neres = res_radial
   neres@cnLevelSelectionMode = "ExplicitLevels"
   neres@cnLevels = (/ -0.2,-0.8/)   ; set levels

   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = -15.
   ;res_radial@cnMaxLevelValF   = 0.0
   ;if (it.le.430) then
     ;res_radial@cnLevelSpacingF   = 0.15
   ;else
     ;res_radial@cnLevelSpacingF   = 0.8
   ;end if
   neradial_wind= gsn_csm_contour(wks,bradial(0:62,:),neres)

   zeres = res_radial
   zeres@cnLevelSelectionMode = "ExplicitLevels"
   zeres@cnLevels = (/ 0.0 /)   ; set levels
   zeres@cnLineThicknessF  = 1.6
   ;res_radial@cnLevelSelectionMode = "ManualLevels"
   ;res_radial@cnMinLevelValF = -15.
   ;res_radial@cnMaxLevelValF   = 0.0
   ;if (it.le.430) then
     ;res_radial@cnLevelSpacingF   = 0.15
   ;else
     ;res_radial@cnLevelSpacingF   = 0.8
   ;end if
   zeradial_wind= gsn_csm_contour(wks,bradial(0:62,:),zeres)

;--------------------------------------------------------------------------------
;---------------------- w wind ----------------------------------------------

  res_w = res
  res_w@gsnFrame  = False
  res_w@gsnDraw   = False

  res_w@cnLineColor  =  "green"
  res_w@cnFillOn = False
  res_w@cnLinesOn = True
  
  res_w@cnLevelSelectionMode = "ExplicitLevels"
  res_w@cnLevels = (/-0.01,0.25,0.5,1,2,4/)   ; set levels

  res_w@gsnContourNegLineDashPattern  = 11
  ;res_w@cnLineLabelsOn    = True
  ;res_w@cnLineLabelBackgroundColor = -1
  ;res_w@cnMaxLevelValF   = 0.
  ;res_w@cnMinLevelValF   = -5.
  ;res_w@cnLevelSpacingF = 3.
  res_w@cnLineThicknessF  = 1.0
  
  w_wind = gsn_csm_contour(wks,bwwnd(0:62,:),res_w) 

;--------------------------------------------------------------------------------
  res_t = res

  res_t@gsnFrame = False
  res_t@gsnDraw  = False

  res_t@gsnLeftString  = " "
  res_t@gsnRightString  = " "
  
  time = (it*10)/60./24.
  ;res_t@tiYAxisString = "Day  " + (time-1) + " - " + time
  res_t@tiYAxisString = "T = "+ ((it*10/60.)+in*24) +" h" 
  res_t@tiMainString  = "Radius"+ rr(ir)*2 +" Km" 

  ;res_t@tmYLMode    = "Explicit"
  ;res_t@tmYLValues  = (/0, 7, 14,21,28/)
  ;res_t@tmYLLabels  = (/10,12,14,16,18/)

  ;res_t@tmXBMode    = "Explicit"
  ;res_t@tmXBValues  = (/0, 50,100,150,199/)
  ;res_t@tmXBLabels  = (/0,100,200,300,400/)

    ;res_t@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    ;if (it.le.164) then
        ;res_t@cnLevelSpacingF = 0.5
        ;res_t@cnMinLevelValF  = -4.
       ; res_t@cnMaxLevelValF  = 4.
      ;else if (it.le.430) then
       ; res_t@cnLevelSpacingF = 0.8
       ; res_t@cnMinLevelValF  = -6.
       ; res_t@cnMaxLevelValF  = 6.
      ;else
          ;res_t@cnLevelSpacingF = 1.2
          ;res_t@cnMinLevelValF  = -12
          ;res_t@cnMaxLevelValF  = 12       
      ;end if
    ;end if

  res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res_t@cnLevels     = (/ -5, -4, -3,-2,-1, -0.5, 1, 3, 5, 7, 9,11, 13,15 /)   ; set levels
  res_t@cnFillColors = (/120,110,100,90,82,73,65,60,50,40,30,20, 10, 9,8/)  ; set the colors to be used

  res_t@cnFillOn = True
  res_t@cnLinesOn = False
  res_t@lbLabelBarOn        = False           ; turn off individual cb's
  ;res_t@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
 ; res_t@cnLevels     = (/ -4, -3,-2,-1,-0.5,-0.3,0.3,0.5,  1,3 ,  5,  7,  9,13/)   ; set levels
  ;res_t@cnFillColors = (/  2,  8,16,26,  32,  40,  0, 75, 83,95,106,112,120,126,129/)  ; set the colors to be used
  res_t@cnLineLabelsOn = False                    ; turn the line labels off

  ;print(n)
  t_pl = gsn_csm_contour(wks,btha(0:62,:),res_t) 

;--------------------------------------------------------------------------------

  
  t_k(n) = t_pl
  
  overlay(t_k(n), poradial_wind)
  overlay(t_k(n), neradial_wind)
  overlay(t_k(n), zeradial_wind)
  ;overlay(t_k(n), w_wind)

  ;t_k(n+4) = gsn_csm_contour(wks,t_ano(it,0:62,0:199),res_t) 
  ;overlay(t_k(n+4), w_wind)

  n = n+1
end do

end do
  

end do

  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@lbOrientation        = "Vertical" 
  gsn_panel(wks, t_k(0:15), (/4,4/), gres_ta)
  gsn_panel(wks, t_k(16:32), (/4,4/), gres_ta)
  gsn_panel(wks, t_k(32:47), (/4,4/), gres_ta)
  gsn_panel(wks, t_k(48:63), (/4,4/), gres_ta)
  gsn_panel(wks, win(64:79), (/4,4/), gres_ta)
  ;gsn_panel(wks, win(14:21), (/4,4/), gres_ta)




end