load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


   undef("monthmean")
   function monthmean(x)
   begin
   ;计算一个daily数据的月平均值
   ;
       a=new((/12/),"float")
       a(0)=avg(x(0:30))
       a(1)=avg(x(31:58))
       a(2)=avg(x(59:89))
       a(3)=avg(x(90:119))
       a(4)=avg(x(120:150))
       a(5)=avg(x(151:180))
       a(6)=avg(x(181:211))
       a(7)=avg(x(212:242))
       a(8)=avg(x(243:272))
       a(9)=avg(x(273:303))
       a(10)=avg(x(304:333))
       a(11)=avg(x(334:364))
       return  a

   end 



begin 
 
;=================================================================
; 此脚本主要用于绘制ASIC年循环序列以及其标准差分布。 
; 2019.12.25绘制
; 加入了bar图标示逐月平均
; 2020.02修改
; 此脚本对比ASIC指数的1.5倍标准差曲线和90%概率密度的阈值阈值曲线
; 2020.05.03修改
;=================================================================
    days=(/1,32,60,91,121,152,182,213,244,274,305,335/)
   ;days=(/30,61,91,122,153,183,214,244,275,306,334,365/)
    months=(/"J","F","M","A","M","J","J","A","S","O","N","D"/)

;===================================================
;  data processing
;===================================================

    asic=new((/29,365/), "float")  ;中央区海冰ASIC海冰指数序列

    asic_mean=new((/365/),"float")
    
    year=1989

    do i=0,28


        asic(i,:)=asciiread("/mnt/e/ncl_for_subsystem/variation_curve/variation_curve/central_arctic_new/"+year+"_central_arctic_seaice_concentration.txt"\
         ,(/365/), "float")
        year=year+1 
        print(year)


    end do

    max_asic=dim_max_n(asic,0)
    min_asic=dim_min_n(asic,0)

    asic_mean=dim_avg_n_Wrap(asic,0)  ;ASIC年循环序列

    asic_stddev=dim_stddev_n(asic,0)  ;逐日标准差序列

    ts=monthmean(asic_mean)
    
    ts_mean=dim_avg(ts) 
    
;=======================================================
; 统计逐年夏季7-9月ASIC_CA低于80%的天数
;=======================================================
    num_80=new((/29/),"float")
    do i=0,28
       num_80(i)=ind(asic(i,:).eq.min(asic(i,:)));num(asic(i,181:272).le.80)
    end do
;=======================================================
;  计算PDF:这里计算了90%阈值的结果（即为100-10=90%）
;=======================================================
    asic_pdf_90=new((/365/),"float")
    do i=0,364
        ap= pdfx(asic(:,i),200, False)    ; default number of bins
        ;print(ap@bin_center)
        ;printVarSummary(ap@bin_center)
        ;print(ap)
        ap_center=doubletofloat(ap@bin_center) 
        ;print(ap_center)
        x=cumsum(ap,0)
        ;print(x)
        xx=ind(abs(x-10).eq.min(abs(x-10)))
        ;print(xx)
        ;print(ap_center(xx))
        asic_pdf_90(i)=ap_center(xx(0))
        delete([/ap,ap_center,x,xx/])
    end do
    print(asic_pdf_90)
    asic_pdf_95=new((/365/),"float")
    do i=0,364
        ap= pdfx(asic(:,i),200, False)    ; default number of bins
        ;print(ap@bin_center)
        ;printVarSummary(ap@bin_center)
        ;print(ap)
        ap_center=doubletofloat(ap@bin_center) 
        ;print(ap_center)
        x=cumsum(ap,0)
        ;print(x)
        xx=ind(abs(x-5).eq.min(abs(x-5)))
        ;print(xx)
        ;print(ap_center(xx))
        asic_pdf_95(i)=ap_center(xx(0))
        delete([/ap,ap_center,x,xx/])
    end do
    print(asic_pdf_95)
;=======================================================
; 其次计算融冰-结冰季节去季节循环序列
;=======================================================
    time=ispan(1,365,1)
;=======================================================
; 绘图部分
;=======================================================
  
    wks_type = "png"
    wks_type@wkWidth  = 2500
    wks_type@wkHeight = 2500 
    wks_type@vpWidthF=0.8
    wks_type@vpHeightF=0.4
    ;wks=gsn_open_wks(wks_type,"../picture/Central_arctic_asic_cycle")
    wks=gsn_open_wks("png","/mnt/e/ncl_for_subsystem/picture/2020/Central_arctic_asic_cycle_pdf")

    plot=new(1,graphic)

    res=True

    res@vpWidthF=0.8
    res@vpHeightF=0.48
    res@gsnMaximize=True
    res@gsnDraw=False
    res@gsnFrame=False

    res@xyMonoLineColor=False
    res@xyLineColor=(/"red"/)   ;这一句很关键
    res@xyDashPattern=0.
    res@xyLineThicknessF=10.

    ;res@tiMainString="ASIC_HCIR:  90% versus 1.5 std"
    ;res@tiMainFontHeightF=0.015

    res@tmXBMode ="Explicit"
    res@tmXBValues=days
    res@tmXBLabels=months
    res@trYMaxF=110
    res@trYMinF=50
    res@trXMaxF=365
    res@trXMinF=1

    ; res@gsnXYAboveFillColors = "white"
    ; res@gsnXYBelowFillColors = "green"
    
    res@tmXMajorGrid                = True
    res@tmYMajorGrid                = True
    res@tmXMajorGridThicknessF      = 1.0
    res@tmYMajorGridThicknessF      = 1.0
    res@tmXMajorGridLineDashPattern = 2
    res@tmYMajorGridLineDashPattern = 2

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineThicknessF  = 2.                    ; line thicker   
    res_lines@tfPolyDrawOrder   = "PreDraw"
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineColor       ="blue"
    
    res@tiYAxisString           ="ASIC(%)"
    res@tiXAxisString           ="Month"
    res@tiXAxisOffsetYF         =-0.06    ;设置横坐标的垂直偏移量
    res@tiYAxisOffsetXF         =0.01
    plot=gsn_csm_xy(wks,time,asic_mean,res)

    ;dum1=gsn_add_polyline(wks,plot(0),(/1,14*365/),(/0.,0./),res_lines)
    ;==============================================================
    ; 添加范围条
    ;==============================================================
    xp1    = new((/2,365/), "float" )

    xp1(0,:)=asic_mean+1.6*asic_stddev   ;阴影代表标准差
    xp1(1,:)=asic_mean-1.6*asic_stddev

    ; xp1(0,:)=max_asic                  ;阴影代表最大最小值范围
    ; xp1(1,:)=min_asic
    

    printVarSummary(xp1)
    printMinMax(xp1,-1)

    gsres                   = True   
    gsres@gsnDraw           =False
    gsres@gsnFrame          =False                      ; poly res
    gsres@tfPolyDrawOrder   = "Predraw"                   ; draw this first
    gsres@gsnXYFillColors        = "gray" 
    gsres@gsnXYFillOpacities=0.3                ; color chosen

    dummy = gsn_csm_xy (wks,time,xp1,gsres) 
    ;print(ts)
    res@xyLineThicknessF=3.
    res@xyLineColor="blue"
    plot1 = gsn_csm_xy(wks,time,asic_pdf_90,res)
    res@xyLineColor="green"
    plot2 = gsn_csm_xy(wks,time,asic_pdf_95,res)
; ;=====================================================
; ; 添加每月平均值的数字条。
; ;=====================================================
; tres                      = True                ; text mods desired
; tres@txFontHeightF        = 0.012               ; make smaller
; dum = new(12,graphic)
; do i=0,11
;    dum(i) = gsn_add_text(wks,plot,sprintf("%4.2f",ts(i)),\
;                         days(i)+15,ts(i)+3,tres)
; end do
;========================================================
;   文字和曲线注释res
;========================================================
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineThicknessF  = 3.;15.                    ; line thicker   
    ;res_lines@tfPolyDrawOrder   =  "PostDraw"
    res_lines@gsLineColor       = "green";"black"
    res_lines@gsLineDashPattern = 1.
     
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.018                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification
    res_text@tfPolyDrawOrder    = "PostDraw"
    
    ;dum1=gsn_add_polyline(wks,plot,(/0.,365./),(/ts_mean,ts_mean/),res_lines)

;=============================================================
;   加注释
;=============================================================
    xx=(/50,80/)
    yy=(/65,65/);原始值
    legend_name=(/"ASIC_HCIR","PDF:(90%)","PDF:(95%)"/)
    
    res_lines@gsLineDashPattern = 0.
    res_lines@gsLineColor       = "red";"black
    dum2=gsn_add_polyline(wks,plot1,xx,yy,res_lines)
    dum11=gsn_add_text(wks,plot1,legend_name(0),xx(1)+10,yy(1),res_text)
    
    yy=(/60,60/);原始值
    res_lines@gsLineColor       = "blue"
    dum3=gsn_add_polyline(wks,plot1,xx,yy,res_lines)
    dum11=gsn_add_text(wks,plot1,legend_name(1),xx(1)+10,yy(1),res_text)
    
    yy=(/55,55/);原始值
    res_lines@gsLineColor       = "green"
    ;res_lines@gsLineDashPattern = 2
    dum4=gsn_add_polyline(wks,plot1,xx,yy,res_lines)
    dum11=gsn_add_text(wks,plot1,legend_name(2),xx(1)+10,yy(1),res_text)

    ; print(ts_mean)
    ; print(max_asic)
    ; print(max(max_asic-min_asic))
    ; print(asic_mean)
    overlay(plot,dummy)
    overlay(plot,plot1)
    overlay(plot,plot2 )
    draw(plot)
    frame(wks)


    print(num_80)
end 

   