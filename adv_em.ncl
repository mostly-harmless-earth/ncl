    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

    nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18"/)

    nn1 = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518","600","606","612","618"/)

do in = 16,16
 
    b = addfile("/user_home/jyyin/dta/sim_lev100/angle/radial_wind"+nn1(in)+".nc","r")
    uu = b->wrad
  
    c = addfile("/user_home/jyyin/dta/sim_lev100/angle/vertical_wind"+nn1(in)+".nc","r")
    ww = c->ww

    teh = addfile("/user_home/jyyin/dta/sim_lev100/angle/cirtano"+nn1(in)+".nc","r")
    theta = teh->ta

    
    ;RADVM = - avg(vr)*d(adv(theta))/dr
    ;RADVE = - d(avg(vr'*theta'))/dr - avg(vr'*theta')/r
    ;VADVM = - avg(w)*d(adv(theta))/dz
    ;VADVE = - d(avg(w'*theta'))/dz

    dis = dimsizes(uu)
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
    
    printVarSummary(um)
    
    ue = uu-umt
    we = ww-wmt
    thetae = theta - thetamt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    radve = new((/dis(0),dis(1),dis(2)/), float)
    radvm = new((/dis(0),dis(1),dis(2)/), float)
    vadve = new((/dis(0),dis(1),dis(2)/), float)
    vadvm = new((/dis(0),dis(1),dis(2)/), float)
    
    r = fspan(0, 400, 200)*1000
    dr = r(1)-r(0)

    hei = fspan(500,25700,100)
    dz = hei(1)-hei(0)

    uthe = ue*thetae
    wthe = we*thetae

    uthm = dim_avg_n(uthe,3)
    ;uthm = conform_dims(dis, uthm1, (/0,1,2/))

    wthm = dim_avg_n(wthe,3)
    ;wthm = conform_dims(dis, wthm1, (/0,1,2/))

    printVarSummary(um)
    printVarSummary(thetam)
    printVarSummary(uthm)
    
    do ir = 1, dis(2)-2

        radvm(:,:,ir) = -1*um(:,:,ir)*(thetam(:,:,ir)-thetam(:,:,ir-1))/dr
        radve(:,:,ir) = -1*(uthm(:,:,ir)-uthm(:,:,ir-1))/dr-uthm(:,:,ir)/r(ir)
        print("r = " +ir)
    
    end do

    do ih = 1, dis(1)-2

        vadvm(:,ih,:) = -1*wm(:,ih,:)*(thetam(:,ih,:)-thetam(:,ih-1,:))/dz
        vadve(:,ih,:) = -1*(wthm(:,ih,:)-wthm(:,ih-1,:))/dz
        print("h = "+ih)
    
    end do

end do

    nmin = 10*60
    ;radvmp = dim_avg_n(radvm,3)
    radvm_6h = dim_sum_n(radvm, 0)
    
    ;radvep = dim_avg_n(radve,3)
    radve_6h = dim_sum_n(radve, 0)
    
    ;vadvmp = dim_avg_n(vadvm,3)
    vadvm_6h = dim_sum_n(vadvm, 0)
    
    ;vadvep = dim_avg_n(vadve,3)
    vadve_6h = dim_sum_n(vadve, 0)

    radv_6h = radvm_6h + radve_6h
    vadv_6h = vadvm_6h + vadve_6h

    adv_6h = radv_6h+vadv_6h

    plot4 = new(7, graphic)

    wks=gsn_open_wks("pdf","sim_lev100/e-m-test") 
    gsn_define_colormap(wks,"MPL_RdBu")  ; Change color map.
    gsn_reverse_colormap(wks)

    res = True
    res@cnFillOn = True
    res@cnLinesOn = False

    plot4(0) = gsn_csm_contour(wks, radvm_6h(0:65,:)*nmin, res)
    plot4(1) = gsn_csm_contour(wks, radve_6h(0:65,:)*nmin, res)
    plot4(2) = gsn_csm_contour(wks, vadvm_6h(0:65,:)*nmin, res)
    plot4(3) = gsn_csm_contour(wks, vadve_6h(0:65,:)*nmin, res)
    plot4(4) = gsn_csm_contour(wks, radv_6h(0:65,:)*nmin, res)
    plot4(5) = gsn_csm_contour(wks, vadv_6h(0:65,:)*nmin, res)
    plot4(6) = gsn_csm_contour(wks, adv_6h(0:65,:)*nmin, res)

  ;overlay(plot9(3), ne1)
  ;overlay(plot9(4), ne2)

  gres = True
  gsn_panel(wks, plot4, (/4,2/), gres)


end


