load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;f = addfile ("/user_home/jyyin/dta/sim3/wrfout_d01_2000-03-03_00:00:00", "r")
    
    files = systemfunc("ls ./sim9_v3/wrfout_d02_*")
    a = addfiles(files, "r")
    ListSetType(a, "cat")

    ;p1     = wrf_user_getvar(f,"p",-1)
    ;t1     = wrf_user_getvar(f,"tk",-1)  ;

    times = wrf_user_getvar(a, "times", -1) ; get all time values on file
    ;p     = wrf_user_getvar(a,"p",-1)  ; calculate pressure across all time, levels
    ;t     = wrf_user_getvar(a,"tk",-1) ;
    ;hz     = wrf_user_getvar(f,"z",1)  ;
    
  dims = dimsizes(times)
  ;lat2d = f->XLAT(0,:,:)
  ;lon2d = f->XLONG(0,:,:)
  ;dimll = dimsizes(lat2d)
  ;nlat  = dimll(0)
  ;mlon  = dimll(1)
  m = ispan(1,dims,1)*6/60.

; Sea Level Pressure
  
  
  ;
  print(dims)

;find typhoon center
; Array for track
  time = new(dims,string)
  ;imin = new(dims,integer)
  ;jmin = new(dims,integer)
  smin = new(dims,float)
  vmax = new(dims,float)
  
  ;cordi = new((/dims,2/),integer)
  ;p_min = new((/dims,68/),float)
  ;slp_min = new(dims,float)
  n=0

  ;printVarSummary(v10)
  ;printVarSummary(p)
  
  do it = 0, dims-1

    slp = wrf_user_getvar(a, "slp", it)
    vv = wrf_user_getvar(a, "V10", it)
    uu = wrf_user_getvar(a, "U10", it)
    v10 = sqrt(uu^2+vv^2)

    slp2d = new((/221,221/),float)
    slp2d = slp(10:230,10:230)
    v2d = new((/221,221/),float)
    v2d = v10(10:230,10:230)
    dd = dimsizes(v2d)

; We need to convert 2-D array to 1-D array to find the minima.
    slp1d    = ndtooned(slp2d)
    smin(it) = min(slp2d)

    v1d    = ndtooned(v2d)
    vmax(it) = max(v2d)

; Convert the index for 1-D array back to the indeces for 2-D array.
    ;minij    = ind_resolve(ind(slp1d.eq.min(slp2d)),dd)
    ;imin(it) = minij(0,0)
    ;jmin(it) = minij(0,1)

    ;cordi(it,0) = imin(it)
    ;cordi(it,1) = jmin(it)

    ;p_min(it,:) = p(it,:,imin(it),jmin(it))
    ;slp_min(it) = slp(it,imin(it),jmin(it))
  

    delete(slp1d)
    delete(slp2d)
    ;delete(minij)

    delete(v1d)
    delete(v2d)


    n = n+1
    print("time = " + times(it)+ "/" + it)
  end do
  
  ;t_c = (/540,640,780,920,1020,1660,1320,1560,2300/)
  ;slp_cho = new(9, float)

  ;do itt = 0, 8
   ; tmid = t_c(itt)
   ; slp_cho(itt) = slp(tmid,120,120)
  ;end do
  ;print(slp_cho)

; Graphics section
  ;printVarSummary(slp)

  wks=gsn_open_wks("pdf","/user_home/jyyin/dta/sim9_v3/slp-V10-6d") 
  gsn_define_colormap(wks,"MPL_BuGn")  ; Change color map.

  plots = new(2,graphic)
  res                     = True
  gres                    = True
  res@gsnDraw            = False                   ; don't draw
  res@gsnFrame           = False                   ; don't advance frame
  ;res@cnFillOn            = True
  ;res@cnLinesOn           = False
  ;res@cnLineLabelsOn      = False
  ;res@cnLineThicknesses   = 1.5

  ;res@tmXBMode = "Explicit"
  ;res@tmXBValues  = (/0,600,1200,1800,2400,2880/)
  ;res@tmXBLabels   =(/0, 30,  60,  90, 120, 144/)
  
; resources for "left" variable
  resL                        = True 
  resL@xyLineThicknesses      = 2.5                  ; thicker line
  resL@tiYAxisString =  "Sea Level Pressure (Pa)"
  resL@tiXAxisString =  "Time (h)" ; axis string

; resources for "right" variable
  resR                        = True                      
  resR@xyLineThicknesses      = 2.5                   ; thicker line
  resR@tiYAxisString = "Max Wind Speed (m/s)" ; axis string

  plot = gsn_csm_xy2(wks,m,smin,vmax,resL,resR)
  
  plots(0) = gsn_csm_xy(wks,m,smin,res)
  plots(1) = gsn_csm_xy(wks,m,vmax,res)


  gres@gsMarkerIndex = 0
  gres@gsMarkerSizeF = 0.015
  gres@gsMarkerColor = "navy"                 ; color chosen
  gres@gsMarkerThicknessF = 3
  
  gres = True
  
  ;plot3 = gsn_add_polymarker( wks,plot(1), t_c, slp_cho, gres)
  
  gres@gsnCenterString = "Sea Level Pressure(Pa) ~C~ Max Wind Speed(m/s)" 
  gsn_panel(wks, plots, (/1,2/), gres)

  ;asciiwrite("sim9_v3/slp_min.txt",smin)
  asciiwrite("sim9_v3/wnd_max.txt",vmax)

end