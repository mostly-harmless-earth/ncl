load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
     
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  a = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d03_2000-02-01_06:00:00","r")
  a_out = addfile("/user_home/jyyin/dta/sim_lev100/wrfout_d02_2000-02-01_06:00:00","r")
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/ntimes,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

   nr = 150
   nz = 100  ; Sigma levels

   nx = 420
   ny = 420

   nxo = 240
   nyo = 240

 t_ano = new((/ntimes,nz,nx,ny/),"float")
 th = new((/ntimes,nz,nx,ny/),"float")
 th_out = new((/ntimes,nz,nxo,nyo/),"float")

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/horizontal_plot_30") 
    gsn_define_colormap(wks,"MPL_coolwarm")  ; Change color map.

    ;;; t_sum: 120 X 68 X 150
    ;;; interval 6min 
    ;;; 1h: 10 ;;; 2h: 20

  do it = 6, 9 , 1; TIME LOOP
   
    print("Working on time: " + it )

    z = wrf_user_getvar(a, "z", it)
    z_out = wrf_user_getvar(a_out, "z", it)
 
    thb  = wrf_user_getvar(a, "th", it)
    thb_out  = wrf_user_getvar(a_out, "th", it)
    printVarSummary(thb)
    ;printVarSummary(thb_out)

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 100)

    do iz = 0, nz-1
      th(it,iz,:,:) = wrf_interp_3d_z(thb, z, hei(iz))
      th_out(it,iz,:,:) = wrf_interp_3d_z(thb_out, z_out, hei(iz))
    end do

  end do

    th_avg1 = dim_avg_n(th_out,3)
    th_avg  = dim_avg_n(th_avg1,2)
    ;printVarSummary(t_ano)
    ;printVarSummary(th)
    ;printVarSummary(th_avg)

  do it = 0, ntimes-1,1
    do iz = 0,nz-1,1
        t_ano(it,iz,:,:) = th(it,iz,:,:)-th_avg(it,iz)
    end do
  end do 


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
    t_ano2 = dim_avg_n(t_ano(:,46:48,:,:),1)
    do it = 6, 9,1
      ;res@tiMainString = "time = " + (it*6/60.) + "h"
      plots =  gsn_csm_contour(wks,t_ano2(it,:,:), res)
    end do

    t_ano!0 = "time"
    t_ano!1 = "height"
    t_ano!2 = "Radial_sn"
    t_ano!3 = "Radial_we"
    t_ano@long_name = "temperature anomaly"
    t_ano@units = "K"
    t_ano@_FillValue = 9.96921e+36

;outfilet = addfile("sim_lev100/tha/unazi_tano_d5_00.nc","c")
;outfilet->ta = t_ano
    
end