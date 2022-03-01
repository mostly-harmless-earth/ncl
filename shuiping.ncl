load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    files = systemfunc("ls ./sim_lev100/hori/ahori_t4*")
    ano = addfiles(files, "r")
    ListSetType(ano, "cat")

    ;ano = addfile("sim_lev100/hori/rela_t0_hori_tano.nc","r")
    t_ano = ano[:]->ta

    a = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    t_d01 = a->th

    t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    ;printVarSummary(t_ev)
    ;printVarSummary(t_ano)

    do lev = 0, 90
      do i = 0, 419
        do j = 0, 419

          t_ano(:,lev,i,j) = t_ano(:,lev,i,j)-t_ev(0,lev)
        
        end do 
      end do
    end do

;outfilet = addfile("sim_lev100/hori/rela_t0_hori_tano.nc","c")
;outfilet->ta = t_ano

    ;ano = addfile("sim_lev100/hori/rela_t0_hori_tano.nc","r")
    ;t_ano = ano->ta(:,40:60,:,:)

    dim = dimsizes(t_ano)

    files = systemfunc("ls ./sim_lev100/hori/hori_u4*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    uu = ano_h[:]->ua

    files = systemfunc("ls ./sim_lev100/hori/hori_v4*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    vv = ano_h[:]->va

    ;files = systemfunc("ls ./sim_lev100/hori/hori_w3*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    ;ww = ano_h[:]->wa

    hei = fspan(500, 27500, 100)/1000
    r1 = ispan(0,400,1)
    r2 = ispan(-400,400,2)
    hei@units = "m"
    r1@units = "km"
    ;print(r1)
    print(hei)
    printVarSummary(t_ano)
    printVarSummary(uu)
    printVarSummary(vv)

    rms = dimsizes(uu)

    nt = rms(0)
    nx = rms(2)
    ny = rms(3)

;outfilet = addfile("sim_lev100/wind/u_d5.nc","c")
;outfilet->ua = uu(:,40:60,:,:)

;outfilet = addfile("sim_lev100/wind/v_d5.nc","c")
;outfilet->va = vv(:,40:60,:,:)

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/Hori_d3") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    ;gsn_reverse_colormap(wks)

    dt = 36   ;;;; multiple of 6
    plot = new(200, graphic)
    n=0

do it = 0, rms(0)-1, dt

  time = (it*10/60.)+24

  res                     = True
  gres                    = True
  
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

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

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = (/5,10,15,20/)
 ; res@tmYLValues  = (/12,25,38,51/)

  res@tmYLMode    = "Explicit"
  res@tmYLLabels  = r2(::50)
  res@tmYLValues  = r1(::50)
  
  res@tmXBMode    = "Explicit"
  res@tmXBLabels  = r2(::50)
  res@tmXBValues  = r1(::50)


    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
   ; res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used
    

    
  
    vcres                     = res      ; plot mods desired
    vcres@lbLabelStride       = 2         ; plot every other colar bar label
    vcres@vcRefMagnitudeF         = 4.              ; make vectors larger
    vcres@vcRefLengthF            = 0.030            ; ref vec length ;;; biger Value biger Arrow
    vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
    vcres@vcMinDistanceF          = 0.05            ; thin out vectors
    vcres@vcGlyphOpacityF         = 0.8

    ;vcres@vcFillArrowsOn           = True
    vcres@vcWindBarbLineThicknessF    =  1.5
    vcres@vcFillArrowEdgeThicknessF = 2.0
    vcres@vcMinFracLengthF         = 0.33
    vcres@vcMinMagnitudeF          = 0.001
    vcres@vcMonoFillArrowFillColor = False
    vcres@vcMonoWindBarbColor     = False
    vcres@vcFillArrowEdgeColor    ="Black"
    vcres@vcMinDistanceF           = 0.03
   ; opts@vcWindBarbTickLengthF    = 0.33
    
    u_hori1 = dim_avg_n(uu(:,47:49,:,:),1)
    u_hori2 = dim_avg_n(uu(:,49:51,:,:),1) 
    u_hori3 = dim_avg_n(uu(:,53:55,:,:),1)

    v_hori1 = dim_avg_n(vv(:,47:49,:,:),1)
    v_hori2 = dim_avg_n(vv(:,49:51,:,:),1)
    v_hori3 = dim_avg_n(vv(:,53:55,:,:),1)

    ;uc = dim_sum_n(u_hori(it,10:410,10:410), 0)
    ;vc = dim_sum_n(v_hori(it,10:410,10:410), 0)
    uc1 = u_hori1(it,10:410,10:410)
    vc1 = v_hori1(it,10:410,10:410)
    
    uc2 = u_hori2(it,10:410,10:410)
    vc2 = v_hori2(it,10:410,10:410)
    
    uc3 = u_hori3(it,10:410,10:410)
    vc3 = v_hori3(it,10:410,10:410)
 
    wndplot1 = gsn_vector(wks, uc1, vc1, vcres)
    wndplot2 = gsn_vector(wks, uc2, vc2, vcres)
    wndplot3 = gsn_vector(wks, uc3, vc3, vcres)

    wres = True
    wres@cnFillOn            = False
    wres@cnLinesOn           = True
    wres@cnLineLabelsOn      = False
    wres@cnLineThicknessF    = 1.6

    wres@cnLevelSelectionMode = "ManualLevels" 
    wres@cnLevelSpacingF = 0.25
    wres@cnMinLevelValF  = -1.
    wres@cnMaxLevelValF  = 1.

    ;wplot = gsn_csm_contour(wks,w_hori(it,10:410,10:410),wres)

    cnres = res
    cnres@cnFillOn            = True
    cnres@cnLinesOn           = False
    cnres@cnLineLabelsOn      = False

    cnres@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    
    t_hori1 = dim_avg_n(t_ano(:,47:49,:,:),1)
    t_hori2 = dim_avg_n(t_ano(:,49:51,:,:),1)
    t_hori3 = dim_avg_n(t_ano(:,53:55,:,:),1)

    cnres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    cnres@cnLevels     = (/ -5, -4, -3,-2,-1, 0, 1, 3, 5, 7, 9,11, 13,15 /)   ; set levels
    cnres@cnFillColors = (/120,110,100,90,82,73,66,60,50,40,30,20, 10, 9,8/)  ; set the colors to be used
    ;if (it.le.164) then
        ;cnres@cnLevelSpacingF = 0.5
        ;cnres@cnMinLevelValF  = -4.
        ;cnres@cnMaxLevelValF  = 4.
      ;else if (it.le.430) then
        ;cnres@cnLevelSpacingF = 0.8
        ;cnres@cnMinLevelValF  = -6.
        ;cnres@cnMaxLevelValF  = 6.
     ; else
         ; cnres@cnLevelSpacingF = 1.2
         ; cnres@cnMinLevelValF  = -12
         ; cnres@cnMaxLevelValF  = 12       
      ;end if
    ;end if
    
    cnres@tiMainString = "time = " + time + "h " +" 13.5km"
    plot(n) =  gsn_csm_contour(wks,t_hori1(it,10:410,10:410), cnres)

    cnres@tiMainString = "time = " + time + "h "+" 14km"
    plot(n+1) =  gsn_csm_contour(wks,t_hori2(it,10:410,10:410), cnres)

    cnres@tiMainString = "time = " + time + "h "+" 15km"
    plot(n+2) =  gsn_csm_contour(wks,t_hori3(it,10:410,10:410), cnres)


    ;overlay(plot, wplot)
    overlay(plot(n), wndplot1)
    overlay(plot(n+1), wndplot2)
    overlay(plot(n+2), wndplot3)

    n = n+3
    ;print(it)

end do

    gres = True
    gres@gsnPanelLabelBar = True
    gres@lbOrientation        = "Vertical"
    gres@txString = "Theta Anomaly"
    gsn_panel(wks, plot(0:11), (/4,3/), gres)


end