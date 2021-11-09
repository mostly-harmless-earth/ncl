load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;---Open file; substitute your own WRF output file here

    ;files = systemfunc("ls ./sim8/wrfout_d02_*")
    a = addfile("/user_home/jyyin/dta/sim9/wrfout_d02_2000-09-04_12:00:00.nc","r")

    
    ;f = addfiles(files, "r")
    ;ListSetType(f, "cat")
    ;f2 = addfile (, "r")

;--Read variables

    ;times = wrf_user_getvar(f2,"times",-1)  ; get all time values on file
    ;tb    =   ; calculate pressure across all time, levels
    ;t_pbl   = wrf_user_getvar(a, "te_temf", -1);
    ;p   = wrf_user_getvar(a, "p", 2)
    ;th = wrf_user_getvar(f,"th",-1)
    ;t = wrf_user_getvar(f, "T", -1)

    ;printVarSummary(t)
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
    td = a->H_DIABATIC

    printVarSummary(td)
    ;printVarSummary(t_adv_v2)

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

    wks = gsn_open_wks("pdf","sim9/test-adv-9")
    gsn_define_colormap(wks, "MPL_coolwarm")

    res = True
    res@cnFillOn = True
    plot = gsn_csm_contour(wks, td(30,:,120,:), res)
    ;plot = gsn_csm_contour(wks, differ2(30,:,120,:), res)
    ;plot = gsn_csm_contour(wks, differ3(30,:,120,:), res)
    ;plot = gsn_csm_contour(wks, t_adv_v(30,:,120,:), res)

end