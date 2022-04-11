load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here

    ;files = systemfunc("ls ./sim8/wrfout_d02_*")
    ;a = addfile("/share/home/kkchu/yin/sim_lev100/wrfout_d03_*","r")

        

nn = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18","6_00","6_06","6_12","6_18","7_00","7_06","7_12","7_18",\
          "8_00","8_06","8_12","8_18","9_00","9_06","9_12","9_18","10_00","10_06","10_12","10_18"/)

nn1 = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18","600","606","612","618","700","706","712","718",\
          "8_00","8_06","8_12","8_18","9_00","9_06","9_12","9_18","10_00","10_06","10_12","10_18"/)
dim = dimsizes(nn) 

do in = 20, 27,1

    a = addfile("/ldata6/jyyin/sim_lev100/wrfout_d03_2000-02-0"+nn(in)+":00:00","r")  
    print("time = " + nn(in))
    
    ;files = systemfunc("ls ./sim_lev100/wrfout_d03_2000-02-01_2000-02-01_00:00:00")
    ;a = addfiles(files, "r")
    ;ListSetType(a, "cat")

;--Read variables

    ;times = wrf_user_getvar(a,"times",-1)  ; get all time values on file
    ;tb    =   ; calculate pressure across all time, levels
    ;t_pbl   = wrf_user_getvar(a, "te_temf", -1);
    ;p   = wrf_user_getvar(a, "p", 2)
    ;qv = wrf_user_getvar(a, "QVAPOR", -1)
    
    ;th = wrf_user_getvar(a,"th",-1)
    ;z = wrf_user_getvar(a, "z", -1)
    ;ua = wrf_user_getvar(a,"ua",-1)
    ;va = wrf_user_getvar(a,"va", -1)
    ;wa = wrf_user_getvar(a,"wa",-1)
    ;hei = wrf_user_getvar(a, "height", -1)

    ;slp = wrf_user_getvar(a, "slp", -1)
    ;printVarSummary(th)
    ;vv = wrf_user_getvar(a, "V10", -1)
    ;uu = wrf_user_getvar(a, "U10", -1)
    ;wnd = sqrt(uu^2+vv^2)

    tb_adv_h = wrf_user_getvar(a, "T_TEND_ADV_H", -1)
    tb_adv_v = wrf_user_getvar(a, "T_TEND_ADV_V", -1)

    tb_diff1  = wrf_user_getvar(a, "T_TEND_DIFF", -1)
    tb_diff3  = wrf_user_getvar(a, "T_TEND_DIFF3", -1)

    tb_cu    = wrf_user_getvar(a, "RTHCUTEN", -1)
    tb_ra    = wrf_user_getvar(a, "RTHRATEN", -1)
    tb_pbl   = wrf_user_getvar(a, "RTHBLTEN", -1)
    tb_heat  = wrf_user_getvar(a, "H_DIABATIC", -1)
    
    mu = wrf_user_getvar(a, "MU", -1)
    mub = wrf_user_getvar(a, "MUB", -1)
    mut = mu+mub
    
    ;dbz  = a->refl_10cm

    ;outfilet = addfile("sim_lev100/slp/slp0"+nn(in)+".nc","c")
    ;outfilet->slp = slp
    
    ;outfilet = addfile("sim_lev100/wind10/wnd0"+nn(in)+".nc","c")
    ;outfilet->wnd = wnd

    ;outfilet = addfile("sim_lev100/water/qv"+nn(in)+".nc","c")
    ;outfilet->qv = qv

    ;p = wrf_user_getvar(a,"p",-1)
    ;printVarSummary(p)

    ;tk = wrf_user_getvar(a,"tk",-1)
    ;printVarSummary(tk)

    ;outfilet = addfile("sim_lev100/d02/d02_theta/theta0"+nn1(in)+".nc","c")
    ;outfilet->th = th
    
    ;outfilet = addfile("sim_lev100/tk/tink"+nn(in)+".nc","c")
    ;outfilet->tk = tk

    ;outfilet = addfile("sim_lev100/d02/d02_height/z0"+nn1(in)+".nc","c")
    ;outfilet->z = z
    
    ;outfilet = addfile("sim_lev100/wind/u_0"+nn(in)+".nc","c")
    ;outfilet->ua = ua
    
    ;outfilet = addfile("sim_lev100/wind/v_0"+nn(in)+".nc","c")
    ;outfilet->va = va
    
    ;outfilet = addfile("sim_lev100/wind/w_0"+nn(in)+".nc","c")
    ;outfilet->wa = wa

    outfilet = addfile("sim_lev100/budget_or/adv_h_0"+nn(in)+".nc","c")
    outfilet->T_TEND_ADV_H = tb_adv_h

    outfilet = addfile("sim_lev100/budget_or/adv_v_0"+nn(in)+".nc","c")
    outfilet->T_TEND_ADV_V = tb_adv_v
    
    outfilet = addfile("sim_lev100/budget_or/diff_0"+nn(in)+".nc","c")
    outfilet->T_TEND_DIFF = tb_diff1

    outfilet = addfile("sim_lev100/budget_or/diff3_0"+nn(in)+".nc","c")
    outfilet->T_TEND_DIFF3 = tb_diff3

    outfilet = addfile("sim_lev100/budget_or/pbl_0"+nn(in)+".nc","c")
    outfilet->RTHBLTEN = tb_pbl
    
    outfilet = addfile("sim_lev100/budget_or/heat_0"+nn(in)+".nc","c")
    outfilet->H_DIABATIC = tb_heat

    outfilet = addfile("sim_lev100/budget_or/mut_0"+nn(in)+".nc","c")
    outfilet->MUT = mut

    ;outfilet = addfile("sim_lev100/budget_or/cu_0"+nn(in)+".nc","c")
    ;outfilet->RTHCUTEN = tb_cu

    ;outfilet = addfile("sim_lev100/wind/dbz_0"+nn(in)+".nc","c")
    ;outfilet->dbz = dbz

    delete(a)

end do

   ; ro = fspan(0.0, 700, 200)
   ; print(ro)

    ;outfilet = addfile("sim_lev100/slp/slp0518.nc","c")
    ;outfilet->slp = slp

    ;outfilet = addfile("sim_lev100/wind10/wnd0518.nc","c")
    ;outfilet->wnd = wnd


    ;printVarSummary(t_ano)
    ;hei = fspan(500, 27500, 68)
    ;print(hei)
    ;r = fspan(0.0,700.0,150)
    ;print(r)
    ;printVarSummary(th)
    
    ;printVarSummary(mu)
    ;printVarSummary(mub)
    ;u_adv_h = a->U_TEND_ADV_V
    ;u_adv_v = a->U_TEND_ADV_H
    ;u_diff = a->U_TEND_DIFF

    ;printVarSummary(u_adv_h)
    ;printVarSummary(u_adv_v)
    ;printVarSummary(u_diff)

    ;t_adv_h1 = a->T_TEND_ADV_H1
    ;t_adv_h2 = a->T_TEND_ADV_H2
    ;t_adv_h = a->T_TEND_ADV_H
    ;t_adv_v = a->T_TEND_ADV_V

    ;printVarSummary(z)
    ;printVarSummary(hei)
    ;print(times)

    ;differ1 = t_adv_h - t_adv_h1
    ;differ2 = t_adv_h - t_adv_h2
    ;differ3 = t_adv - t_adv_h - t_adv_v

   ; rthshten = a->RTHSHTEN
    ;rthcuten = a->RTHCUTEN
   ; rthraten = a->RTHRATEN
    ;rthblten = a->RTHBLTEN

   ; hei = fspan(500, 26500, 68)
    ;print(hei)
    
    ;printVarSummary(rthshten)
    ;printVarSummary(rthcuten)
   ; printVarSummary(rthraten)
    ;printVarSummary(rthblten)

    ;gmp=(((PH(k)+PH(k+1)) / 2) + ((PHB(k)+(PHB(k+1)) / 2) / 9.81 – HGT 
    ;gmp=(PH+PHB)/9.81-HGT  

    ;p = new((/217,68,240,240/),"float")
    ;do i = 0, 216
       ;print("Working on time: " + i)
       ;p(i,:,:,:)   =wrf_user_getvar(f2, "p", i) 
    ;end do
    
    ;phb  =wrf_user_getvar(f2, "PHB", -1)
    ;hgt  =wrf_user_getvar(f2, "height", -1)
    
    ;lat = wrf_user_getvar(f,"lat",0)
    ;lon = wrf_user_getvar(f,"lon",0)
    
    ;t1     = wrf_user_getvar(f2,"tk",-1)  ;
    ;u     = wrf_user_getvar(f2,"U",-1)  ; 
    ;v     = wrf_user_getvar(f2,"V",-1)  ;  
    ;hz     = wrf_user_getvar(f2,"z",-1)  ;

    ;z1 = z(:,120,120)/1000
    ;z2 = z(:,33,33)/1000

    ;c2 = p(1,:,120,120)/100
    ;c3 = hgt(0,:,5,5)
    ;c4 = p(1,:,25,25)/100
    ;print(th_t_tend)
    ;print(c2)
    ;print(c3)
    ;print(c4)

    ;zzz1 = z(2,:,10,10)
    ;zzz2 = z(2,:,150,150)
    ;zzz3 = z(2,:,150,150)

    ;print(zzz1)
    ;print(zzz2)
    ;print(zzz3)

; Look at your data
    ;printVarSummary(p)
    ;printVarSummary(lon)
    
    ;xlon = lon(0,:)
    ;xlat = lon(1,:)
    
    ;print(xlon)
    ;print(xlat)
    
    ;printVarSummary(ph)
    ;printVarSummary(phb)
    ;printVarSummary(hgt)

    ;printMinMax(p, 0)
    ;printMinMax(pp, 0)

    ;wks = gsn_open_wks("pdf","sim_lev90/height")
    ;gsn_define_colormap(wks, "MPL_coolwarm")

    ;res = True
    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)
    ;res@cnFillOn = True

    ;do it = 0, 119, 10

    ;plot = gsn_csm_contour(wks, z(it,:,10,:)-z(it,:,100,:), res)
    ;plot = gsn_csm_contour(wks, z(it,:,100,:)-hei(it,:,100,:), res)
    ;plot = gsn_csm_contour(wks, hei(it,:,120,:), res)
    
    ;end do

end
