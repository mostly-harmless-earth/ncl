    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   
         
begin    


  a = addfile("/user_home/jyyin/dta/sim_lev100/angle/vt_azi.nc.nc","r")
  tangential = a->wtan
   
  b = addfile("/user_home/jyyin/dta/sim_lev100/angle/vr_azi.nc.nc","r")
  radial = b->wrad
  
  c = addfile("/user_home/jyyin/dta/sim_lev100/angle/azi_vertical.nc","r")
  wwnd = c->ww

  a_v = addfile("sim_lev100/bud/adv_v_azi.nc","r")
  t_adv_v = a_v->t_adv_v

  a_h = addfile("sim_lev100/bud/adv_h_azi.nc","r")
  t_adv_h = a_h->t_adv_h

  d = addfile("/user_home/jyyin/dta/sim_lev100/bud/adv_v.nc","r")
  advh = d->ww



























    !=====================================================
    ! RADVM = - avg(vr)*d(adv(theta))/dr
    ! RADVE = - d(avg(vr'*theta'))/dr - avg(vr'*theta')/r