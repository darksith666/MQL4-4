//+------------------------------------------------------------------+
//|                                                     Fractals.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//----Fractal------
#property indicator_chart_window
#property indicator_buffers 1                               // fractals 
#property indicator_color1 Red

#include <FR_UP.mqh>;

//---- buffers
double ExtUpFractalsBuffer[];                                  
double ExtMapBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping  
    SetIndexBuffer(0,ExtUpFractalsBuffer);  
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,217);
//----
    SetIndexEmptyValue(0,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Fractal Up");
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
//----Up Fractals
   while(i>=2)
     {
     bFound = Fractals_Up(i);
      if (bFound)
      { 
      ExtUpFractalsBuffer[i] = High[i];
      }
     i--;
     }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+