load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

;===============================================================
; 此程序是为了绘制2007,2008,2010,2011,2012,2016年北极中央区海冰ASIC曲线及其anomaly
; 
; 
; 2019.08.07修改
; 2020.02.04修改 这一版中主要加入了2008年 并且统计了各个异常年夏季（6-8月）的ASIC低于80%的天数
; 2020.04.27重新调整了坐标标签的位置，改变了曲线的粗细
;===============================================================

procedure  add_legend_for_picture(wks,plot,xx,yy,legend_name,legend_color,dash_data)
;local xx,yy
begin
;========================================================
;这段程序实现的功能为，给定坐标位置变量和标注量以及标记颜色，标记类型等，
;为底图加上对应线段和文字
;========================================================

   res_text                    = True                  ; text mods desired
   res_text@txFontHeightF      = 0.014                 ; change text size
   res_text@txJust             = "CenterLeft"          ; text justification
   res_text@tfPolyDrawOrder    = "PostDraw"


   res_lines                   = True                  ; polyline mods desired
   res_lines@gsLineThicknessF  = 4.                    ; line thicker   
   res_lines@tfPolyDrawOrder   =  "PostDraw"
   res_lines@gsLineColor       = legend_color
   res_lines@gsLineDashPattern = dash_data
   
   str = unique_string("polyline")
 
  
   print(yy)

    
   plot@$str$=gsn_add_polyline(wks,plot,xx,yy,res_lines)
   dum=gsn_add_text(wks,plot,legend_name,xx(1)+1.0,yy(1),res_text)
  
   printVarSummary(dum)
   print(legend_color)
   print(legend_name)
   
 
end
   days=(/1,32,60,91,121,152,182,213,244,274,305,335/)
   ;days=(/30,61,91,122,153,183,214,244,275,306,334,365/)
   months=(/"J","F","M","A","M","J","J","A","S","O","N","D"/)

   plot_max=120.
   plot_min=40.


   asic=new((/29,365/), "float")
   asic_mean=new((/365/),"float")

   year=1989
   do i=0,28
         
        asic(i,:)=asciiread("../variation_curve/variation_curve/central_arctic_new/"+year+"_central_arctic_seaice_concentration.txt"\
         ,(/365/), "float")
        year=year+1 
        print(year)


   end do


   asic_mean=dim_avg_n(asic,0)
   asic_all=new((/7,365/),"float")
   asic_all(0,:)=asic_mean
   asic_all(1,:)=asic(18,:)
   asic_all(2,:)=asic(19,:)
   asic_all(3,:)=asic(21,:)
   asic_all(4,:)=asic(22,:)
   asic_all(5,:)=asic(23,:)
   asic_all(6,:)=asic(27,:)
  
   do i=1,6
      nu=num(asic_all(i,182:272).le.80)
      print(nu)
   end do

   asic_all_anomaly=new((/7,365/),"float")
   asic_all_anomaly(0,:)=asic_all(0,:)-asic_mean
   asic_all_anomaly(1,:)=asic_all(1,:)-asic_mean
   asic_all_anomaly(2,:)=asic_all(2,:)-asic_mean
   asic_all_anomaly(3,:)=asic_all(3,:)-asic_mean
   asic_all_anomaly(4,:)=asic_all(4,:)-asic_mean
   asic_all_anomaly(5,:)=asic_all(5,:)-asic_mean
   asic_all_anomaly(6,:)=asic_all(6,:)-asic_mean
;================================================================
;  first plot
;================================================================
   wks_type = "png"
   wks_type@wkWidth  = 2500
   wks_type@wkHeight = 2500

   wks = gsn_open_wks("ps","../picture/2020/ASIC abnormal year") 
   wks = gsn_open_wks("png","../picture/2020/ASIC abnormal year_test") 
   ;wks = gsn_open_wks(wks_type,"../picture/2020/ASIC abnormal year")  

   gsn_define_colormap(wks,"rainbow+gray")

   plot=new(2,"graphic")

   res                    = True              ; plot mods desired
   res@gsnDraw            = False             ; don't draw yet
   res@gsnFrame           = False             ; don't advance frame yet
   res@gsnMaximize        = True
   res@gsnPaperOrientation = "portrait"
   res@vpHeightF    = 0.48                ; change aspect ratio of plot
   res@vpWidthF             = 0.7
   ;==========================================================
   ;for some detail configure
   ;==========================================================
   res@xyMonoLineColor    = False             ; want colored lines
   res@xyLineColors       = (/"black","red","blue","chartreuse3","purple","darkorange","cyan"/)
   res@xyDashPatterns     = (/0.,0.,0.,0.,0.,0.,0./)      ; make all lines solid 
   res@xyLineThicknesses=(/1.,1.,1.,1.,1.,1.,1./)*5;3
   res@tmXBMode ="Explicit"
   res@tmXBValues=days
   res@tmXBLabels=months
   res@trYMaxF=plot_max
   res@trYMinF=plot_min
   res@trXMaxF=365
   res@trXMinF=1
   ;res@gsnLeftString="unit:percent"
   ;res@tiMainString       ="ASIC abnormal year"    
   
   res@tiYAxisString="ASIC(%)"
   res@tiXAxisString="Month"
   res@tiXAxisOffsetYF         =-0.06    ;设置横坐标的垂直偏移量
   res@tiYAxisOffsetXF         =0.01  
   ;res@gsnLeftString="(a)"
   res@gsnCenterString="(a)"
   res@gsnCenterStringFontHeightF=0.025

   res@tmXMajorGrid                = True
   res@tmYMajorGrid                = True
   res@tmXMajorGridThicknessF      = 2.0;1.0
   res@tmYMajorGridThicknessF      = 2.0;1.0
   res@tmXMajorGridLineDashPattern = 2
   res@tmYMajorGridLineDashPattern = 2
 
   ;============================================================
   ;plot sic(2015-2017)
   ;============================================================

   year1=ispan(1,365,1)  
   printVarSummary(year1)
   printVarSummary(asic_all)

   plot(0)=gsn_csm_xy(wks,year1,asic_all,res)
   
   res@trYMaxF=10
   res@trYMinF=-30.  
   ;res@gsnLeftString="(b)"
   res@gsnCenterString="(b)"
   plot(1)=gsn_csm_xy(wks,year1,asic_all_anomaly,res)
   
   ;==============================================================
   ; 添加图注
   ;==============================================================
   xx=(/15,35/)
   yy=(/110,110/);原始值
   yy1=(/5,5/) ;异常值
   legend_name=(/"Clim","07","08","10","11","12","16"/)
   legend_color=(/"black","red","blue","chartreuse3","purple","darkorange","cyan"/)
   
   dum1=new(7,"graphic")
   dum2=new(7,"graphic")
   
   do i=0,6
      res_text                    = True                  ; text mods desired
      res_text@txFontHeightF      = 0.023                 ; change text size
      res_text@txJust             = "CenterLeft"          ; text justification
      res_text@tfPolyDrawOrder    = "PostDraw"


      res_lines                   = True                  ; polyline mods desired
      res_lines@gsLineThicknessF  = 5.;3.;15.                    ; line thicker   
      ;res_lines@tfPolyDrawOrder   =  "PostDraw"
      res_lines@gsLineColor       = legend_color(i)
      res_lines@gsLineDashPattern = 0.

      dum1(i)=gsn_add_polyline(wks,plot(0),xx,yy,res_lines)
      dum11=gsn_add_text(wks,plot(0),legend_name(i),xx(1)+6.0,yy,res_text)

      dum2(i)=gsn_add_polyline(wks,plot(1),xx,yy1,res_lines)
      dum11=gsn_add_text(wks,plot(1),legend_name(i),xx(1)+6.0,yy1,res_text)

      xx=xx+50
   end do

   
   ; genres                     = True
   ; textres                    = True
   ; lineres                    = True
   ; genres@XPosPercent         = 26
   ; genres@YPosPercent         = 20
   ; textres@lgLabels           = legend_name(::-1) ; reverse label order for legend
   ; textres@lgItemCount        = 6
   ; lineres@lgLineThicknesses  = 3.5
   ; lineres@lgLineColors       = legend_color(::-1)     ; reverse color order for legend
   ; lineres@lgDashIndexes      = res@xyDashPatterns(::-1)   ; reverse pattern order for legend
   ; lineres@LineLengthPercent  = 40

   
;============================================================
;  add standrad deviation
;============================================================

   xp1    = new((/2,365/), "float" )


   do k=0,364
      dx1             = stddev(asic(:,k))
      xp1(0,k)          = asic_mean(k)+dx1
      xp1(1,k)          = asic_mean(k)-dx1

   end do
   
   printVarSummary(xp1)
   printMinMax(xp1,-1)

   gsres                   = True   
   gsres@gsnDraw           =False
   gsres@gsnFrame          =False                      ; poly res
   gsres@tfPolyDrawOrder   = "Predraw"                   ; draw this first
   gsres@gsnXYFillColors        = "gray" 
   gsres@gsnXYFillOpacities=0.3                ; color chosen
   ;dummy1 =gsn_add_polygon (wks1,plot1,xp1,yp1,gsres)
   dummy1 = gsn_csm_xy (wks,year1,xp1,gsres) 
   

   overlay(plot(0),dummy1)
   
   resp=True
   resp@gsnPanelMainString=""
   ;resp@gsnPanelMainString="ASIC Abnormal Year: ASIC and Anomaly"
    ;res@tiMainString= "unique events:slp and wind for JAS"
   gsn_panel(wks,plot,(/1,2/),resp) 
  

  



