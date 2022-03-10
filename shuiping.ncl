load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    files = systemfunc("ls ./sim_lev100/hori/ahori_t2*")
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
    printVarSummary(t_ano)
    ;files = systemfunc("ls ./sim_lev100/hori/hori_u2*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    ;uu = ano_h[:]->ua

    ;files = systemfunc("ls ./sim_lev100/hori/hori_v2*")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    ;vv = ano_h[:]->va

    files = systemfunc("ls ./sim_lev100/hori/hori_w2*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    ww = ano_h[:]->wa

    hei = fspan(500, 27500, 100)/1000
    r1 = ispan(0,120,1)
    r2 = ispan(-120,120,2)
    hei@units = "m"
    r1@units = "km"
    ;print(r1)
    ;print(hei)
    
    ;printVarSummary(uu)
    ;printVarSummary(vv)

    rms = dimsizes(ww)

    nt = rms(0)
    nx = rms(2)
    ny = rms(3)

;outfilet = addfile("sim_lev100/wind/u_d5.nc","c")
;outfilet->ua = uu(:,40:60,:,:)

;outfilet = addfile("sim_lev100/wind/v_d5.nc","c")
;outfilet->va = vv(:,40:60,:,:)

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/levels_d2") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    ;gsn_reverse_colormap(wks)

    dt = 12   ;;;; multiple of 6
    plot = new(200, graphic)
    n=0

do it = 36, 96, dt
    
    hi = (/38,42,46,50/)
    hei = fspan(500, 27500, 100)/1000
    

    do in = 0,3

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

        res@tmYLMode    = "Explicit"
        res@tmYLLabels  = r2(::20)
        res@tmYLValues  = r1(::20)
  
        res@tmXBMode    = "Explicit"
        res@tmXBLabels  = r2(::20)
        res@tmXBValues  = r1(::20)

        ;res@tmXBMode    = "Explicit"
        ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
        ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

        ;res@tmYLMode    = "Explicit"
        ;res@tmYLValues  = (/0, 11,24,36,40/)
        ; res@tmYLLabels  = (/0.5,5,10,15,17/)

        ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
        ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
        ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
       
        vcres                     = res      ; plot mods desired
        vcres@lbLabelStride       = 2         ; plot every other colar bar label
        vcres@vcRefMagnitudeF         = 4.              ; make vectors larger
        vcres@vcRefLengthF            = 0.030            ; ref vec length ;;; biger Value biger Arrow
        vcres@vcGlyphStyle            = "LineArrow"    ; turn on curly vectors
        vcres@vcMinDistanceF          = 0.05            ; thin out vectors
        vcres@vcGlyphOpacityF         = 0.8

        ;vcres@vcFillArrowsOn           = True
        vcres@vcWindBarbLineThicknessF    =  1.0
        vcres@vcFillArrowEdgeThicknessF = 1.0
        vcres@vcMinFracLengthF         = 0.33
        vcres@vcMinMagnitudeF          = 0.001
        vcres@vcMonoFillArrowFillColor = False
        vcres@vcMonoWindBarbColor     = False
        vcres@vcFillArrowEdgeColor    ="gray70"
        ; opts@vcWindBarbTickLengthF    = 0.33
    
        ;u_hori1 = dim_avg_n(uu(:,46:48,:,:),1)
        ;u_hori2 = dim_avg_n(uu(:,49:51,:,:),1) 
        ;u_hori3 = dim_avg_n(uu(:,53:55,:,:),1)

        ;v_hori1 = dim_avg_n(vv(:,46:48,:,:),1)
        ;v_hori2 = dim_avg_n(vv(:,49:51,:,:),1)
        ;v_hori3 = dim_avg_n(vv(:,53:55,:,:),1)

        ;u_hori = uu(:,hi(in),:,:)
        ;v_hori = vv(:,hi(in),:,:)

       ; uc = u_hori(it,150:270,150:270)
        ;vc = v_hori(it,150:270,150:270)

        ;wndplot = gsn_vector(wks, uc, vc, vcres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        wres = True
        wres@gsnDraw = False
        wres@gsnFrame = False
        wres@cnFillOn            = False
        wres@cnLinesOn           = True
        wres@cnLineLabelsOn      = False
        wres@cnInfoLabelOn       = False
        wres@cnLineThicknessF    = 0.8

        ;wres@cnLevelSelectionMode = "ManualLevels" 
        ;wres@cnLevelSpacingF = 0.2
        ;wres@cnMinLevelValF  = -1.
        ;wres@cnMaxLevelValF  = 1.
        wres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
        wres@cnLevels     = (/1.,5.,10.,15./)   ; set levels
        ;wres@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/) 
        wres@cnMonoLineColor  = False
        wres@cnLineColors = (/"seagreen1","seagreen2","seagreen3","seagreen4"/)

        ;w_hori1 = dim_avg_n(ww(:,47:49,:,:),1)
        ;w_hori2 = dim_avg_n(ww(:,49:51,:,:),1)
        ;w_hori3 = dim_avg_n(ww(:,53:55,:,:),1)

        w_hori = ww(:,hi(in),:,:)

        wplot = gsn_csm_contour(wks,w_hori(it,150:270,150:270),wres)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        cnres = res
        cnres@cnFillOn            = True
        cnres@cnLinesOn           = False
        cnres@cnLineLabelsOn      = False

        cnres@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    
        ;t_hori1 = dim_avg_n(t_ano(:,47:49,:,:),1)
        ;t_hori2 = dim_avg_n(t_ano(:,49:51,:,:),1)
        ;t_hori3 = dim_avg_n(t_ano(:,53:55,:,:),1)

        t_hori = t_ano(:,hi(in),:,:)

        cnres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
        cnres@cnLevels     = (/ -5, -4, -3,-2,-1,-0.5,0.5, 3, 5, 7, 9,11, 13,15 /)   ; set levels
        cnres@cnFillColors = (/120,110,100,95,90,82,65,60,50,40,30,20, 10, 9,8/)  ; set the colors to be used
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
    
        cnres@gsnLeftString = sprintf("%6.2f",hei(hi(in))) +" Km"
        cnres@gsnRightString = "time = " + time + "h " 
        plot(n) =  gsn_csm_contour(wks,t_hori(it,150:270,150:270), cnres)

        ;overlay(plot, wplot)
        ;overlay(plot(n), wndplot)
        overlay(plot(n), wplot)
        ;overlay(plot(n+1), wplot2)
        ;overlay(plot(n+2), wplot3)
        ;overlay(plot(n+1), wndplot2)
        ;overlay(plot(n+2), wndplot3)
        n = n+1
        ;print(it)
    end do
end do
    
    gres = True
    gres@gsnPanelLabelBar = True
    gres@lbOrientation  = "Vertical"
    ;gres@txString = 
    gsn_panel(wks, plot(0:19), (/5,4/), gres)
 
    ;gsn_panel(wks, plot(24:47), (/4,6/), gres)
    ;gsn_panel(wks, plot(48:59), (/4,6/), gres)
    ;gsn_panel(wks, plot(60:83), (/4,6/), gres)
    ;gsn_panel(wks, plot(84:107), (/4,6/), gres)

end