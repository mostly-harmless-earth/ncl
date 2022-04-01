load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin


;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200
  r = fspan(0.0,400.0,nr)
  r@units = "km"

  nz = 100  ; Sigma levels
  hei = fspan(500, 27500, 100)

  degtorad = 2*3.14159/360.0
  radtodeg = 180.0/3.14159
  alfa = fspan(0.0,359.0,360)
  alfa = alfa*degtorad

  dx = new((/nr,360/),"float")
  dy = new((/nr,360/),"float")

 do i = 0,nr-1,1
    do j = 0,359,1
         dx(i,j)= r(i)*cos(alfa(j))
         dy(i,j)= r(i)*sin(alfa(j))
    end do
end do
  
  lat_p = new(nr*360,"float")
  lon_p = new(nr*360,"float")
  
  do i = 0, nr-1, 1
    do j = 0, 359, 1

      lat_p(i*360+j) = dx(i,j)
      lon_p(i*360+j) = dy(i,j)
    
    end do
  end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
         ; "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
         ; "5_00","5_06","5_12","5_18"/)

    ;nn1 = (/"100","106","112","118","200","206","212","218",\
          ;"300","306","312","318","400","406","412","418",\
          ;"500","506","512","518"/)
    
    ;in = 5

    files = systemfunc("ls ./sim_lev100/bud/ang_heat_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_heat = ano_h[:]->t_heat
    
    files = systemfunc("ls ./sim_lev100/bud/ang_pbl_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_pbl = ano_h[:]->t_pbl
    
    files = systemfunc("ls ./sim_lev100/bud/ang_diff_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_diff1 = ano_h[:]->t_diff
    
    files = systemfunc("ls ./sim_lev100/bud/ang_diff3_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_diff3 = ano_h[:]->t_diff
    
    files = systemfunc("ls ./sim_lev100/bud/ang_adv_v_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_adv_v = ano_h[:]->t_adv_v

    files = systemfunc("ls ./sim_lev100/bud/ang_adv_h_02*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    t_adv_h = ano_h[:]->t_adv_h

    ;a_heat = addfile("sim_lev100/bud/ang_heat_02*","r")
    ;t_heat = a_heat->t_heat

    ;a_pbl = addfile("sim_lev100/bud/ang_pbl_02*","r")
    ;t_pbl = a_pbl->t_pbl

    ;a_diff = addfile("sim_lev100/bud/ang_diff_02*","r")
    ;t_diff1 = a_diff->t_diff

    ;a_diff3 = addfile("sim_lev100/bud/ang_diff3_02*","r")
    ;t_diff3 = a_diff3->t_diff

    ;a_v = addfile("sim_lev100/bud/ang_adv_v_02*","r")
    ;t_adv_v = a_v->t_adv_v

    ;a_h = addfile("sim_lev100/bud/ang_adv_h_02*","r")
    ;t_adv_h = a_h->t_adv_h
    
    ;d = addfile("sim_lev100/angle/cirtano2*","r")
    ;t_ano = d->ta

    files = systemfunc("ls ./sim_lev100/angle/cirtano2*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")
    t_ano = a[:]->ta

    files = systemfunc("ls ./sim_lev100/angle/vertical_wind2*")
    b = addfiles(files, "r")
    ListSetType(b, "cat")
    ww = b[:]->ww

    ae = addfile("/user_home/jyyin/dta/sim_lev100/d01/tha100.nc","r")
    t_d01 = ae->th

    t_ev = dim_avg_n(t_d01(:,:,55:83), 2) ;;; r = fspan(0.0, 1800.0, 100)

    rms = dimsizes(t_ano)

    en = conform_dims(rms, t_ev(0,:), 1)
    t_ano = t_ano-en

    t_diff = t_diff1 + t_diff3

    t_sum = t_adv_h + t_adv_v + t_heat + t_pbl  + t_diff
    t_adv = t_adv_h + t_adv_v

    printVarSummary(t_sum)
    printVarSummary(t_ano)
    print(r)
     
    ;t_sum = smth9(t_sum, 0.50, 0.25, False)
    ;t_sum = smth9(t_sum, 0.50, -0.25, False)
    t_sum = runave_n(t_sum, 3, 0, 0)
    t_sum = runave_n(t_sum, 3, 0, 0)
    t_sum = runave_n(t_sum, 5, 0, 1)
    t_sum = runave_n(t_sum, 3, 0, 1)
    ;t_sum = runave_n(t_sum, 5, 0, 2)
    ;t_sum = runave_n(t_sum, 3, 0, 2)
    ;t_sum = runave_n(t_sum, 5, 0, 3)
    ;t_sum = runave_n(t_sum, 3, 0, 3)

    ;t_ano = smth9(t_ano, 0.50, 0.25, False)
    ;t_ano = smth9(t_ano, 0.50, -0.25, False)

    t_ano = runave_n(t_ano, 3, 0, 1)
    t_ano = runave_n(t_ano, 3, 0, 1)
    ;t_ano = runave_n(t_ano, 3, 0, 2)
    ;t_ano = runave_n(t_ano, 3, 0, 2)
    ;t_ano = runave_n(t_ano, 3, 0, 3)
    ;t_ano = runave_n(t_ano, 3, 0, 3)
 
    t_adv_h = runave_n(t_adv_h, 3, 0, 1)
    t_adv_v = runave_n(t_adv_v, 3, 0, 1)
    t_heat  = runave_n(t_heat, 3, 0, 1)
    t_pbl   = runave_n(t_pbl, 3, 0, 1)
    t_diff  = runave_n(t_diff, 3, 0, 1)   
    
    ;t_sum = runave_n(t_sum, 3, 0, 0)
    ;t_sum = runave_n(t_sum, 5, 0, 1)
    ;t_sum = runave_n(t_sum, 5, 0, 2)

    wks=gsn_open_wks("pdf","sim_lev100/cb_heat") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    ;;; t_sum: 36 X 420 X 420
    ;;; interval 10 min 
    ;;; 1h: 6 ;;; 2h: 12

    n = 0
    dims = dimsizes(t_pbl)
    plots = new(12,graphic)


    ;do i = 0,3,1

    ;timi = (/198,276,396,492/) ;;;33h, 46h, 66h, 82h
    ;dtg  = (/29,59,119,59/)
    
    ;it = timi(i)
    ;dt = dtg(i)
    
    it = 54
    dt = 29
    nmin = 10*60

    ;th(it,:,:) = dim_sum_n(th(it-6:it+6,:,:), 0)/3.

    t_sum_1h   = dim_sum_n(t_sum(it:it+dt,:,:,:), 0)
    t_adv_h_1h = dim_sum_n(t_adv_h(it:it+dt,:,:,:), 0)
    t_adv_v_1h = dim_sum_n(t_adv_v(it:it+dt,:,:,:), 0)
    t_adv_1h   = dim_sum_n(t_adv(it:it+dt,:,:,:), 0)

    t_heat_1h  = dim_sum_n(t_heat(it:it+dt,:,:,:), 0)
    t_pbl_1h   = dim_sum_n(t_pbl(it:it+dt,:,:,:), 0)
    ;t_cu_1h    = dim_sum_n(t_cu(it:it+dt,:,:), 0)
    ;t_ra_1h    = dim_sum_n(t_ra(it:it+dt,:,:), 0)
    t_diff_1h  = dim_sum_n(t_diff(it:it+dt,:,:,:), 0)

    t_adv_1h = t_adv_h_1h + t_adv_v_1h

    t_temp = t_ano(it+dt+1,:,:,:)-t_ano(it,:,:,:)
    ;t_temp = th2(it,:,:)-th(it,:,:)
    ;t_temp(:,:) = smth9(t_temp(:,:), 0.5, -0.25, True)
    ;printVarSummary(t_cu_1h)

  gres                    = True
  plot9 = new(9,graphic)
  plot6 = new(2,graphic)
  vp = new(100, graphic)

  res = True
  res@cnFillOn            = True
  res@cnLinesOn           = False

  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame

  res@sfXArray = lat_p
  res@sfYArray = lon_p

  res@trGridType        = "TriangularMesh"

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 17,35,53/)
  ;res@tmYLLabels  = (/0.5,5,10,15/)

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLValues  = (/0, 7, 14,21,28/)
  ;res@tmYLLabels  = (/10,12,14,16,18/)

  ;res@vpWidthF           = .6
  ;res@vpHeightF          = .4

  tres = res

  tres@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  tres@cnLevelSpacingF = 0.5
  tres@cnMinLevelValF  = -5.
  tres@cnMaxLevelValF  = 5.

  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevels     = (/ 15, 13, 11,  9,  7, 5, 3, 1,-0.1,-1,-2,-3,-4,-5 /)   ; set levels
  ;res@cnFillColors = (/120,115,110,105,100,95,90,82,  73,65,50,40,30,20,10/)  ; set the colors to be used

  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevels     = (/-5,-4,-3,-2,-1,-0.5, 1, 3, 5, 7,  9, 11, 13,15 /)   ; set levels
  ;res@cnFillColors = (/10,20,30,40,50,  60,65,70,80,90,100,110,120,124,128/)
  
  time1 = it*10/60.+24
  time2 = (it+dt+1)*10/60.+24

  ilev = 50

  btano1 = ndtooned(t_ano(it,ilev,:,:))
  btano2 = ndtooned(t_ano(it+dt+1,ilev,:,:))
  
  res@gsnRightString = time1 +"h"
  plot6(0) = gsn_csm_contour(wks, btano1, tres)

  res@gsnRightString = time2 +"h"
  plot6(1) = gsn_csm_contour(wks, btano2, tres)

  vpres = res

  vpres@cnLinesOn = True
  vpres@cnFillOn = False

  vpres@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  vpres@cnLevels     = (/5.,10.,15.,20./)   ; set levels
  ;wres@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/) 
  vpres@cnMonoLineColor  = False
  vpres@cnLineColors = (/"seagreen1","seagreen2","seagreen3","seagreen4"/)

  bw1 = ndtooned(ww(it,ilev,:,:))
  bw2 = ndtooned(ww(it+dt+1,ilev,:,:))

  vp1 = gsn_csm_contour(wks, bw1, vpres)
  vp2 = gsn_csm_contour(wks, bw2, vpres)

  ;res@gsnRightString = time+4 +"h"
  ;plot6(2) = gsn_csm_contour(wks, t_ano(it+24,36:65,:), res)
  
  ;res@gsnRightString = time+6 +"h"
  ;plot6(3) = gsn_csm_contour(wks, t_ano(it+54,36:65,:), res)
  
  ;res@gsnRightString = time+12 +"h"
  ;plot6(4) = gsn_csm_contour(wks, t_ano(it+72,36:65,:), res)

  overlay(plot6(0), vp1)
  overlay(plot6(1), vp2)

  gres@txString = "time = " + time1 +"h - "+ time2 + "h"
  gsn_panel(wks, plot6, (/1,2/), gres)

  ares = True

  ares@sfXArray = lat_p
  ares@sfYArray = lon_p
  
  ares@gsnDraw            = False                   ; don't draw
  ares@gsnFrame           = False                   ; don't advance frame
  
  ares@vpWidthF           = .5
  ares@vpHeightF          = .5
  
  ares@tiXAxisString           = "Radius(km)"
  ares@tiYAxisString           = "height(km)"
  ares@cnFillOn                = True
  ares@cnLinesOn               = False 

  ares@tmXMajorGrid          = True               ; Add white grid lines
  ares@tmXMajorGridLineColor = "gray"
  ares@tmYMajorGrid          = True
  ares@tmYMajorGridLineColor = "gray"

  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025


  ;ares@cnLevelSelectionMode = "AutomaticLevels"

  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 17,35,53,60/)
  ;ares@tmYLLabels  = (/0.5,5,10,15,17/)


  ;ares@tmYLMode    = "Explicit"
  ;ares@tmYLValues  = (/0, 7, 14,21,28/)
  ;ares@tmYLLabels  = (/10,12,14,16,18/)

  ;ares@tmXBMode    = "Explicit"
  ;ares@tmXBValues  = (/0, 40, 80, 120,160,199/)
  ;ares@tmXBLabels  = (/0, 80, 160,240,320,400/)

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-10,-0.8,-0.6,-0.4,-0.2, 0,   2,  4,  6,  8,10/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,1ilev,152,167,183,199,215/)  ; set the colors to be used

  ;ares@lbLabelBarOn        = False           ; turn off individual cb's
  ;ares@lbOrientation        = "Vertical"
  ;ares@tiMainString = "Total Advection"
  ;plot9(0) = gsn_csm_contour(wks,t_adv_1h(11:41,:)*720, ares)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Draw RHS & Actual change ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels  
  if (it.le.1000) then 
    ares@cnLevelSpacingF = 0.5
    ares@cnMinLevelValF  = -3.0
    ares@cnMaxLevelValF  = 3.0
  else
    ares@cnLevelSpacingF = 1.
    ares@cnMinLevelValF  = -6.
    ares@cnMaxLevelValF  = 6.
  end if

  t_dire = t_sum_1h(ilev,:,:)*nmin-t_temp(ilev,:,:)
  
  bsum = ndtooned(t_sum_1h(ilev,:,:))
  bt_temp = ndtooned(t_temp(ilev,:,:))
  bt_dire = ndtooned(t_dire(:,:))

  ares@tiMainString = "Sum of RHS"
  plot9(1) = gsn_csm_contour(wks,bsum*nmin, ares)

  printVarSummary(t_sum_1h)

  ares@tiMainString = "Actual change"
  plot9(0) = gsn_csm_contour(wks,bt_temp, ares)

  
  ares@tiMainString = "diffrence"
  plot9(2) = gsn_csm_contour(wks,bt_dire, ares)

  ares@cnLevelSelectionMode = "ManualLevels"
  ares@cnLevelSpacingF = 0.5
  ares@cnMinLevelValF  = -3.0
  ares@cnMaxLevelValF  = 3.0
  
  bt_diff_1h = ndtooned(t_diff_1h(ilev,:,:))
  bt_heat_1h = ndtooned(t_heat_1h(ilev,:,:))
  bt_adv_1h  = ndtooned(t_adv_1h(ilev,:,:))
  bt_adv_v_1h = ndtooned(t_adv_v_1h(ilev,:,:))
  bt_adv_h_1h = ndtooned(t_adv_h_1h(ilev,:,:))
  bt_pbl_1h = ndtooned(t_pbl_1h(ilev,:,:))
  ;bt_adv_h_1h = ndtooned(t_adv_h_1h(ilev,:,:))

  ares@tiMainString = "Diff"
  plot9(8) = gsn_csm_contour(wks,bt_diff_1h*nmin, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot9(7) = gsn_csm_contour(wks,bt_heat_1h*nmin, ares)

  ares@tiMainString = "PBL"
  plot9(6) = gsn_csm_contour(wks,bt_pbl_1h*nmin, ares)
  
  ares@tiMainString = "ADV"
  plot9(5) = gsn_csm_contour(wks,bt_adv_1h*nmin, ares)

  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-100,-80,-60,-40,-20, 0,   20,  40,  60,  80,100/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,1ilev,152,167,183,199,215/)  ; set the colors to be used

  ares@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
  ;if (it.le.400) then 
    ares@cnLevelSpacingF = 50.
    ares@cnMinLevelValF  = -800.
    ares@cnMaxLevelValF  = 800.
  ;else
    ;ares@cnLevelSpacingF = 20.
    ;ares@cnMinLevelValF  = -100.
    ;ares@cnMaxLevelValF  = 100.
  ;end if

  ares@tiMainString = "Horizontal Advection"
  plot9(3) = gsn_csm_contour(wks,bt_adv_h_1h*nmin, ares)
  ;ares@tiMainString = "Radiation "
  ;plot9(6) = gsn_csm_contour(wks,t_ra_1h(11:41,:)*720, ares)
  
  ares@tiMainString = "Vertical Advection"
  plot9(4) = gsn_csm_contour(wks,bt_adv_v_1h*nmin, ares)
  
  ;gres = True
  ;gres@tiMainString = "theta Budget Term 1 hour"
  ;gsn_panel(wks, plot9, (/2,3/), gres)

  ;ares@cnFillOn  = False
  ;ares@cnLinesOn = True 
  ;ares@cnLineThicknessF = 1.5
  ;ares@cnLineColor = "black"
 
  ;ares@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;ares@cnLevels     = (/-5,-4,-3,-2,-1.5,-1/)   ; set levels
  ;ares@cnFillColors = (/ 7, 23,33,59,71,101,1ilev,152,167,183,199,215/)  ; set the colors to be used

  ;ne1 = gsn_csm_contour(wks,t_temp(ilev,:,:), ares)
  ;ne2 = gsn_csm_contour(wks,t_temp(ilev,:,:), ares)

  ;overlay(plot9(3), ne1)
  ;overlay(plot9(4), ne2)

  ;gres@gsnPanelLabelBar = True
  gsn_panel(wks, plot9, (/3,3/), gres)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    dim = dimsizes(t_heat)

    ll = 0
    tcho = new(dim(1), float)
    tcho = 0.
    
    do ctt = it, it+dt+1,6
      do i = 1, 50
        do j = 1, 359
        
          if (ismissing(ww(ctt,38,i,j))) then
            
            print("Missing at" + i +" / " + j)
            continue

          end if
          
          if (ww(ctt,38,i,j).ge.10.) then
            
            print("location = " + i +" / " + j +"when time = " + ctt)
            
            ;lx(ll) = i
            ;ly(ll) = j
            tcho(:) = t_heat(ctt,:,i,j) + tcho(:)
            ll = ll+1

          end if
        
        end do
      end do
    end do
    
    if (ll.ge.1) then
      print("numbers = "+ll)
      tcho(:) = tcho(:)/(ll+0.0)
    end if

  vres = True
  vres@gsnDraw = False
  vres@gsnFrame = False
  
  vres@vpHeightF = 0.7
  vres@vpWidthF = 0.4
  
  ;vres@trYMinF  = -800.           ; Set min/max of left Y axis
  ;vres@trYMaxF  = 800.

  vres@gsnXRefLine  = 0.; four X reference lines 
  vres@gsnXRefLineThicknessF = 1.0  

  ;tcho = t_ano(it,:,236,203)+t_ano(it,:,237,202)+t_ano(it,:,237,203))/3

  ;vres@tmYLMode    = "Explicit"
  ;vres@tmYLValues  = (/0, 7, 14,21,28/)
  ;vres@tmYLLabels  = (/10,12,14,16,18/)

  bud = new((/5,dim(1)/), float)

  do ir = 0,60,20

  tcho2 = dim_avg_n(t_heat_1h(:,ir:ir+20,:),1)
  tcho3 = dim_avg_n(tcho2,1) 
  bud(0,:) = tcho3
  
  tcho2 = dim_avg_n(t_adv_1h(:,ir:ir+20,:),1)
  tcho3 = dim_avg_n(tcho2,1) 
  bud(1,:) = tcho3
  
  tcho2 = dim_avg_n(t_adv_v_1h(:,ir:ir+20,:),1)
  tcho3 = dim_avg_n(tcho2,1) 
  bud(2,:) = tcho3

  tcho2 = dim_avg_n(t_adv_h_1h(:,ir:ir+20,:),1)
  tcho3 = dim_avg_n(tcho2,1) 
  bud(3,:) = tcho3

  tcho2 = dim_avg_n(t_temp(:,ir:ir+20,:),1)
  tcho3 = dim_avg_n(tcho2,1) 
  bud(4,:) = tcho3

  printVarSummary(tcho2)
  printVarSummary(tcho3)
  hei = fspan(500, 27500, 100)/1000

  ;vres@xyLineColor = "green"
  vres@xyLineColors     = (/10,50,110,90,150/) ; colors chosen
  vres@xyDashPatterns   = 0.      ; make all lines solid
  vres@xyLineThicknessF = 2.2
  vres@pmLegendDisplayMode    = "Always"            ; turn on legend
  vres@xyExplicitLegendLabels = (/"H_Diabatic"," Total Advection","Vertical Advection", \
                                 "horizontal Advection","Actual Change"/)


  vp(0) = gsn_csm_xy(wks, tcho(40:65)*dt*nmin, hei(40:65),vres)
  vp(1) = gsn_csm_xy(wks, bud(:,40:65)*dt*nmin, hei(40:65),vres) 

  gsn_panel(wks, vp, (/1,2/), gres)

end do
  
  ;vp(x+1) = gsn_csm_y(wks, t_ano(it,36:65,237,202), vres)
  ;vp(x+2) = gsn_csm_y(wks, t_ano(it,36:65,237,203), vres) 

;end do

end












