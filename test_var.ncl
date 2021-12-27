load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here

    ;files = systemfunc("ls ./sim8/wrfout_d02_*")
    a = addfile("/user_home/jyyin/dta/sim9_v3/wrfout_d02_2000-09-01_12:00:00.nc","r")
    ;ano_h = addfile("sim9/tano_d1_00.nc","r")
    
    
    ;files = systemfunc("ls ./sim9/heat*")
    ;a_heat = addfiles(files, "r")
    ;ListSetType(a_heat, "cat")
    ;t_heat = a_heat[:]->t_heat
    ;t_ano = ano_h->ta
;--Read variables

    ;times = wrf_user_getvar(f2,"times",-1)  ; get all time values on file
    ;tb    =   ; calculate pressure across all time, levels
    ;t_pbl   = wrf_user_getvar(a, "te_temf", -1);
    ;p   = wrf_user_getvar(a, "p", 2)
    th = wrf_user_getvar(a,"th",-1)
    z = wrf_user_getvar(a, "z", -1)
    hei = wrf_user_getvar(a, "height", -1)

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

    printVarSummary(z)
    printVarSummary(hei)

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

    zzz1 = z(50,:,10,10)
    zzz2 = z(50,:,100,100)
    zzz3 = z(50,:,120,120)

    print(zzz1)
    print(zzz2)
    print(zzz3)

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



    wks = gsn_open_wks("pdf","sim9_v3/height")
    gsn_define_colormap(wks, "MPL_coolwarm")

    res = True
    ;res@tmXBMode    = "Explicit"
    ;res@tmXBValues  = (/0, 22, 43, 64, 85,107,128/)
    ;res@tmXBLabels  = (/0,100,200,300,400,500,600/)

    ;res@tmYLMode    = "Explicit"
    ;res@tmYLValues  = (/0, 11,24,36,40/)
    ;res@tmYLLabels  = (/0.5,5,10,15,17/)
    ;res@cnFillOn = True

    do it = 0, 119, 10

    plot = gsn_csm_contour(wks, z(it,:,10,:)-z(it,:,100,:), res)
    plot = gsn_csm_contour(wks, z(it,:,100,:)-hei(it,:,100,:), res)
    plot = gsn_csm_contour(wks, hei(it,:,120,:), res)
    
    end do

end