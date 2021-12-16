load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
     
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim9_v3/wrfout_d02_2000-09-03_12:00:00","r")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/480,ntimes,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

   nr = 150
   nz = 68  ; Sigma levels

 t_ano = new((/ntimes,nz,240,240/),"float")
 th = new((/ntimes,nz,240,240/),"float")

 t_adv_v = new((/ntimes,nz,240,240/),"float")
 t_adv_h = new((/ntimes,nz,240,240/),"float")
 t_adv = new((/ntimes,nz,240,240/),"float")

 t_diff  = new((/ntimes,nz,240,240/),"float")
 t_heat  = new((/ntimes,nz,240,240/),"float")
 t_pbl   = new((/ntimes,nz,240,240/),"float")
 t_cu   = new((/ntimes,nz,240,240/),"float")
 t_ra   = new((/ntimes,nz,240,240/),"float")

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9_v3/Horizontal_plot") 
    gsn_define_colormap(wks,"MPL_coolwarm")  ; Change color map.

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 6min 
    ;;; 1h: 10 ;;; 2h: 20

  do it = 55, 90 , 1; TIME LOOP
   
    print("Working on time: " + it )

    z = wrf_user_getvar(a, "z", it)
 
    tb_adv_h = wrf_user_getvar(a, "T_TEND_ADV_H", it)
    tb_adv_v = wrf_user_getvar(a, "T_TEND_ADV_V", it)
    tb_adv   = wrf_user_getvar(a, "RTHFTEN", it)

    tb_diff  = wrf_user_getvar(a, "T_TEND_DIFF", it)
    tb_cu    = wrf_user_getvar(a, "RTHCUTEN", it)
    tb_ra    = wrf_user_getvar(a, "RTHRATEN", it)
    tb_pbl   = wrf_user_getvar(a, "RTHBLTEN", it)
    tb_heat  = wrf_user_getvar(a, "H_DIABATIC", it)

    thb  = wrf_user_getvar(a, "th", it)
    printVarSummary(thb)

    mut = wrf_user_getvar(a, "MUT", it)
    ;mub = wrf_user_getvar(a, "MUB", it)
    ;mut = mu+mub
;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 68)

    do iz = 0, nz-1

      th(it,iz,:,:) = wrf_interp_3d_z(thb, z, hei(iz))

      t_adv_v(it,iz,:,:) = wrf_interp_3d_z(tb_adv_v, z, hei(iz))/mut(:,:)
      t_adv_h(it,iz,:,:) = wrf_interp_3d_z(tb_adv_h, z, hei(iz))/mut(:,:)
      t_adv(it,iz,:,:)  = wrf_interp_3d_z(tb_adv, z, hei(iz))

      t_diff(it,iz,:,:)  = wrf_interp_3d_z(tb_diff, z, hei(iz))/mut(:,:)
      t_heat(it,iz,:,:)  = wrf_interp_3d_z(tb_heat, z, hei(iz))
      t_pbl(it,iz,:,:)   = wrf_interp_3d_z(tb_pbl, z, hei(iz))
      t_cu(it,iz,:,:)    = wrf_interp_3d_z(tb_cu, z, hei(iz))
      t_ra(it,iz,:,:)    = wrf_interp_3d_z(tb_ra, z, hei(iz))

    end do

  end do

    n = 0
    plots = new(12,graphic)

    th_avg1 = dim_sum_n(th,3)
    th_avg  = dim_sum_n(th_avg1,2)
    ;printVarSummary(t_ano)
    ;printVarSummary(th)
    ;printVarSummary(th_avg)

  do it = 1, ntimes-1,1
    do iz = 0,nz-1,1
        t_ano(it,iz,:,:) = th(it,iz,:,:)-th_avg(it,iz)
    end do
  end do 

    t_adv_v = t_adv_v*0.98
    t_adv = t_adv_h + t_adv_v
    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl + t_ra + t_diff
     
    do it = 59,69,30

    t_sum_1h   = dim_sum_n(t_sum(it:it+29,:,:,:), 0)
    t_adv_h_1h = dim_sum_n(t_adv_h(it:it+29,:,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(it:it+29,:,:,:), 0)
    t_adv_1h   = dim_sum_n(t_adv(it:it+29,:,:,:), 0)

    t_heat_1h  = dim_sum_n(t_heat(it:it+29,:,:,:), 0)
    t_pbl_1h   = dim_sum_n(t_pbl(it:it+29,:,:,:), 0)
    t_cu_1h    = dim_sum_n(t_cu(it:it+29,:,:,:), 0)
    t_ra_1h    = dim_sum_n(t_ra(it:it+29,:,:,:), 0)
    t_diff_1h  = dim_sum_n(t_diff(it:it+29,:,:,:), 0)

    t_adv_1h = t_adv_h_1h + t_adv_v_1h
    t_temp = t_ano(it+30,:,:,:)-t_ano(it,:,:,:)

  res                     = True
  gres                    = True
  
  res@gsnDraw            = True                   ; don't draw
  res@gsnFrame           = True                   ; don't advance frame
  res@cnFillOn            = True
  res@cnLinesOn           = True
  res@cnLineLabelsOn      = False
  ;res@cnLineThicknesses   = 1.5
  ;gres@gsMarkerIndex = 0
  ;gres@gsMarkerSizeF    = 0.015
  ;gres@gsMarkerColor       = "navy"                 ; color chosen
  ;gres@gsMarkerThicknessF = 3
  ;res@xyLineThicknesses = 2.0
  ;res@tiMainString = "Sea Level Pressure ~c~ Max Wind Speed"
  
  
  ;res@tiYAxisString           = "height(km)"
  ;res@tiXAxisString           = "times(hr)"
  ;res@tiMainString = "Hovmoller 72-96h (r=0km)"

  ;ti = ispan(0, 479, 1)
  ;res@tmXBMode    = "Explicit"
  ;res@tmXBValues  = ti(::40)
  ;res@tmXBLabels   = ti(::40)*3/60+72
  
  ;t_ano2=transpose(t_ano(:,0:44,1))
  ;plots = gsn_csm_contour(wks,t_ano2, res)

    res@gsnDraw            = False                   ; don't draw
    res@gsnFrame           = False                   ; don't advance frame

    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.8,-1.4,-1.0,-0.6,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

    ;res@lbLabelBarOn        = False           ; turn off individual cb's
 
    ;res@tiMainString = "time = " + ((it+1)*6/60.) + "h"
    plots(n) =  gsn_csm_contour(wks,t_ano(it,24,:,:), res)
    n = n+1
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw budget term ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  plot9 = new(9,graphic)
  
  ares = True
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame

  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "height(km)"
  ares@cnFillOn            = True
  ares@cnLinesOn           = True
  
  ares@tmXBMode = "Explicit"
  r1 = fspan(0.0,700.0,150)
  ;print(r1)
  ;ares@tmXBMode    = "Explicit"
  ;ares@tmXBValues  = (/0, 22, 43, 64, 85/)
  ;ares@tmXBLabels  = (/0,100,200,300,400/)

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/1,3,5,7,10/)
  ;ares@tmYLLabels  = (/13,14,15,16,17/)

  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025

  ares@cnLevelSelectionMode     = "AutomaticLevels"

  ;ares@tiMainString = "Total Advection"
  ;plot9(0) = gsn_csm_contour(wks,t_adv_1h(11:41,:)*360, ares)

  ares@tiMainString = "Vertical Advection"
  plot9(0) = gsn_csm_contour(wks,t_adv_v_1h(24,:,:)*360, ares)

  ares@tiMainString = "Horizontal Advection"
  plot9(1) = gsn_csm_contour(wks,t_adv_h_1h(24,:,:)*360, ares)
;
  ares@tiMainString = "Total Advection"
  plot9(2) = gsn_csm_contour(wks,t_adv_1h(24,:,:)*360, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot9(3) = gsn_csm_contour(wks,t_heat_1h(24,:,:)*360, ares)

  ares@tiMainString = "PBL + Diffusion"
  plot9(4) = gsn_csm_contour(wks,(t_pbl_1h(24,:,:)+t_diff_1h(24,:,:))*360, ares)

  ares@tiMainString = "Cu"
  plot9(5) = gsn_csm_contour(wks,t_cu_1h(24,:,:)*360, ares)

  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*360, ares)

  ;gres = True
  ;gres@tiMainString = "theta Budget Term 1 hour"
  ;gsn_panel(wks, plot9, (/2,3/), gres)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;plot3 = new(3,graphic)

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/1,3,5,7,10/)
  ;ares@tmYLLabels  = (/13,14,15,16,17/)

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevelSpacingF = 0.2
  ;ares@cnLevels     = (/ -1.1,-0.9,-0.7,-0.5,-0.4,-0.3,-0.2,-0.1,0.1, 0.2,0.5,0.8/)   ; set levels
  ;ares@cnFillColors = (/    2,   5,   8,  16,  24,  32,  48,  64,  0,  80, 90,100,110/)  ; set the colors to be used

  ares@tiMainString = "Sum of RHS"
  plot9(6) = gsn_csm_contour(wks,t_sum_1h(24,:,:)*360, ares)

  ares@tiMainString = "Actual change"
  plot9(7) = gsn_csm_contour(wks,t_temp(24,:,:), ares)

  t_dire = t_sum_1h(24,:,:)*360-t_temp(24,:,:)

  time = ((it+1)*6/60.)

  ares@tiMainString = "diffrence"
  plot9(8) = gsn_csm_contour(wks,t_dire(:,:), ares)

  ;gres@txString = "time = " + time +"h - "+ (time+1) + "h"
  gsn_panel(wks, plot9, (/3,3/), gres)

end do

  ;res@tiMainString = "time = " + (time+0.5) + "h"
  plots(n) =  gsn_csm_contour(wks,t_ano(it,24,:,:), res)
  gres_ta = True
  gres_ta@gsnPanelLabelBar = True
  gres_ta@txString = "Theta Anomaly"
  gsn_panel(wks, plots, (/3,4/), gres_ta)

end