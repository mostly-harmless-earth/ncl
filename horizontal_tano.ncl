load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  f = addfile("/user_home/jyyin/dta/sim5/wrfout_d02_2000-05-05_00:00:00","r")
  files = systemfunc("ls ./sim5/wrfout_d02_*")
      
  a = addfiles(files, "r")
  ListSetType(a, "cat")

  fout = addfile("/user_home/jyyin/dta/sim5/wrfout_d01_2000-05-05_00:00:00","r")
  filesout = systemfunc("ls ./sim5/wrfout_d01_*")
      
  aout = addfiles(filesout, "r")
  ListSetType(aout, "cat")
         
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  times  = wrf_user_getvar(a,"times",-1)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
 
  mdims = new((/2880,68,240,240/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

  nz = 68  ; Sigma levels
  hei = fspan(500, 26500, 68)
  
  t_ano = new((/ntimes,nz,240,240/), float)

  wks = gsn_open_wks("pdf","sim5/horizontal-t-anomaly")
  gsn_define_colormap(wks, "MPL_coolwarm")

do it = 61,ntimes-1,60
  
  tb = wrf_user_getvar(a, "tk", it)
  z = wrf_user_getvar(a, "z", it)
  tb_out   = wrf_user_getvar(aout, "tk", it)
  z_out   = wrf_user_getvar(aout, "z", it)
  
  t = tb
  t_out = tb_out

  do iz = 0, nz-1
    t(iz,:,:) = wrf_interp_3d_z(tb, z, hei(iz))
    t_out(iz,:,:) = wrf_interp_3d_z(tb_out, z_out, hei(iz))  
  end do

  t_avg1 = dim_avg_n(t_out,2)
  t_avg = dim_avg_n(t_avg1,1)

do lev = 0,nz-1
  do i = 0,239
    do j = 0, 239

      t_ano(it,lev,i,j) = t(lev,i,j)-t_avg(lev); write loop content
    
    end do
  end do
end do


  res = True
  res@cnFillOn = True

  res@tiMainString = "time = "+it*3/60+ " h"

  res@cnLevels     = (/ -2,-1.5, -1,-0.5, 0, 0.5,1.5, 3, 5,  7,  9, 11, 13/)   ; set levels
  res@cnFillColors = (/  2,   8, 16,  24, 32, 0, 80,90,93,  96, 108,120,126,129/)  ; set the colors to be used

  plot = gsn_csm_contour(wks, t_ano(it,30,:,:), res)
  
  print("t="+it)

end do
end
