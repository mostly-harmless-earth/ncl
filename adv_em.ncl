    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

   
         
begin    

    ;nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
         ; "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
         ; "5_00","5_06","5_12","5_18"/)

   ; nn1 = (/"100","106","112","118","200","206","212","218",\
          ;"300","306","312","318","400","406","412","418",\
         ; "500","506","512","518","600","606","612","618"/)

;do in = 16,16

    ;b = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/radial_wind"+nn1(in)+".nc","r")
    ;c = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/vertical_wind"+nn1(in)+".nc","r")
    ;teh = addfile("/user_home/jyyin/dta/sim_lev100/t_wind_perh/cirtano"+nn1(in)+".nc","r")

    files = systemfunc("ls ./sim_lev100/t_wind_perh/radial_wind5*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    uu = ano_h[:]->wrad
    
    files = systemfunc("ls ./sim_lev100/t_wind_perh/vertical_wind5*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")  
    ww = ano_h[:]->ww

    files = systemfunc("ls ./sim_lev100/t_wind_perh/cirtano5*")
    ano_h = addfiles(files, "r")
    ListSetType(ano_h, "cat")
    theta = ano_h[:]->ta

    files1 = systemfunc("ls ./sim_lev100/bud/ang_adv_v_05*")
    ano_h1 = addfiles(files1, "r")
    ListSetType(ano_h1, "cat")
    adv_v = ano_h1[:]->t_adv_v

    files1 = systemfunc("ls ./sim_lev100/bud/ang_adv_h_05*")
    ano_h1 = addfiles(files1, "r")
    ListSetType(ano_h1, "cat")
    adv_h = ano_h1[:]->t_adv_h

    ;uu = runave_n(uu, 3, 0, 0)
    ;ww = runave_n(ww, 3, 0, 0)
    ;theta = runave_n(theta, 3, 0, 0)

    ;uu = runave_n(uu, 3, 0, 1)
    ;ww = runave_n(ww, 3, 0, 1)
    ;theta = runave_n(theta, 3, 0, 1)
    
    ;uu = runave_n(uu, 3, 0, 2)
    ;ww = runave_n(ww, 3, 0, 2)
    ;theta = runave_n(theta, 3, 0, 2)

    delete(ano_h)
    delete(ano_h1)
    delete(files)
    delete(files1)

;;;;;;;;;;;;;;;;;; calculate the mean ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;RADVM = - avg(vr)*d(adv(theta))/dr
    ;RADVE = - d(avg(vr'*theta'))/dr - avg(vr'*theta')/r
    ;VADVM = - avg(w)*d(adv(theta))/dz
    ;VADVE = - d(avg(w'*theta'))/dz

    dis = dimsizes(uu) ;;144 x 91 x 200 x 360
    print(dis)
    printVarSummary(theta)

;;;;;;;;;;;;;;;;;; calculate the mean ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    um = dim_avg_n(uu, 3)
    wm = dim_avg_n(ww, 3)
    thetam = dim_avg_n(theta,3)
    
;;;;;;;;;;;;;;;;;; calculate the eddy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    umt = conform_dims(dis, um, (/0,1,2/))
    wmt = conform_dims(dis, wm, (/0,1,2/))
    thetamt = conform_dims(dis, thetam, (/0,1,2/))

; check umt 
    
    printVarSummary(um)
    
    ue = uu-umt
    we = ww-wmt
    thetae = theta - thetamt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    radve = new((/dis(0),dis(1),dis(2)/), float)
    radvm = new((/dis(0),dis(1),dis(2)/), float)
    vadve = new((/dis(0),dis(1),dis(2)/), float)
    vadvm = new((/dis(0),dis(1),dis(2)/), float)

    total_adv_v1 = new(dis, float)
    total_adv_h1 = new(dis, float)
    
    r = fspan(0, 400, 200)*1000
    dr = r(10)-r(9)
    print(dr)

    hei = fspan(500,27500,100)
    dz = hei(10)-hei(9)
    print(dz)

    uthe = ue*thetae
    wthe = we*thetae
    printVarSummary(uthe)

    uthm = dim_avg_n(uthe,3)
    ;uthm = conform_dims(dis, uthm1, (/0,1,2/))

    wthm = dim_avg_n(wthe,3)
    ;wthm = conform_dims(dis, wthm1, (/0,1,2/))

    printVarSummary(um)
    printVarSummary(thetam)
    printVarSummary(uthm)
    
    do ir = 1, dis(2)-2

; check diff 
        radvm(:,:,ir) = -1*um(:,:,ir)*(thetam(:,:,ir+1)-thetam(:,:,ir-1))/2./dr
        radve(:,:,ir) = -1*(uthm(:,:,ir+1)-uthm(:,:,ir+1))/2./dr-uthm(:,:,ir)/r(ir)

        total_adv_h1(:,:,ir,:) = -1*uu(:,:,ir,:)*(theta(:,:,ir+1,:)-theta(:,:,ir-1,:))/dr
        print("r = " +ir)
    
    end do

    do ih = 1, dis(1)-2

        vadvm(:,ih,:) = -1*wm(:,ih,:)*(thetam(:,ih+1,:)-thetam(:,ih-1,:))/2./dz
        vadve(:,ih,:) = -1*(wthm(:,ih,:)-wthm(:,ih-1,:))/dz

        total_adv_v1(:,ih,:,:) = -1*ww(:,ih,:,:)*(theta(:,ih+1,:,:)-theta(:,ih-1,:,:))/2./dz
        print("h = "+ih)
    
    end do

    total_adv_v = dim_avg_n(total_adv_v1,3)
    total_adv_h = dim_avg_n(total_adv_h1,3)

    delete(uu)
    delete(ww)
    delete(theta)
    delete(um)
    delete(ue)
    delete(wm)
    delete(we)
    delete(thetam)
    delete(thetae)

    d = addfile("/user_home/jyyin/dta/sim_lev100/angle/d7_t0_ta.nc","r")
    t_ano = d->ta

;end do

    ;it = 12
    ;dt = 6
    
    it = 0
    dt = 36

    ns = 10*60.

    radvm_6h = dim_sum_n(radvm(it:it+dt,:,:), 0)
    radve_6h = dim_sum_n(radve(it:it+dt,:,:), 0)
    vadvm_6h = dim_sum_n(vadvm(it:it+dt,:,:), 0)
    vadve_6h = dim_sum_n(vadve(it:it+dt,:,:), 0)

    total_h_6h = dim_sum_n(total_adv_h(it:it+dt,:,:), 0)
    total_v_6h = dim_sum_n(total_adv_v(it:it+dt,:,:), 0)

    total = total_v_6h + total_h_6h

    ;radvm_6h = runave_n(radvm_6h, 3, 0, 0)
    ;radve_6h = runave_n(radve_6h, 3, 0, 0)
    ;vadvm_6h = runave_n(vadvm_6h, 3, 0, 0)
    ;vadve_6h = runave_n(radve_6h, 3, 0, 0)

    ;radvm_6h = runave_n(radvm_6h, 3, 0, 1)
    ;;radve_6h = runave_n(radve_6h, 3, 0, 1)
    ;vadvm_6h = runave_n(vadvm_6h, 3, 0, 1)
    ;vadve_6h = runave_n(radve_6h, 3, 0, 1)

    adv_vp = dim_avg_n(adv_v,3)
    model_adv_v_6h = dim_sum_n(adv_vp(it:it+dt,:,:), 0)

    adv_hp = dim_avg_n(adv_h,3)
    model_adv_h_6h = dim_sum_n(adv_hp(it:it+dt,:,:), 0)

    radv_6h = radvm_6h + radve_6h
    vadv_6h = vadvm_6h + vadve_6h

    adv_6h = radvm_6h + radve_6h + vadvm_6h + vadve_6h
    adv_model = model_adv_v_6h + model_adv_h_6h

    dd = adv_6h-adv_model

    h = radve + radvm
    v = vadve + vadvm 

 v!0 = "time"
 v!1 = "height"
 v!2 = "Radial"
 v@long_name = "vertical advection"
 v@units = "K/s"
 v@_FillValue = 9.96921e+36

 h!0 = "time"
 h!1 = "height"
 h!2 = "Radial"
 h@long_name = "Horizontal advection"
 h@units = "K/s"
 h@_FillValue = 9.96921e+36

    plot4 = new(15, graphic)

    wks = gsn_open_wks("pdf","sim_lev100/test_d5") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@cnFillOn = True
    res@cnLinesOn = False

    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 50,100,150,199/)
    ;res@tmXBLabels  = (/0,100,200,300,400/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 7, 14,21,28/)
    ;res@tmYLLabels  = (/10,12,14,16,18/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 17,35,53,60/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)

    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    res@cnLevelSpacingF = 0.5
    res@cnMinLevelValF  = -15.
    res@cnMaxLevelValF  = 15.

    res@tiMainString = "RADVM = ~C~ - avg(vr)*d(avg(theta))/dr"
    plot4(0) = gsn_csm_contour(wks, radvm_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = "RADVE = ~C~ - d(avg(vr'*theta'))/dr - avg(vr'*theta')/r"
    plot4(1) = gsn_csm_contour(wks, radve_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = "VADVM = ~C~ - avg(w)*d(adv(theta))/dz"
    plot4(2) = gsn_csm_contour(wks, vadvm_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = "VADAE = ~C~ - d(avg(w'*theta'))/dz"
    plot4(3) = gsn_csm_contour(wks, vadve_6h(0:65,0:180)*ns, res)

    res@tiMainString = " RADVM + RADVE "
    plot4(4) = gsn_csm_contour(wks, radv_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = " VADVM + VADAE "
    plot4(5) = gsn_csm_contour(wks, vadv_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = "-u*d(theta)/dr "
    plot4(6) = gsn_csm_contour(wks, total_h_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = "-w*d(theta)/dz"
    plot4(7) = gsn_csm_contour(wks, total_v_6h(0:65,0:180)*ns, res)
    
    res@tiMainString = "RADVM + RADVE + VADVM + VADAE"
    plot4(8) = gsn_csm_contour(wks, adv_6h(0:65,0:180)*ns, res)  

    res@tiMainString = "u*d(theta)/dr + w*d(theta)/dz"
    plot4(9) = gsn_csm_contour(wks, total(0:65,0:180)*ns, res)
      
    res@tiMainString = "adv_model"
    plot4(10) = gsn_csm_contour(wks, adv_model(0:65,0:180)*ns, res) 

    res@tiMainString = "Diff"
    plot4(11) = gsn_csm_contour(wks, adv_6h(0:65,0:180)*ns-adv_model(0:65,0:180)*ns,res)   

    res@tiMainString = "Theta Change"
    plot4(12) = gsn_csm_contour(wks, t_ano(756,0:65,0:180) - t_ano(720,0:65,0:180), res)   
    
    res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
    res@cnLevelSpacingF = 5.
    res@cnMinLevelValF  = -80.
    res@cnMaxLevelValF  = 80.
    
    res@tiMainString = "model adv_v"
    plot4(13) = gsn_csm_contour(wks, model_adv_v_6h(0:65,0:180)*ns, res)

    res@tiMainString = "model adv_h"
    plot4(14) = gsn_csm_contour(wks, model_adv_h_6h(0:65,0:180)*ns, res)



  ;overlay(plot9(3), ne1)
  ;overlay(plot9(4), ne2)

  gres = True
  gsn_panel(wks, plot4, (/5,4/), gres)

end


