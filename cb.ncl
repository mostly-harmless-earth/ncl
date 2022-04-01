load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    
    files = systemfunc("ls ./sim_lev100/hori/hori_w2*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    ww = ano_h[:]->wa

    ;files = systemfunc("ls ./sim_lev100/hori/ahori_t2*")
    ;ano = addfiles(files, "r")
    ;ListSetType(ano, "cat")

    ano = addfile("sim_lev100/hori/bhori_t2_t0.nc","r")
    t_ano = ano->ta
;
    ;a = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    ;t_d01 = a->th

    files = systemfunc("ls ./sim_lev100/bud/hori/hv_heat_02*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")

    ;a = addfile("/user_home/jyyin/dta/sim_lev100/hori/hv_heat_02*.nc","r")
    heat = a[:]->t_heat

    ;t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    printVarSummary(ww)
    ;printVarSummary(t_ano)
    
    hei = fspan(500, 27500, 100)/1000
    r1 = ispan(0,120,1)
    r2 = ispan(-120,120,2)
    hei@units = "m"
    r1@units = "km"
    ;print(r1)
    ;print(hei)

    rms = dimsizes(ww)

    nt = rms(0)
    nx = rms(2)
    ny = rms(3)
    ;ww = runave_n(ww, 3, 0, 1)

    ;en = conform_dims(rms, t_ev(0,:), 1)
    ;t_ano = t_ano-en

;outfilet = addfile("sim_lev100/hori/bhori_t3_t0.nc","c")
;outfilet->ta = t_ano

    ;ano = addfile("sim_lev100/hori/rela_t0_hori_tano.nc","r")
    ;t_ano = ano->ta(:,40:60,:,:)

    dim = dimsizes(heat)
    printVarSummary(heat)
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

;outfilet = addfile("sim_lev100/wind/u_d5.nc","c")
;outfilet->ua = uu(:,40:60,:,:)

;outfilet = addfile("sim_lev100/wind/v_d5.nc","c")
;outfilet->va = vv(:,40:60,:,:)
    ;printVarSummary(uu)
    ;printVarSummary(vv)
    
    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim_lev100/cb_d2") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    ;gsn_reverse_colormap(wks)

    dt = 24   ;;;; multiple of 6
    plot = new(200, graphic)
    vp = new(100,graphic)
    n = 0
    x = 0

    hi = (/38,48,48,53/)
    hei = fspan(500, 27500, 100)/1000

do it = 48, 96, dt

    print("it = "+it)

    ll = 0
    tcho = new((/dim(0),dim(1)/), float)
    tcho = 0.

    lx = new(100,integer)
    ly = new(100,integer)

    do i = 0, 419
      do j = 0, 419
        
        if (ww(it,38,i,j).ge.15.) then
            
            print("location = " + i +" / " + j)
            
            lx(ll) = i
            ly(ll) = j
            ll = ll+1

            tcho(:,:) = heat(:,:,i,j) + tcho(:,:)

        end if

      end do
    end do

    tcho = tcho/ll
    print("number = "+ll)
    
    do in = 0,1

        time = (it*10/60.)+24

        res                     = True
        gres                    = True
  
        res@gsnDraw            = False                   ; don't draw
        res@gsnFrame           = False                   ; don't advance frame

        ;res@tmYLMode    = "Explicit"
        ;res@tmYLLabels  = r2(::20)
        ;res@tmYLValues  = r1(::20)
  
        ;res@tmXBMode    = "Explicit"
        ;res@tmXBLabels  = r2(::20)
        ;res@tmXBValues  = r1(::20)

        ;res@tmXBMode    = "Explicit"
        ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
        ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

        ;res@tmYLMode    = "Explicit"
        ;res@tmYLValues  = (/0, 11,24,36,40/)
        ; res@tmYLLabels  = (/0.5,5,10,15,17/)

        ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
        ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
        ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;stres = True

        ;u_hori = uu(:,hi(in),:,:)
        ;v_hori = vv(:,hi(in),:,:)

        ;st = gsn_csm_streamline(wks, u_hori(it,160:260,160:260), v_hori(it,160:260,160:260), res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        wres = True
        wres@gsnDraw = False
        wres@gsnFrame = False
        wres@cnFillOn            = False
        wres@cnLinesOn           = True
        wres@cnLineLabelsOn      = False
        wres@cnInfoLabelOn       = False
        wres@cnLineThicknessF    = 0.6

        ;wres@cnLevelSelectionMode = "ManualLevels" 
        ;wres@cnLevelSpacingF = 0.2
        ;wres@cnMinLevelValF  = -1.
        ;wres@cnMaxLevelValF  = 1.

        
        wres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
        wres@cnLevels     = (/10.,15.,20./)   ; set levels
        ;wres@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/) 
        wres@cnMonoLineColor  = False
        wres@cnLineColors = (/"seagreen2","seagreen3","seagreen4"/)

        ;w_hori1 = dim_avg_n(ww(:,47:49,:,:),1)
        ;w_hori2 = dim_avg_n(ww(:,49:51,:,:),1)
        ;w_hori3 = dim_avg_n(ww(:,53:55,:,:),1)

        w_hori = ww(:,hi(in),:,:)
        wres@gsnLeftString = " "
        wres@gsnRightString = " "

        wplot = gsn_csm_contour(wks,w_hori(it,160:260,160:260),wres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        cnres = res
        cnres@cnFillOn            = True
        cnres@cnLinesOn           = False
        cnres@cnLineLabelsOn      = False
        cnres@cnInfoLabelOn       = False

        cnres@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels

        rp1 = ispan(0,100,1)
        rp2 = ispan(-100,100,2)
        ;rp@units = "km"
        ;print(rp)
        cnres@tmXBMode    = "Explicit"
        cnres@tmYLMode    = "Explicit"
        
        cnres@tmYLLabels  = rp2(::25)
        cnres@tmYLValues  = rp1(::25)
        
        cnres@tmXBLabels  = rp2(::25)
        cnres@tmXBValues  = rp1(::25)

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
        
        cnres@lbLabelBarOn        = False 
        cnres@gsnLeftString = sprintf("%6.2f",hei(hi(in))) +" Km"
        cnres@gsnRightString = "time = " + time + "h " 
        plot(n) =  gsn_csm_contour(wks,t_hori(it,160:260,160:260), cnres)

        ;overlay(plot, wplot)
        ;overlay(plot(n), st)
        overlay(plot(n), wplot)
        ;overlay(plot(n+1), wplot2)
        ;overlay(plot(n+2), wplot3)
        ;overlay(plot(n+1), wndplot2)
        ;overlay(plot(n+2), wndplot3)
        n = n+1
        ;print(it)
    end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  vres = True
  vres@gsnDraw = False
  vres@gsnFrame = False
  
  vres@vpHeightF = 0.7
  vres@vpWidthF = 0.4

  ;vres@trXMinF          = -7.           ; Set min/max of left Y axis
  ;vres@trXMaxF          = 7.

  vres@gsnXRefLine  = 0.; four X reference lines 
  vres@gsnXRefLineThicknessF = 1.2  

  ;tcho = t_ano(it,:,236,203)+t_ano(it,:,237,202)+t_ano(it,:,237,203))/3

  ;vres@tmYLMode    = "Explicit"
  ;vres@tmYLValues  = (/0, 7, 14,21,28/)
  ;vres@tmYLLabels  = (/10,12,14,16,18/)

  tcho1 = tcho(it,0:65)
  
  tcho2 = dim_avg_n(heat(it,:,:,205:215),2)
  tcho3 = dim_avg_n(tcho2(:,205:215),1)

  printVarSummary(tcho1)
  printVarSummary(tcho3)
  
  vp(x) = gsn_csm_xy(wks, tcho1(0:65), hei(0:65),vres)
  vp(x+4) = gsn_csm_xy(wks, tcho3(0:65), hei(0:65),vres) 
  
  ;vp(x+1) = gsn_csm_y(wks, t_ano(it,36:65,237,202), vres)
  ;vp(x+2) = gsn_csm_y(wks, t_ano(it,36:65,237,203), vres) 
  
  x = x+1

end do
    
    gres = True
    gres@gsnPanelLabelBar = True
    gres@lbOrientation  = "Vertical"
    ;gres@txString = 
    gsn_panel(wks, plot(0:3), (/2,2/), gres)
    gsn_panel(wks, vp(0:7), (/2,4/), gres)
    ;gsn_panel(wks, plot(48:59), (/4,6/), gres)
    ;gsn_panel(wks, plot(60:83), (/4,6/), gres)
    ;gsn_panel(wks, plot(84:107), (/4,6/), gres)



end