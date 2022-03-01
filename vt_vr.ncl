
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;************************************************
begin

  nn = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518","6_00","6_06","6_12","6_18"/)

  nn1 = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18","6_00","6_06","6_12","6_18"/)

  din = dimsizes(nn)

do in = 1, din-1, 1 

  au = addfile("sim_lev100/wind/u_0"+nn1(in)+".nc", "r")
  av = addfile("sim_lev100/wind/v_0"+nn1(in)+".nc", "r")
  at = addfile("sim_lev100/theta/theta0"+nn(in)+".nc", "r")

  az = addfile("sim_lev100/height/z0"+nn(in)+".nc", "r")
  
  ua = au->ua
  va = av->va
  ta = at->th
  
  z1 = az->z
  ;printVarSummary(z_out)

  print(in)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  rms = dimsizes(ua)
  ntimes = rms(0)          ; number of times in the file

  nx = 420
  ny = 420
 
  ;mdims = new((/ntimes,nx,ny/), integer)
  ;nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

  imin = 210
  jmin = 210

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200  ;;; 200 * 2 = 400 Km
  nz = 100   ; Sigma levels
  r = fspan(0.0,400.0,nr)
  ;print(r)
  r@units = "km"
  ;ro@units = "km"

;;-----------------------------------------------------------------------
  
  hei = fspan(100, 27500, 100)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ;fs     = systemfunc("ls ./wrfout_d03*")
   ;nfs    = dimsizes(fs)
   
   ;ist    = 0
   ;ied    = 168 ;*6
   
   ;ntimes = ied - ist+1
;   ntimes = ntimes/6
;----------------------values set by user---------------------------
    sumlen   = 200 ; the total circul of interpolate
    pi       = 3.14159265
    nlevs    = 100
    ;h        = new((/21/),float)

    Vt_lev  = new((/ntimes,nz,sumlen,360/),float)
    Vr_lev  = new((/ntimes,nz,sumlen,360/),float)
    t_lev  = new((/ntimes,nz,sumlen,360/),float)

do ih = 0 , 90

   ;h(ih) = 200*ih
   ;h(0)  = 20.0

    hei = fspan(100, 27500, 100)

    ua_po    = new((/ntimes,sumlen,360/),float)  ;creat final out put arry
    va_po    = new((/ntimes,sumlen,360/),float)  ;creat final out put arry 
    ta_po    = new((/ntimes,sumlen,360/),float)
    
    xloc = new((/ntimes/),"float")
    yloc = new((/ntimes/),"float")

;******************read TC center file in txt format*******************
   ;xloc = fbinrecread("x0_cen.ieee",0,(/ntimes/),"float")
   ;yloc = fbinrecread("y0_cen.ieee",0,(/ntimes/),"float")

    xloc = 210
    yloc = 210
    
    ;print(xloc)
    Vr_sum     = new((/nlevs/),float)
    Vt_sum     = new((/nlevs/),float)
    tt_sum     = new((/nlevs/),float)

    Vt         = new((/ntimes,sumlen,360/),float)
    Vr         = new((/ntimes,sumlen,360/),float)
    to         = new((/ntimes,sumlen,360/),float)

    do ifs = 0 , ntimes-1, 6                                                                                        
    
        ;a    = addfile(fs(ifs)+".nc","r")
        ;time  = wrf_user_getvar(a,"times",-1)
  
     ;print("Working on time:"+time)
       
        ;z         = wrf_user_getvar(a,"z",0)
        ;modeluu   = wrf_user_getvar(a,"ua",0)
        ;modelvv   = wrf_user_getvar(a,"va",0)
        z         = z1(ifs,:,:,:)
        modeluu   = ua(ifs,:,:,:)
        modelvv   = va(ifs,:,:,:)
        modeltt   = ta(ifs,:,:,:)

;-----------------intrp to height or pressure--------------------

        ;uu  =  wrf_user_intrp3d_z(modeluu,z,"h",h(ih),0.,False)   ;new((/my,nx/),"float")
        ;vv  =  wrf_user_intrp3d_z(modelvv,z,"h",h(ih),0.,False)   ;new((/my,nx/),"float")

        uu = wrf_interp_3d_z(modeluu,z, hei(ih))
        vv = wrf_interp_3d_z(modelvv,z, hei(ih))
        tt = wrf_interp_3d_z(modeltt,z, hei(ih))

        mdims = dimsizes(uu)
        my = mdims(0)      ;lat
        nx = mdims(1)      ;lon

;------------------begin interpolate var to polar coordinates-----------  

        xi        = ispan(0,nx-1,1)  ;xi,yi are grid point
        yi        = ispan(0,my-1,1)  ;in the wrfout file,xi is WE direction yi is SN

        loc_x = xloc(ifs)
        loc_y = yloc(ifs)

        xo        =new(sumlen*360,float)
        yo        =new(sumlen*360,float)
    
        do len =0,sumlen-1,1                                                                                   
             do angel=0,359,1                                                                                     
                xo(len*360+angel) = 1.*loc_x+1.*len*cos(1.*angel/180.*pi)  ;WE
                yo(len*360+angel) = 1.*loc_y+1.*len*sin(1.*angel/180.*pi)  ;SN
            end do                                                                                               
        end do                                                                                                 
  
        xo_2d = onedtond(xo,(/sumlen,360/))
        yo_2d = onedtond(yo,(/sumlen,360/))

        uu_po_level  = new((/sumlen,360/),float)                                                      
        vv_po_level  = new((/sumlen,360/),float)
        tt_po_level  = new((/sumlen,360/),float)
                                                                     
         uu_lev = linint2_points(xi,yi,uu,False,xo,yo,0)
         vv_lev = linint2_points(xi,yi,vv,False,xo,yo,0)
         tt_lev = linint2_points(xi,yi,tt,False,xo,yo,0)
        
         uu_po_level = onedtond(uu_lev,(/sumlen,360/))
         vv_po_level = onedtond(vv_lev,(/sumlen,360/))
         tt_po_level = onedtond(tt_lev,(/sumlen,360/))                                              
                                                                                                                  
;-----------------change dimensions------------------
 
        ua_po(ifs,:,:) = uu_po_level
        va_po(ifs,:,:) = vv_po_level
        ta_po(ifs,:,:) = tt_po_level

    end do
;---------------calculate Vt and Vr---------------

    pp = pi/180.0

    do it = 0 , ntimes-1,6
        ;print("Running...")
     
           do len = 0 , sumlen-1
               do ang = 0,359 
                  Vt(it,len,ang) = va_po(it,len,ang)*cos(1.*ang*pp)-ua_po(it,len,ang)*sin(1.*ang*pp)
                  Vr(it,len,ang) = va_po(it,len,ang)*sin(1.*ang*pp)+ua_po(it,len,ang)*cos(1.*ang*pp)
               end do
           end do  
      
    end do

    Vt_lev(:,ih,:,:) =  Vt(:,:,:)
    Vr_lev(:,ih,:,:) =  Vr(:,:,:)
    t_lev(:,ih,:,:) =  ta_po(:,:,:)

    print("Vt&Vr DONE"+ih)

end do

 Vr_lev!0 = "time"
 Vr_lev!1 = "height"
 Vr_lev!2 = "Radial"
 Vr_lev!3 = "Angles"

 Vr_lev@long_name = "Radial wind"
 Vr_lev@units = "m/s"
 Vr_lev@_FillValue = 9.96921e+36

 Vt_lev!0 = "time"
 Vt_lev!1 = "height"
 Vt_lev!2 = "Radial"
 Vt_lev!3 = "Angles"

 Vt_lev@long_name = "tangential wind"
 Vt_lev@units = "m/s"
 Vt_lev@_FillValue = 9.96921e+36

 t_lev!0 = "time"
 t_lev!1 = "height"
 t_lev!2 = "Radial"
 t_lev!3 = "Angles"

 t_lev@long_name = "theta"
 t_lev@units = "K"
 t_lev@_FillValue = 9.96921e+36

outfilet = addfile("sim_lev100/lin/vr_0"+nn(in)+".nc","c")
outfilet->wrad = Vr_lev(:,0:90,0:199,:)

outfilet = addfile("sim_lev100/lin/vt_0"+nn(in)+".nc","c")            
outfilet->wtan = Vt_lev(:,0:90,0:199,:)

outfilet = addfile("sim_lev100/lin/th_0"+nn(in)+".nc","c")            
outfilet->th = t_lev(:,0:90,0:199,:)


;wks=gsn_open_wks("X11","/user_home/jyyin/dta/sim_lev100/vt_vr")
;vvv = dim_avg_n(Vr_lev(6,40:70,:,:), 2)
;ttt = dim_avg_n(t_lev(6,40:70,:,:), 2)

;res = True
;res@cnFillOn = True
;plot =  gsn_csm_contour(wks,vvv, res)
;plot =  gsn_csm_contour(wks,ttt, res)


print("Output DONE"+in)

delete(Vt_lev)
delete(Vr_lev)
delete(t_lev)

end do


  ;slp       = wrf_user_getvar(a,"slp",0)

  ;slp       = smth9_Wrap(slp,0.5,0.25,False)

 ; flat2d    = slp
 ; flat1d    = ndtooned(flat2d)
 ; dsizes_a  = dimsizes(flat2d)
 ; indices   = ind_resolve(minind(flat1d),dsizes_a)
  ;loc_x     = indices(0,1)
  ;loc_y     = indices(0,0)

        ; avo       = smth9_Wrap(avo,0.5,0.25,False)
        ;=========AVO Center============
       ; xloc1 = 0.0
        ;yloc1 = 0.0
        ;atot = 0.0

       ; do i = loc_y-100 , loc_y+100
       ;    do j = loc_x-100 , loc_x+100
      ;        xloc1 = avo(i,j)*i + xloc1
     ;         yloc1 = avo(i,j)*j + yloc1
    ;          atot = atot + avo(i,j)
   ;        end do
  ;      end do

;      loc_x = tointeger(xloc1/atot)
 ;     loc_y = tointeger(yloc1/atot)
;rint("location: x_"+loc_x+"  y_"+loc_y)

end 
