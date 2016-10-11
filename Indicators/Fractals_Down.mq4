 //+------------------------------------------------------------------+
//|                                                     Fractals.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
//---- input parameters
#include <FR_DOWN.mqh> 
//---- buffers
double ExtDownFractalsBuffer[];
double ExtMapBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping  
     SetIndexBuffer(0,ExtDownFractalsBuffer);   
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,218);
//----
    SetIndexEmptyValue(0,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Fractal Down");
//---- initialization done   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nCountedBars;
   bool   bFound;
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted    
   if(nCountedBars<=2)
      i=Bars-nCountedBars-3;
   if(nCountedBars>2)
     {
      nCountedBars--;
      i=Bars-nCountedBars-1;
     }
 
 //----Fractals down
 
 while(i>=2)
 
 {
     bFound = Fractals_Down(i);
      if (bFound)
      { 
      ExtDownFractalsBuffer[i] = Low[i];
      }
     i--;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+