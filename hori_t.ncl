load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
external CAL "/user_home/jyyin/dta/radheight_fix.so"                

begin    

; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  ;a = addfile("/user_home/jyyin/dta/wrfout_d02_2000-04-04_00:00:00","r")
  ;a1 = addfile("/user_home/jyyin/dta/wrfout_d01_2000-04-04_00:00:00","r")

  nn = (/"100","106","112","118","200","206","212","218",\
          "300","306","312","318","400","406","412","418",\
          "500","506","512","518"/)

  nn1 = (/"1_00","1_06","1_12","1_18","2_00","2_06","2_12","2_18",\
          "3_00","3_06","3_12","3_18","4_00","4_06","4_12","4_18",\
          "5_00","5_06","5_12","5_18"/)


  din = dimsizes(nn)

do in = 0, din-1, 1 

  at = addfile("sim_lev100/theta/theta0"+nn(in)+".nc", "r")

  au = addfile("sim_lev100/wind/u_0"+nn1(in)+".nc", "r")
  av = addfile("sim_lev100/wind/v_0"+nn1(in)+".nc", "r")
  aw = addfile("sim_lev100/wind/w_0"+nn1(in)+".nc", "r")
  
  az = addfile("sim_lev100/height/z0"+nn(in)+".nc", "r")
  
  outfilet = addfile("sim_lev100/ev/envi0"+nn(in)+".nc","r")
  t_avg = outfilet->te  

  printVarSummary(t_avg)

  ub = au->ua
  vb = av->va
  wb = aw->wa

  tb = at->th
  ;printVarSummary(tb_out)
  z = az->z
  ;printVarSummary(z_out)

  print("doc = " + nn1(in))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  FirstTime = True
  rms = dimsizes(tb)
  ntimes = rms(0)          ; number of times in the file

  nx = rms(2)
  ny = rms(3)
 
  mdims = new((/ntimes,nx,ny/), integer)
  nd = dimsizes(mdims)
  FirstTime = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;----------------------------- Find the TC Center ----------------------

  imin = 210
  jmin = 210

;;;;;;;;;;;;;;;;;;;;; Generate the pole coordinate ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  nr = 200  ;;; 200 * 2 = 400 Km
  nz = 100   ; Sigma levels
  r = fspan(0.0,400.0,nr)
  r@units = "km"

;;-----------------------------------------------------------------------
 
 t_ano    = new((/ntimes,nz,nx,ny/),"float")
 
 uu = t_ano
 vv = t_ano
 ww = t_ano

  do it = 0 , ntimes-1 , 6; TIME LOOP
   
    print("Working on time: " + it )

;-------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; vertical interp & decoupled mass;;;;;;;;;;;;;;;;;;;;;;;

    hei = fspan(500, 27500, 100)
    t       = new((/nz,nx,ny/), "float")

    do iz = 0, nz-1

      t(iz,:,:)       = wrf_interp_3d_z(tb(it,:,:,:), z(it,:,:,:), hei(iz))
      uu(it,iz,:,:)      = wrf_interp_3d_z(ub(it,:,:,:), z(it,:,:,:), hei(iz))
      vv(it,iz,:,:)      = wrf_interp_3d_z(vb(it,:,:,:), z(it,:,:,:), hei(iz))
      ww(it,iz,:,:)      = wrf_interp_3d_z(wb(it,:,:,:), z(it,:,:,:), hei(iz))

    end do

do lev = 0,nz-1
  do i = 0,ny-1
    do j = 0,ny-1

        t_ano(it,lev,i,j) = t(lev,i,j)-t_avg(it,lev)
    
    end do
  end do
end do

delete(t)

end do
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; output Section ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
 t_ano!0 = "time"
 t_ano!1 = "height"
 t_ano!2 = "Radial"
 t_ano@long_name = "temperature anomaly"
 t_ano@units = "K"
 t_ano@_FillValue = 9.96921e+36

    copy_VarMeta(t_ano, uu)
    copy_VarMeta(t_ano, vv)
    copy_VarMeta(t_ano, ww)

outfilet = addfile("sim_lev100/hori/hori_tano"+nn(in)+".nc","c")
outfilet->ta = t_ano(:,0:75,:,:)

outfilet = addfile("sim_lev100/hori/hori_u"+nn(in)+".nc","c")
outfilet->ua = uu(:,0:75,:,:)

outfilet = addfile("sim_lev100/hori/hori_v"+nn(in)+".nc","c")
outfilet->va = vv(:,0:75,:,:)

outfilet = addfile("sim_lev100/hori/hori_w"+nn(in)+".nc","c")
outfilet->wa = ww(:,0:75,:,:)

print("finish output : " + it )
    
    delete(t_ano)
    delete(t_avg)

    delete(uu)
    delete(vv)
    delete(ww)
    
    delete(ub)
    delete(vb)
    delete(wb)
    
    delete(at)
    delete(az)

end do

end