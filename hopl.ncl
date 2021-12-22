load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    files = systemfunc("ls ./sim9_v3/tha/unazi_*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")

    ;ano_h = addfile("sim9_v3/tha/unazi_tano_d1_12.nc","r")
    t_ano = ano_h[:]->ta

    hei = fspan(500, 27500, 68)/1000
    r1 = fspan(0.0,700.0,150)
    hei@units = "m"
    r1@units = "km"
    ;print(r1)
    ;print(hei)
    printVarSummary(t_ano)

    nt = 120*9

  do it = 0, nt-1
    do iz = 0,67

      t_ano(it,iz,:,:) = smth9(t_ano(it,iz,:,:), 0.5, 0.25, True) 
    
    end do
  end do

    wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9_v3/Hori_tano") 
    ;gsn_define_colormap(wks,"BlueWhiteOrangeRed")  ; Change color map.
    gsn_define_colormap(wks,"MPL_RdBu")
    gsn_reverse_colormap(wks)


    dt = 5


do it = 0,nt-1, dt

  res                     = True

  gres                    = True
  
  res@gsnDraw            = True                   ; don't draw
  res@gsnFrame           = True                   ; don't advance frame
  res@cnFillOn            = True
  res@cnLinesOn           = False
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

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = (/5,10,15,20/)
 ; res@tmYLValues  = (/12,25,38,51/)

  ti = ispan(0, 132, 1)
  res@tmXBMode    = "Explicit"
  res@tmXBValues  = ti(::20)
  res@tmXBLabels   = ti(::20)*6

  res@tmYLMode    = "Explicit"
  res@tmYLValues  = ti(::20)
  res@tmYLLabels   = ti(::20)*6
  
  ;t_ano2=transpose(t_ano(:,0:44,1))
  ;plots = gsn_csm_contour(wks,t_ano2, res)

    ;res@gsnDraw            = False                   ; don't draw
    ;res@gsnFrame           = False                   ; don't advance frame

    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
   ; res@tmYLLabels  = (/0.5,5,10,15,17/)

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-2.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.2,  1, 2, 3, 4, 5, 6,  7,  8,  9/)   ; set levels
    ;res@cnFillColors = (/  10,  15,  20,  30,  40,  60,  0, 70,75,80,85,90,95,100,105,110,112/)  ; set the colors to be used
    
    time = it*6/60.
    res@tiMainString = "time = " + time + "h day = " + time/24.

    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    
    if (it.le.262) then

      t_hori = dim_avg_n(t_ano(:,31:33,:,:),1)
       
      res@cnLevelSpacingF = 0.2
      res@cnMinLevelValF  = -3.
      res@cnMaxLevelValF  = 3.

    else 
      if (it.le.926) then

        t_hori = dim_avg_n(t_ano(:,33:35,:,:),1)
       
        res@cnLevelSpacingF = 0.5
        res@cnMinLevelValF  = -4.
        res@cnMaxLevelValF  = 4.
      else

        t_hori = dim_avg_n(t_ano(:,36:38,:,:),1)

        res@cnLevelSpacingF = 0.5
        res@cnMinLevelValF  = -6.5
        res@cnMaxLevelValF  = 6.5

      end if
    end if
    
    plots =  gsn_csm_contour(wks,t_hori(it,54:186,54:186), res)

end do

end