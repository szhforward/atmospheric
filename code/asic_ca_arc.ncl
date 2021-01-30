load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin 
 
;=================================================================
;此脚本主要用于绘制中央区(CA)和北极整体(ARC)时间序列 
;(可以绘制两种图：1.原始的密集度指数2.密集度指数的anomaly)
;2019.02.16修改
;=================================================================


days1=new((/14/),"float")
days1(0)=276
do i=1,13
  days1(i)=days1(i-1)+365
end do 

days2=new((/14/),"float")
days2(0)=days1(13)+365
do i=1,13
  days2(i)=days2(i-1)+365
end do 
; years=(/"1990","1991","1992","1993","1994","1995","1996",\
;       "1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007",\
;       "2008","2009","2010","2011","2012","2013","2014","2015","2016","2017"/)
years=(/"90","91","92","93","94","95","96",\
      "97","98","99","00","01","02","03","04","05","06","07",\
      "08","09","10","11","12","13","14","15","16","17"/)

years1=(/"90","91","92","93","94","95","96",\
      "97","98","99","00","01","02","03"/)
years2=(/"04","05","06","07","08","09","10","11","12","13","14","15","16","17"/)




days=new((/29/),"float")
days(0)=1
do i=1,28
  days(i)=days(i-1)+365
end do 



; years=(/"89","90","91","92","93","94","95","96",\
;       "97","98","99","00","01","02","03","04","05","06","07",\
;       "08","09","10","11","12","13","14","15","16","17"/)


printVarSummary(days)
printVarSummary(years)



;===================================================
;  data processing
;===================================================
    year=1989

    area=new((/29,365/), "float")
    area_mean=new((/365/),"float")
     
    area_total=new((/29,365/), "float")
    area_mean_total=new((/365/),"float")

    do i=0,28
          
             
         area(i,:)=asciiread("/mnt/e/ncl_for_subsystem/variation_curve/variation_curve/central_arctic_new/"+year+"_central_arctic_seaice_concentration.txt",(/365/), "float")
         area_total(i,:)=asciiread("/mnt/e/ncl_for_subsystem/variation_curve/variation_curve/total_arctic/"+year+"_total_arctic_seaice_concentration.txt",(/365/), "float")
         year=year+1 
         print(year)


    end do

    area_mean=dim_avg_n_Wrap(area, 0)
    area_mean_total=dim_avg_n_Wrap(area_total, 0)
    area_mean_all=new((/29*365/),"float")
    area_mean_all_total=new((/29*365/),"float")
    do i=0,364
       do j=0,28
         area_mean_all(i+j*365)=area_mean(i)
         area_mean_all_total(i+j*365)=area_mean_total(i)    
       end do
    end do

    printVarSummary(area_mean_all)



    ;================================================
    ; 其次计算融冰-结冰季节去季节循环序列
    ;================================================


    area_new=new((/28,365/),"float")
    do i=0,27
     area_new(i,:274)=area(i,90:)
     area_new(i,275:)=area(i+1,:89)
    end do
    area_new@_FillValue=-999.

    area_new_total=new((/28,365/),"float")
    do i=0,27
     area_new_total(i,:274)=area_total(i,90:)
     area_new_total(i,275:)=area_total(i+1,:89)
    end do
    area_new_total@_FillValue=-999.


    plot_max=110
    plot_min=15

    ; area_mean1=dim_avg_n_Wrap(area_new(:7,:), 0)
    ; area_mean2=dim_avg_n_Wrap(area_new(8:17,:),0)
    ; area_mean3=dim_avg_n_Wrap(area_new(18:27,:), 0)

    asic_ts=reshape(area_new,(/28*365/))
    asic_ts_total=reshape(area_new_total,(/28*365/))

    ; sic_std_upper=new((/28,365/),"float")
    ; sic_std_lower=new((/28,365/),"float")
    ; do i=0,364
    ; sic_std_upper(:,i)=1.5*stddev(area_new(:,i))
    ; sic_std_lower(:,i)=-1.5*stddev(area_new(:,i))
    ; end do

    ; sic_std_upper:=reshape(sic_std_upper,(/28*365/))
    ; sic_std_lower:=reshape(sic_std_lower,(/28*365/))

    ; printVarSummary(sic_std_upper)
    ; printVarSummary(sic_std_lower)
    ; print(sic_std_lower(0))
    ; print(sic_std_lower(365))
    ; print(sic_std_lower(2*365))

    data=new((/2,28*365/),"float")
    data(0,:)=asic_ts ;asic_ts-area_mean_all(90:89+365*28);asic_ts
    data(1,:)=asic_ts_total ;sic_std_lower;sic_std_lower+area_mean_all(90:89+365*28);sic_std_lower;sic_std_lower+area_mean_all(90:89+365*28);从89年4月1日开始到17年3月31日

    data1=data(0,:)
    data2=data(1,:)

    time=ispan(1,28*365,1)
    time1=ispan(1,14*365,1)
    time2=ispan(14*365+1,28*365,1)

    printVarSummary(data)
    printVarSummary(time)

    ; low_asic_events=where(data1.le.data2,data1,-999.)

    ; low_asic_events@_FillValue=-999.

    ; num_low_events=num(.not.ismissing(low_asic_events))

    ; low_asic_events_date=new((/dimsizes(low_asic_events)/),"float")

    ; print(num_low_events)

   



 ;=======================================================
 ; 绘图部分
 ;=======================================================
  
    wks_type = "png"
    wks_type@wkWidth  = 2500
    wks_type@wkHeight = 2500 

    wks=gsn_open_wks("png","/mnt/e/ncl_for_subsystem/picture/2020/ASIC_CA_ARC_curve_final")

    plot=new(2,graphic)

    res=True

    res@vpWidthF=0.8
    res@vpHeightF=0.2
    res@gsnMaximize=True
    res@gsnDraw=False
    res@gsnFrame=False

    res@xyMonoLineColor=False
    res@xyLineColors=(/"red","blue"/);(/"red","white"/)   ;这一句很关键
    res@xyDashPattern=0.
    res@xyLineThicknessF=5.

    ; res@tiMainString="ASIC_abnormal_events "+n+"N"
    res@tiMainFontHeightF=0.015

    res@tmXBMode ="Explicit"
    res@tmXBValues=days1
    res@tmXBLabels=years1
    res@trYMaxF=plot_max
    res@trYMinF=plot_min
    res@trXMaxF=14*365
    res@trXMinF=1

    ; res@gsnXYAboveFillColors = "white"
    ; res@gsnXYBelowFillColors = "green"
     
    res@tmXMajorGrid                = True
    res@tmYMajorGrid                = True
    res@tmXMajorGridThicknessF      = 3.0
    res@tmYMajorGridThicknessF      = 3.0
    res@tmXMajorGridLineDashPattern = 2
    res@tmYMajorGridLineDashPattern = 2
    
    res@tiYAxisString="ASIC(%)"
    res@tiXAxisString="Year"
    res@tiXAxisOffsetYF         =-0.06    ;设置横坐标的垂直偏移量
    res@tiYAxisOffsetXF         =0.01

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineThicknessF  = 2.                    ; line thicker   
    res_lines@tfPolyDrawOrder   = "PreDraw"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineColor       ="blue"


    plot(0)=gsn_csm_xy(wks,time1,data(:,:14*365-1),res)
    ;plot(0)=gsn_csm_xy(wks,time1,asic_ts(:14*365-1),res)

    ;dum1=gsn_add_polyline(wks,plot(0),(/1,14*365/),(/0.,0./),res_lines)

    res@trXMaxF=28*365
    res@trXMinF=14*365+1
    res@tmXBValues=days2
    res@tmXBLabels=years2

    plot(1)=gsn_csm_xy(wks,time2,data(:,14*365:),res)
    ;plot(1)=gsn_csm_xy(wks,time2,asic_ts(14*365:),res)

    dum2=gsn_add_polyline(wks,plot(1),(/14*365+1,28*365/),(/0.,0./),res_lines)



    resp=True
    resp@gsnMaximize=True
    ;resp@gsnPanelMainString="ASIC Variation (1989-2017)"
    ;resp@gsnCenterString="red lines represent 1.5stddev"
    gsn_panel(wks,plot,(/2,1/), resp)


end 
   