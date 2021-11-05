load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  
  f = addfile("/user_home/jyyin/dta/outputsim5/ta_azi_interp.nc","r")

  t_ano = f->ta
  
  mdims = dimsizes(t_ano)
  ntimes = mdims(0)          ; number of times in the file
  nz = mdims(1)  ; Sigma levels
  nr = mdims(2)

  FirstTime = True
  r = fspan(0.0,700.0,nr)
  hei = fspan(500, 26500, 68)
  r@units = "Km"
  hei@units = "m"
  t_ano&Radial = r
  t_ano&height = hei/1000

  printVarSummary(t_ano)
  
  delta_t = new((/ntimes-3,nz,nr/),"float")
  
  do it = 0, 100
    do iz = 0, nz-1
      do ir = 0, nr-1

        delta_t(it,iz,ir) = t_ano(it+3,iz,ir)-t_ano(it,iz,ir)
        
      end do
    end do
    print("Working on time: " + it )
  end do


  wks = gsn_open_wks("pdf","sim5/dt_9min")
  gsn_define_colormap(wks, "MPL_coolwarm")
  
  delta_t!1 = "height"
  delta_t!2 = "Radial"
 
  delta_t&height= hei/1000
  delta_t&Radial = r
  
  plot = new(6, "graphic")

  do kt = 0, 5

    ttt = (/1,3,5,7,9,11/)
    it = ttt(kt)

    res = True
    res@gsnFrame = False
    res@gsnDraw  = False

    res@gsnLeftString  = "temperature change in 9min"
    res@gsnRightString = "T = "+ it*3 +" min"
    res@cnFillOn = True
    res@cnLinesOn = True
    res@cnLineThicknessF  = 1.0
    res@gsnContourNegLineDashPattern  = 11
    ;res@cnLevelSelectionMode = "ManualLevels"
    ;res@cnLevelSpacingF  = 0.3

    ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
    ;res@cnLevels     = (/-1,-0.8,-0.6,-0.4,-0.2,-0.05,0.05,0.2,0.4,0.6,0.8,1/)   ; set levels
    ;res@cnFillColors = (/ 2,   8,  16,  26,  32,   40,   0, 75, 83, 95,112,120,129/)  ; set the colors to be used

    res@cnLineLabelsOn    = True
    res@cnLineLabelBackgroundColor = -1
    res@lbLabelBarOn        = False           ; turn off individual cb's

  plot(kt)= gsn_csm_contour(wks, delta_t(it,0:42,0:80), res)
  end do

  mres = True
  mres@gsnPanelLabelBar    = True                ; add common colorbar
  gsn_panel(wks, plot(:), (/2,3/), mres)

;outfilera = addfile("output/delta_temp.nc","c")
;outfilera->dt = delta_t

end
  