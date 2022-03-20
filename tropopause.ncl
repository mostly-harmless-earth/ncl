load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

  a = addfile("sim_lev100/tk/tk_azi.nc","r")
  ;f = addfile ("/user_home/jyyin/dta/sim3/wrfout_d01_2000-03-03_00:00:00", "r")

    ;p1     = wrf_user_getvar(f,"p",-1)
    ;t1     = wrf_user_getvar(f,"tk",-1)  ;

    ;times = wrf_user_getvar(a, "times", -1) ; get all time values on file
    ;p     = wrf_user_getvar(a,"p",-1)  ; calculate pressure across all time, levels
    ;t     = wrf_user_getvar(a,"tk",-1) ;
    ;hz     = wrf_user_getvar(f,"z",1)  ;
    
  tk = a->tk
  dims = dimsizes(tk)
  m = ispan(1,dims(0),1)*10/60.

  hei = fspan(500, 27500, 100)/1000

  print(dims)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   cold point    ;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;alti = new((/dims(0),dims(2)/),float)
  ;printVarSummary(alti)
  ;n=0

  ;do it = 0, dims(0)-1,6
    ;do ir = 0,dims(2)-1

      ;tk_min = minind(tk(it,:,ir))
      ;alti(it,ir)= tk_min

      ;n = n+1
      ;print("height = " + tk_min)
    ;end do
  ;end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   lapse rate   ;;;;;;;;;;;;;;;;;;;;;;;;;;;

  alti = new((/dims(0),dims(2)/),float)
  dtdz = new(dims,float)
  printVarSummary(alti)
  printVarSummary(dtdz)
  n=0

  do ih = 0,dims(1)-2
    do ir = 0,dims(2)-1

      h = hei(ih+1)-hei(ih)
      dtdz(:,ih,ir) = (tk(:,ih+1,ir)-tk(:,ih,ir))/h

    end do
  end do

 dtdz!0 = "time"
 dtdz!1 = "height"
 dtdz!2 = "Radial"
 dtdz@long_name = "lapse rate"
 dtdz@units = "k/km"
 dtdz@_FillValue = 9.96921e+36


  ;outfilet = addfile("sim_lev100/tk/dtdz.nc","c")
  ;outfilet->dtdz = dtdz

  dtdz = -dtdz

   do it = 0,dims(0)-1,6
     do ir = 0,dims(2)-1
       do ih = 35,(dims(1)-20)

        if (dtdz(it,ih,ir).le.2) then

          lap = dim_avg_n(dtdz(it,ih:ih+6,ir), 0)

          if (lap.le.2) then
            
            alti(it,ir)= ih
            break
          
          end if
              
        end if

      end do
    end do
  end do

  wks=gsn_open_wks("pdf","sim_lev100/trop") 
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

  
  plots(0) = gsn_csm_y(wks,alti(36,:),res)
  plots(1) = gsn_csm_y(wks,alti(96,:),res)


  gres@gsMarkerIndex = 0
  gres@gsMarkerSizeF = 0.015
  gres@gsMarkerColor = "navy"                 ; color chosen
  gres@gsMarkerThicknessF = 3
  
  gres = True
  
  ;plot3 = gsn_add_polymarker( wks,plot(1), t_c, slp_cho, gres)
  
  gres@gsnCenterString = "tropopause" 
  gsn_panel(wks, plots, (/1,2/), gres)

 alti!0 = "time"
 alti!1 = "Radial"
 alti@long_name = "cold point tropopause"
 alti@units = "m/s"
 alti@_FillValue = 9.96921e+36

  outfilet = addfile("sim_lev100/tk/hgtoflapsrate_avg.nc","c")
  outfilet->alti = alti

  asciiwrite("sim_lev100/tropopause_rate.txt",alti)

end