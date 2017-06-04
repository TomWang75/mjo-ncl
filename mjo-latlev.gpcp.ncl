;***********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"   



;******************** MAIN **********************************
begin

  rdata = "gpcp"
                           ; Must include period of mutual overlap
  twStrt = 19971001        ; include enough temporal buffer for filter
  twLast = 20141231        ; at least 100 days on each side of season

 ;cwStrt = 20001101        ; correlation window for specified season 
 ;cwLast = 20010531       


  latS   =  -35  
  latL   =   35   

  lonS   =    0  
  lonL   =  360  

  levS   = 1000
  levL   =  100



  nameSeason = (/ "annual", "summer", "winter" /)

  nameRegion = "IO"        ; Indian Ocean base region
  latS_IO    =  -5.
  latN_IO    =   5. 
  lonL_IO    =  75.
  lonR_IO    =  85. 

  latS_globe = -30.        ; global subset  [Fig 6]
  latN_globe =  30. 

  latn       =  10.        ; lat band for (lag,lon) Fig 5
  lats       = -10.

 ; lonl       =  80.        ; lon band for (lag,lat) Fig 6
 ; lonr       = 100.

  pltName    = "mjo-lag-lonlev-"+rdata       ; output plot name         
  pltType    = "pdf"       ; x11, ps, eps, pdf, png 
  pltDir     = "./"        ; output plot directory

;***************************************************************************************
;read data
;***************************************************************************************
 ; gpcp, spcam, cam
;***************************************************************************************
; read P
  if(rdata.eq."gpcp")then
  pName  = "precip"          ; name of variable on precipitation file
  dirp   = "/home/wt/WORKING/DATA/PREC/"
  filp   = "gpcp_1dd_v1.2_p1d.19961001-20150531.daily.nc"     ; last date w data 20080430
  f      = addfile(dirp+filp, "r")

  date_p = cd_calendar(f->time, -2)   ; entire file
  iStrt  := ind(date_p.eq.twStrt)      ; desired dates
  iLast  := ind(date_p.eq.twLast)
  delete(date_p)  

    if (getfilevartypes(f,pName) .eq. "short") then
      P  = short2flt( f->$pName$(iStrt:iLast,{latS_globe:latN_globe},:)) 
    else
      P  = f->$pName$(iStrt:iLast,{latS_globe:latN_globe},:) 
    end if

; read u v
  uName = "uwnd"
  vName = "vwnd"
  wName = "omega"
  qName = "shum"
  tName = "air"

  dir  = "/home/wt/WORKING/DATA/ERA-interim"

  filu  =  systemfunc("ls "+diru+"/u/uwnd.interim.*.nc")
  filv  =  systemfunc("ls "+diru+"/v/vwnd.interim.*.nc")
  filw  =  systemfunc("ls "+diru+"/omega/omega.interim.*.nc")
  filq  =  systemfunc("ls "+diru+"/shum/shum.interim.*.nc")
  filt  =  systemfunc("ls "+diru+"/air/air.interim.*.nc")
  setfileoption("nc","SuppressClose",False) ; close too many files 

  end if

;***************************************************************************************
  if(rdata.eq."spcam")then
  pcName       =  "PRECC"
  plName       =  "PRECL"
  dirp         = "/home/yangsong3/wt/SPCAM-TEST-2016/SP_AMIP/"
  filpc        = systemfunc("ls "+dirp+"SP_AMIP.cam.h1.YEAR.198[1-9].daily.PRECC.nc " + dirp + "SP_AMIP.cam.h1.YEAR.199[0-9].daily.PRECC.nc " + dirp + "SP_AMIP.cam.h1.YEAR.200[0-5].daily.PRECC.nc ")
  filpl        = systemfunc("ls "+dirp+"SP_AMIP.cam.h1.YEAR.198[1-9].daily.PRECL.nc " + dirp + "SP_AMIP.cam.h1.YEAR.199[0-9].daily.PRECL.nc " + dirp + "SP_AMIP.cam.h1.YEAR.200[0-5].daily.PRECL.nc ")
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





;************************************************
; create Lanczos BandPass Filter
;************************************************
  ihp    = 2                          ; bpf=>band pass filter
  nWgt   = 201
  sigma  = 1.0                        ; Lanczos sigma
  fca    = 1./100.                    ; MJO clivar
  fcb    = 1./20.
  wgt    = filwgts_lanczos (nWgt, ihp, fca, fcb, sigma )

;************************************************************
; PRECIPITATION:
;     time indices corresponding to the desired time window
;     Read user specified period
;************************************************************

  f      = addfiles(dirp+filp, "r")  
  date_p = cd_calendar(f[:]->time, -2)   ; entire file
  iStrt  = ind(date_p.eq.twStrt)      ; desired dates
  iLast  = ind(date_p.eq.twLast)
  delete(date_p)
                                      ; P(time,lat,lon)
  if (getfilevartypes(f[0],pName) .eq. "short") then
      P  = short2flt( f[:]->$pName$(iStrt:iLast,{latS_globe:latN_globe},:)) 
  else
      P  = f[:]->$pName$(iStrt:iLast,{latS_globe:latN_globe},:) 
  end if

  printVarSummary( P )
  printMinMax(P, True)

  time_p = P&time                     ; clarity
  date_p = cd_calendar(time_p, -2 )   ; yyyymmdd
  
  wyIO   = f->lat({latS_IO:latN_IO})  
  wyIO   = cos(0.017459*wyIO)         ; spatial wgt



;************************************************
; make sure dates agree
;************************************************

  ;if (.not.all(date_p.eq.date_u)) then
  ;    print("date mismatch: exit")
  ;    exit
  ;end if

;************************************************
; Create wgted area average of the base IO precip series  (time)
; Really, no need to area weight here .... area is very small.
;************************************************

  PIO    = wgt_areaave_Wrap(P(:,{latS_IO:latN_IO},{lonL_IO:lonR_IO}), wyIO, 1., 0)
  PIO    = dtrend (PIO, False)                                   ; rmv overall trend
  PIO    = wgt_runave_leftdim( PIO, wgt, 0 )                     ; apply filter
  
;************************************************
; Create LAT average of the global Precip and U series  (time,lon)
; Really, no need to area weight here
;************************************************

  P_timeLon   = dim_avg_Wrap(P( time|:,lon|:,{lat|lats:latn}) )  ; (time,lon)
  P_timeLon   = dtrend_leftdim (P_timeLon, False)                ; rmv overall trend
  P_timeLon   = wgt_runave_leftdim( P_timeLon, wgt, 0 )          ; apply filter



;************************************************
; Create LON average of the global Precip and U series  (time,lat)
; Really, no need to area weight here
;************************************************

 ; P_timeLat   = dim_avg_Wrap(P( time|:,lat|:,{lon|lonl:lonr}) )  ; (time,lat)
 ; P_timeLat   = dtrend_leftdim (P_timeLat, False)                ; rmv overall trend
 ; P_timeLat   = wgt_runave_leftdim( P_timeLat, wgt, 0 )          ; apply filter



;*************************************************************************
; Calculate/Plot the mean seasonal cross-correlations at +/- 'mxlag' lags
;*************************************************************************
  optXcor   = False
  mxlag     = 20
  nSeason   = dimsizes(nameSeason)


 ; optPlot@smth9            = 0.25                ; local spatial smoothing



 ; do ns=0,nSeason-1                              ; loop over each season
 ;    rp_timelon = mjo_xcor_lag (PIO, P_timeLon, date_p, mxlag, nameSeason(ns), optXcor)
 ; end do

rp_timelon = mjo_xcor_lag (PIO, P_timeLon, date_p, mxlag, nameSeason(0), optXcor)

rp_timelon_smth = smth9_Wrap(rp_timelon, 0.5, 0.25, True)

  printVarSummary(rp_timelon_smth)




;*************************************************************************
; PLOT
;*************************************************************************
 wks   = gsn_open_wks(pltType,pltDir+pltName)                ; open a ps file


  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet

 ; res@tiMainString  = "Corr_sst-ntc.earlier season"
  res@gsnLeftString       = ""
  res@gsnRightString       = ""
  res@gsnLeftStringFontHeightF  =  0.02
  res@gsnRightStringFontHeightF  =  0.02
  res@gsnLeftStringOrthogonalPosF = 0


  res@tiMainFontHeightF      =   0.02
  res@tmXBLabelFontHeightF   =   0.025
  res@tmYLLabelFontHeightF   =   0.025
  res@tmXBLabelFontColor     =   1
  res@tmYLLabelFontColor     =   1   
  res@tmXBLabelDeltaF        =  -1
  res@tmYLLabelDeltaF        =  -1
  res@tmXBLabelFont          =   21
  res@tmYLLabelFont          =   21

  res@vpWidthF   =  0.7                         ; make map bigger
  res@vpHeightF  =  0.4
  res@vpXF       = 0.10        ; change start locations
  res@vpYF       = 0.90        ; the plot

  res@tmYROn           = False     ; Turn off right and top tick marks
  res@tmXTOn           = False     ; Turn off right and top tick marks

  res@gsnMajorLonSpacing=30
  res@gsnMajorLatSpacing=20
  res@tmXBMinorOn  =True
  res@tmYLMinorOn  =True





  cmap = read_colormap_file("CBR_coldhot")
  res@cnFillPalette = cmap;(0:120:-1,:)
 ; res@tiMainString  = "Corr_sst-ntc.summer"

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = True              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@cnInfoLabelOn        = False

  res@lbLabelBarOn         = True        ; turn off individual lb's
  res@lbBoxLinesOn         = False
  res@lbOrientation        = "Vertical"
  res@lbLabelAutoStride    = False         ; auto stride on labels
  res@lbLabelStride   =  1
  res@lbLabelFontHeightF = 0.018
  res@pmLabelBarOrthogonalPosF = 0.01          ; move label bar closer

 ;  res@gsnScalarContour     = True               ; contours desired
 ;  res@cnMonoFillPattern    =False
 ;  res@cnFillPatterns       =(/-1,0/)

 ; res@cnLevelSelectionMode =     "ManualLevels" 
 ; res@cnMinLevelValF       =     -1.0
 ; res@cnMaxLevelValF       =      1.0
 ; res@cnLevelSpacingF      =       0.2

  res@cnMonoLineDashPattern =  False
  res@cnLineThicknessF  = 2
  res@cnLineDashPatterns     =  (/6,6,6,6,6,0,0,0,0,0/)

  res@cnLevelSelectionMode = "ExplicitLevels" 
  res@cnLevels     = (/ -1.0, -0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8, 1.0/)  ; set the colors to be used


  res@gsnLeftString       = "GPCP"
  res@gsnRightString       = ""
  res@gsnLeftStringFontHeightF  =  0.03
  res@gsnRightStringFontHeightF  =  0.03

 ; res@tiYAxisString = "time(day)"
  res@tiYAxisFontHeightF = 0.03







  plot           = gsn_csm_hov(wks, rp_timelon_smth({-20:20},{30:210}), res )

;==================================================================================

  resline                  = True                      ; polyline mods desired
  resline@gsLineColor      = "black"                     ; color of lines
  resline@gsLineThicknessF = 2.5                       ; thickness of lines
  resline@gsLineDashPattern = 2

  dumline        = gsn_add_polyline(wks,plot,(/30,182/),(/-20,20/),resline)

draw(plot)
frame(wks)





;========================================================================================

print("Calculated CPU Time " + ( get_cpu_time() ) + " seconds")


end





