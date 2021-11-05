load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

    ;files = systemfunc("ls ./sim9/heat*")
    ;a_heat = addfiles(files, "r")
    ;ListSetType(a_heat, "cat")

    a1 = addfile("/user_home/jyyin/dta/sim9/t_heat.nc","r")
    t_heat = a1->t_heat 

    ;files = systemfunc("ls ./sim8/bud/uncp_pbl*")
    ;a_pbl = addfiles(files, "r")
    ;ListSetType(a_pbl, "cat")
    
    a2 = addfile("/user_home/jyyin/dta/sim9/t_pbl.nc","r")
    t_pbl = a2->t_pbl

    ;files = systemfunc("ls ./sim8/bud/diff*")
    ;a_diff = addfiles(files, "r")
    ;ListSetType(a_diff, "cat")
    ;t_diff = a_diff[:]->t_diff

    a3 = addfile("/user_home/jyyin/dta/sim9/t_diff.nc","r")
    t_diff = a3->t_diff
    

    ;files = systemfunc("ls ./sim8/bud/adv_v*")
    ;a_v = addfiles(files, "r")
    ;ListSetType(a_v, "cat")
    
    a4 = addfile("/user_home/jyyin/dta/sim9/t_adv_v.nc","r")
    t_adv_v = a4->t_adv_v

    ;files = systemfunc("ls ./sim8/bud/adv_h*")
    ;a_h = addfiles(files, "r")
    ;ListSetType(a_h, "cat")
    
    a5 = addfile("/user_home/jyyin/dta/sim9/t_adv_h.nc","r")
    t_adv_h = a5->t_adv_h

    a6 = addfile("/user_home/jyyin/dta/sim9/t_adv.nc","r")
    t_adv = a6->t_adv

    ;files = systemfunc("ls ./sim8/theta_ano0804.nc")
    ;ano_h = addfiles(files, "r")
    ;ListSetType(ano_h, "cat")
    
    ano_h = addfile("sim9/tano_azi_interp.nc","r")
    t_ano = ano_h->ta

    hei = fspan(500, 26500, 68)/1000
    r1 = fspan(0.0,700.0,150)
    hei@units = "m"
    r1@units = "km"

    printVarSummary(t_ano)
    ;print(hei)
    
    t_sum = t_adv + t_heat + t_pbl + t_diff
    t_temp = t_ano(1,:,:)-t_ano(0,:,:)
    ;printVarSummary(t_temp)

  wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9/t66t") 
  gsn_define_colormap(wks,"MPL_coolwarm")  ; Change color map.

  plot = new(9,graphic)
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
  
  
  res@tiYAxisString           = "height(km)"
  res@tiXAxisString           = "times(hr)"
  res@tiMainString = "Hovmoller 72-96h (r=0km)"

  ;res@tmYLMode    = "Explicit"
  ;res@tmYLLabels  = (/5,10,15,20/)
 ; res@tmYLValues  = (/12,25,38,51/)

  ti = ispan(0, 479, 1)
  res@tmXBMode    = "Explicit"
  res@tmXBValues  = ti(::40)
  res@tmXBLabels   = ti(::40)*3/60+72
  
  t_ano2=transpose(t_ano(:,0:44,1))
  plots = gsn_csm_contour(wks,t_ano2, res)

  plots =  gsn_csm_contour(wks,t_ano(0,0:44,:), res)
  
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
  ares@tmXBValues  = (/0,22,42,64,86,107,128,149/)
  ares@tmXBLabels   = (/0,100,200,300,400,500,600,700/)

  ares@tmYLMode    = "Explicit"
  ares@tmYLValues  = (/0,12,26/)
  ares@tmYLLabels  = (/10,15,20/)
  
  ares@tiYAxisFontHeightF      = 0.025
  ares@tiXAxisFontHeightF      = 0.025
  ares@tmXBLabelFontHeightF    = 0.025
  ares@tmYLLabelFontHeightF    = 0.025
  ares@tmYRLabelFontHeightF    = 0.025
  ares@gsnStringFontHeightF    = 0.025

  ares@tiMainString = "Vertical advection"
  plot(0) = gsn_csm_contour(wks,t_adv_v(0,0:44,:)*3600, ares)

  ares@tiMainString = "Horizontal advection"
  plot(1) = gsn_csm_contour(wks,t_adv_h(0,0:44,:)*3600, ares)

  ares@tiMainString = "Diffusion"
  plot(2) = gsn_csm_contour(wks,t_diff(0,0:44,:)*3600, ares)

  ares@tiMainString = "Nonadiabatic heating"
  plot(3) = gsn_csm_contour(wks,t_heat(0,0:44,:)*3600, ares)

  ares@tiMainString = "PBL"
  plot(4) = gsn_csm_contour(wks,t_pbl(0,0:44,:)*3600, ares)

  ares@tiMainString = "Sum of RHS"
  plot(5) = gsn_csm_contour(wks,t_sum(0,0:44,:)*3600, ares)

  ares@tiMainString = "Actual change"
  plot(6) = gsn_csm_contour(wks,t_temp(0:44,:), ares)

  t_dire = t_sum(0,0:44,:)*180-t_temp(0:44,:)

  ares@tiMainString = "diffrence"
  plot(7) = gsn_csm_contour(wks,t_dire(:,:), ares)

  gres = True
  gsn_panel(wks, plot, (/3,3/), gres)

end












