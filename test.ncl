;***********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;***********************************************************
;load "/home/wt/WORKING/DATA/scripts/function.ncl"
;***********************************************************
begin
;***********************************************************

  rdata  = "gpcp"

  yrStrt = 1997
  yrLast = 2016

  latS   =  -10  
  latL   =   10   

  lonS   =    0  
  lonL   =  360  

  levS   = 1000
  levL   =  100









;***************************************************************************************
;read data
;***************************************************************************************
 ; gpcp, spcam, cam
;***************************************************************************************
; gpcp

  if(rdata.eq."gpcp")then

  dir    =  "/home/wt/WORKING/DATA/ERA-interim"
  xName  =  (/"uwnd", "vwnd", "omega", "shum", "air"/)
  xFile  =  (/"/u/uwnd.interim.*.nc",        \
              "/v/vwnd.interim.*.nc",        \
              "/omega/omega.interim.*.nc",   \
              "/shum/shum.interim.*.nc",     \
              "/air/air.interim.*.nc"/)
  
  end if


;***************************************************************************************
;spcam
  if(rdata.eq."spcam")then

  dir          =  "/home/yangsong3/wt/SPCAM-TEST-2016/SP_AMIP"
  xName        =  (/"uwnd", "vwnd", "omega", "shum", "air"/)
  xFile        =  (/"/u/uwnd.interim.*.nc",      \
                    "/v/vwnd.interim.*.nc",      \
                    "/omega/omega.interim.*.nc", \
                    "/shum/shum.interim.*.nc",   \
                    "/air/air.interim.*.nc"/)

  end if


;***************************************************************************************
;cam
  if(rdata.eq."cam")then
  pcName       =  "PRECC"
  plName       =  "PRECL"
  dirp         = "/home/yangsong3/wt/SPCAM-TEST-2016/F_AMIP/"
  filpc        = systemfunc("ls "+dirp+"F_AMIP.cam.h1.YEAR.198[1-9].daily.PRECC.nc " + dirp + "F_AMIP.cam.h1.YEAR.199[0-9].daily.PRECC.nc " + dirp + "F_AMIP.cam.h1.YEAR.200[0-5].daily.PRECC.nc ")
  filpl        = systemfunc("ls "+dirp+"F_AMIP.cam.h1.YEAR.198[1-9].daily.PRECL.nc " + dirp + "F_AMIP.cam.h1.YEAR.199[0-9].daily.PRECL.nc " + dirp + "F_AMIP.cam.h1.YEAR.200[0-5].daily.PRECL.nc ")
  setfileoption("nc","SuppressClose",False) ; close too many files 
  fc           = addfiles(filpc, "r")   
  fl           = addfiles(filpl, "r")   
  ListSetType(fc,"cat")
  ListSetType(fl,"cat")

  date_p = cd_calendar(fc[:]->time, -2)   ; entire file
  iStrt  = ind(date_p.eq.twStrt)      ; desired dates
  iLast  = ind(date_p.eq.twLast)
  delete(date_p) 

  Pc       =  fc[:]->$pcName$(iStrt:iLast,{latS_globe:latN_globe},:) 
  Pl       =  fl[:]->$plName$(iStrt:iLast,{latS_globe:latN_globe},:) 
  P        =  Pc
  P        =  (Pc+Pl)*86400*1000
  delete(Pc)
  delete(Pl)
  end if


;***************************************************************************************
  fu    = addfile(diru+filu, "r")
  fv    = addfile(diru+filv, "r")

  date_u  = cd_calendar(fu->time, -1)
  iStrt  := ind(date_u.eq.twStrt/100)      ; desired dates
  iLast  := ind(date_u.eq.twLast/100)
  delete(date_u)

    if (getfilevartypes(fu,uName) .eq. "short") then
      U  = short2flt( fu->$uName$(iStrt:iLast,{850},{latS_globe:latN_globe},:))
      V  = short2flt( fv->$vName$(iStrt:iLast,{850},{latS_globe:latN_globe},:)) 
    else
      U  = fu->$uName$(iStrt:iLast,{850},{latS_globe:latN_globe},:)
      V  = fv->$vName$(iStrt:iLast,{850},{latS_globe:latN_globe},:) 
    end if



;****************************************************************
; read the var
;****************************************************************
 
 do i = 0, 4

   filed       = systemfunc("ls "+dir(i)+xFile(i))
   setfileoption("nc","SuppressClose",False) ; close too many files 
   f           = addfiles(filed, "r")
   ListSetType(fc,"cat")

   date   = cd_calendar(f[:]->time, -2)
   iStrt  = ind(date.eq.twStrt)      ; desired dates
   iLast  = ind(date.eq.twLast)
   delete(date) 

    if (getfilevartypes(fu,uName) .eq. "short") then
      X  = short2flt( f->$xName(i)$(iStrt:iLast,:,:,:)) 
    else
      X  = f->$xName(i)$(iStrt:iLast,:,:,:)
    end if

   X!0 = "time"
   X!1 = "lev"
   X!2 = "lat"
   X!3 = "lon"

 end do



;****************************************************************
; read the time
;****************************************************************

  ftime = systemfunc("ls "+dir+"/u/uwnd.interim.*.nc ")
  ft    = addfiles(ftime,"r")
  ListSetType(ft, "cat")

  TIME   = ft[:]->time                   ; days since 0000-09-01 00:00:00
  YYYY   = cd_calendar(TIME,-1)/100                 ; entire file
  iYYYY  = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)
  time   = TIME(iYYYY)
  ntime  = dimsizes(time)

  cod   := ft[0]->uwnd (:,{levS:levL},{latS:latL},{lonS:lonL})

  dcod   = dimsizes(cod)
  nlev   = dcod(1)
  nlat   = dcod(2)
  nlon   = dcod(3)




  delete([/ftime, ft, TIME, YYYY, cod, dcod/])

  print("Calculated CPU Time " + ( get_cpu_time() ) + " seconds")
 ; printVarSummary(time)
  print(0)

;****************************************************************
; define the var
;****************************************************************

  lonlev_u_all    = new((/ ntime, nlev, nlon /), "float")
  lonlev_w_all    = new((/ ntime, nlev, nlon /), "float")
  lonlev_qu_all   = new((/ ntime, nlev, nlon /), "float")
  lonlev_qv_all   = new((/ ntime, nlev, nlon /), "float")
  lonlev_qw_all   = new((/ ntime, nlev, nlon /), "float")


  latlev_v_all    = new((/ ntime, nlev, nlat /), "float")
  latlev_w_all    = new((/ ntime, nlev, nlat /), "float")
  latlev_qu_all   = new((/ ntime, nlev, nlat /), "float")
  latlev_qv_all   = new((/ ntime, nlev, nlat /), "float")
  latlev_qw_all   = new((/ ntime, nlev, nlat /), "float")

  delete([/ntime, nlev, nlon/])




;****************************************************************
; 
;****************************************************************
itime = 0
do iy = yrStrt, yrLast
  print(iy)

  all_f1 = systemfunc("ls "+dir+      "/u/uwnd.interim."+iy+".nc")
  all_f2 = systemfunc("ls "+dir+      "/v/vwnd.interim."+iy+".nc")
  all_f3 = systemfunc("ls "+dir+ "/omega/omega.interim."+iy+".nc")
  all_f4 = systemfunc("ls "+dir+   "/shum/shum.interim."+iy+".nc")

  setfileoption("nc","SuppressClose",False) ; close too many files 

  f1 = addfiles(all_f1,"r")
  f2 = addfiles(all_f2,"r")
  f3 = addfiles(all_f3,"r")
  f4 = addfiles(all_f4,"r")


  ListSetType(f1, "cat")
  ListSetType(f2, "cat")
  ListSetType(f3, "cat")
  ListSetType(f4, "cat")

 


print("1")
;*******************************************************

  u    := f1[:]->uwnd (:,{levS:levL},{latS:latL},{lonS:lonL})   ; read in example data [2D only here]
  print("21")

  v    := f2[:]->vwnd (:,{levS:levL},{latS:latL},{lonS:lonL})
  print("22")

  w    := f3[:]->omega(:,{levS:levL},{latS:latL},{lonS:lonL})
  print("23")

  sh   := f4[:]->shum (:,{levS:levL},{latS:latL},{lonS:lonL})


 ; delete(iYYYY)

print("2")
;*************  deal with the data     *****************

;  u    = where(abs(u).gt.200,u@_FillValue,u)
;  v    = where(abs(v).gt.200,v@_FillValue,v)




  u!0 = "time"
  u!1 = "lev"
  u!2 = "lat"
  u!3 = "lon"

  v!0 = "time"
  v!1 = "lev"
  v!2 = "lat"
  v!3 = "lon"

  w!0 = "time"
  w!1 = "lev"
  w!2 = "lat"
  w!3 = "lon"

  sh!0 = "time"
  sh!1 = "lev"
  sh!2 = "lat"
  sh!3 = "lon"

  

  ntime   = dimsizes(sh&time)
  ;nyear   = ntime/12
  ny      = dimsizes(sh&lat)
  nx      = dimsizes(sh&lon)
  nz      = dimsizes(sh&lev)

  lat      = sh&lat
  lon      = sh&lon
  reslon   = dble2flt( lon(1)-lon(0) )                    ;resolution for lon. gpcp:1, trmm:0.25
  reslat   = dble2flt( lat(1)-lat(0) )

  delete([/lat, lon/])
 ; printVarSummary(w)
 ; printMinMax(w,True)

print(3)
;**********************************************************
; calculate the div q
;**********************************************************

 div_qu := new(dimsizes(u), "float")
 div_qv := new(dimsizes(v), "float")
 div_qw := new(dimsizes(w), "float")

 copy_VarCoords(u, div_qu)
 copy_VarCoords(v, div_qv)
 copy_VarCoords(w, div_qw)


 qu := sh*u
 qv := sh*v
 qw := sh*w

 delete(sh)
 nlev = w&lev

 div_qu(:,:,:,1:nx-2) = ( qu(:,:,:,2:nx-1) - qu(:,:,:,0:nx-3) )/(111000.*reslon)
 div_qv(:,:,1:ny-2,:) = ( qv(:,:,2:ny-1,:) - qv(:,:,0:ny-3,:) )/(111000.*reslat)
 div_qw(:,1:nz-2,:,:) = ( qw(:,2:nz-1,:,:) - qw(:,0:nz-3,:,:) )   ; /( (nlev(2:nz-1) - nlev(0:nz-3))*100)
 div_qw(:,0,:,:)      = ( qw(:,1,:,:)      - qw(:,0,:,:)      )/( (nlev(1)      - nlev(0)     )*100)
 div_qw(:,nz-1,:,:)   = ( qw(:,nz-1,:,:)   - qw(:,nz-2,:,:)   )/( (nlev(nz-1)   - nlev(nz-2)  )*100)

 do i = 1,nz-2
 div_qw(:,i,:,:)  =  div_qw(:,i,:,:)/( (nlev(i+1)-nlev(i-1))*100 )
 end do

 delete([/qu, qv, qw/])
;printMinMax(div_qu, False)
;printMinMax(div_qv, False)
;printMinMax(div_qw, False)
print(4)
;**********************************************************
; calculate the u v w
;**********************************************************

  wyIO   = lonlev_u&lat({-10:10})  
  wyIO   = cos(0.017459*wyIO)         ; spatial wgt



; lon-lev
lonlev_u  :=  dim_avg_n_Wrap(u      (time|:,lev|:,{lat|-10:10},lon|:), 2)
lonlev_w  :=  dim_avg_n_Wrap(w      (time|:,lev|:,{lat|-10:10},lon|:), 2)
lonlev_qu :=  dim_avg_n_Wrap(div_qu (time|:,lev|:,{lat|-10:10},lon|:), 2)
lonlev_qv :=  dim_avg_n_Wrap(div_qv (time|:,lev|:,{lat|-10:10},lon|:), 2)
lonlev_qw :=  dim_avg_n_Wrap(div_qw (time|:,lev|:,{lat|-10:10},lon|:), 2)



; lat-lev
latlev_v  :=  dim_avg_n_Wrap(v      (time|:,lev|:,lat|:,{lon|100:130}), 3)
latlev_w  :=  dim_avg_n_Wrap(w      (time|:,lev|:,lat|:,{lon|100:130}), 3)
latlev_qu :=  dim_avg_n_Wrap(div_qu (time|:,lev|:,lat|:,{lon|100:130}), 3)
latlev_qv :=  dim_avg_n_Wrap(div_qv (time|:,lev|:,lat|:,{lon|100:130}), 3)
latlev_qw :=  dim_avg_n_Wrap(div_qw (time|:,lev|:,lat|:,{lon|100:130}), 3)

;printVarSummary(w_avg)


delete([/u, v, w, div_qu, div_qv, div_qw/])


print(5)


print("Calculated CPU Time " + ( get_cpu_time() ) + " seconds")
;**********************************************************
; out the data
;**********************************************************

  
  lonlev_u_all(itime:itime+ntime-1,:,:)    = lonlev_u
  lonlev_w_all(itime:itime+ntime-1,:,:)    = lonlev_w
  lonlev_qu_all(itime:itime+ntime-1,:,:)   = lonlev_qu
  lonlev_qv_all(itime:itime+ntime-1,:,:)   = lonlev_qv
  lonlev_qw_all(itime:itime+ntime-1,:,:)   = lonlev_qw


  latlev_v_all(itime:itime+ntime-1,:,:)    = latlev_v
  latlev_w_all(itime:itime+ntime-1,:,:)    = latlev_w
  latlev_qu_all(itime:itime+ntime-1,:,:)   = latlev_qu
  latlev_qv_all(itime:itime+ntime-1,:,:)   = latlev_qv
  latlev_qw_all(itime:itime+ntime-1,:,:)   = latlev_qw

  
  itime = itime+ntime

print(itime+"  "+ntime)






end do
;**********************************************************
;write Netcdf

lonlev_u_all&time = time
lonlev_w_all&time = time
lonlev_qu_all&time = time
lonlev_qv_all&time = time
lonlev_qw_all&time = time

latlev_v_all&time = time
latlev_w_all&time = time
latlev_qu_all&time = time
latlev_qv_all&time = time
latlev_qw_all&time = time



printVarSummary(lonlev_qw_all)

outfile1 = "./medavg.nc"
outfile2 = "./zonavg.nc"


 
; setfileoption("nc","format","netcdf4")
; setfileoption("nc","headerReserveSpace",64000)
; setfileoption("nc","preFill",False)
; setfileoption("nc","defineMode",True)

;Remove the file if it already existed.


 if (isfilepresent(outfile1)) then
        system("rm " + outfile1)
 end if
 if (isfilepresent(outfile2)) then
        system("rm " + outfile2)
 end if


 f0_out = addfile(outfile1,"c")
 f1_out = addfile(outfile2,"c")





 f0_out->uwnd  = lonlev_u_all
 f0_out->omega = lonlev_w_all
 f0_out->qu    = lonlev_qu_all
 f0_out->qv    = lonlev_qv_all
 f0_out->qw    = lonlev_qw_all


 f1_out->vwnd  = latlev_v_all
 f1_out->omega = latlev_w_all
 f1_out->qu    = latlev_qu_all
 f1_out->qv    = latlev_qv_all
 f1_out->qw    = latlev_qw_all


;========================================================================================

print("Calculated CPU Time " + ( get_cpu_time() ) + " seconds")

end

sudo apt-get install libfprint0 fprint-demo libpam-fprintd gksu-polkit