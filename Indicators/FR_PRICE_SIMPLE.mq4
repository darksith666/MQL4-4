//+------------------------------------------------------------------+
//|                               YBR_Fractals_Price_Simple_Long.mq4 |
//|                                                  Andrey Vasiliev |
//|                                                  andrey-fx@bk.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Vasiliev"
#property link      "andrey-fx@bk.ru"

#property indicator_chart_window
#property indicator_buffers 2
//#property indicator_color1 Red
//#property indicator_color2 Lime
//---- input parameters
int spread=NormalizeDouble((Ask-Bid)/Point, Digits);  //EurUsd=2, GbpUsd=3, Gold=5, Silver=5, UsjJpy=3, GBPCHF=7, UsdChf=3, EurJpy=3, UsdCad=4, GbpJpy=7, AudUsd=3
//---- buffers
double ExtUpFractalsBuffer[];
double ExtDownFractalsBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
/*//---- indicator buffers mapping  
    SetIndexBuffer(0,ExtUpFractalsBuffer);
    SetIndexBuffer(1,ExtDownFractalsBuffer);   
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,119);
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexArrow(1,119);
//----*/
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Fractal Up");
    SetIndexLabel(1,"Fractal Down");
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
   int obj_total=ObjectsTotal();//Возвращает общее число объектов 
   
   for(int i = obj_total - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringFind(label, "ArrowCodeFractals")==-1) continue;
       ObjectDelete(label); //Удаление объекта с указанным именем.  
     }     
//----   
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
//   double dCurrent;
   datetime tCurrent;
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted    
   if(nCountedBars<=2)
      i=Bars-nCountedBars-3;
   if(nCountedBars>2)
     {
      nCountedBars--;
      i=Bars-nCountedBars-1;
     }
//----Up and Down Fractals
   while(i>=2)
     {
//-------------MA Lines--------------------------------
 double MA_Long,MA_Short,MA_Final,dCurrent;

   MA_Long=iMA(NULL,0,200,50,MODE_SMA,PRICE_HIGH,i);
   MA_Short=iMA(NULL,0,200,50,MODE_SMA,PRICE_LOW,i);
   MA_Final=iMA(NULL,0,200,200,MODE_SMA,PRICE_MEDIAN,i);
//-----------------------------------------------------       
     if(MA_Long<Low[i] && MA_Short<Low[i] && MA_Final<Low[i]) 
    { 
      //----Fractals up
      bFound=false;
      dCurrent=High[i];
      tCurrent= Time[i];
      if(dCurrent>High[i+1] && dCurrent>High[i+2] && dCurrent>High[i-1] && dCurrent>High[i-2])
        {
         bFound=true;
         ExtUpFractalsBuffer[i]=dCurrent;
         DrawArrow(tCurrent,NormalizeDouble(dCurrent+(2*spread)*Point, Digits),5,clrRoyalBlue);
        }
      //----6 bars Fractal
      if(!bFound && (Bars-i-1)>=3)
        {
         if(dCurrent==High[i+1] && dCurrent>High[i+2] && dCurrent>High[i+3] &&
            dCurrent>High[i-1] && dCurrent>High[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
           }
        }         
      //----7 bars Fractal
      if(!bFound && (Bars-i-1)>=4)
        {   
         if(dCurrent>=High[i+1] && dCurrent==High[i+2] && dCurrent>High[i+3] && dCurrent>High[i+4] &&
            dCurrent>High[i-1] && dCurrent>High[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
           }
        }  
      //----8 bars Fractal                          
      if(!bFound && (Bars-i-1)>=5)
        {   
         if(dCurrent>=High[i+1] && dCurrent==High[i+2] && dCurrent==High[i+3] && dCurrent>High[i+4] && dCurrent>High[i+5] && 
            dCurrent>High[i-1] && dCurrent>High[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
           }
        } 
      //----9 bars Fractal                                        
      if(!bFound && (Bars-i-1)>=6)
        {   
         if(dCurrent>=High[i+1] && dCurrent==High[i+2] && dCurrent>=High[i+3] && dCurrent==High[i+4] && dCurrent>High[i+5] && 
            dCurrent>High[i+6] && dCurrent>High[i-1] && dCurrent>High[i-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[i]=dCurrent;
           }
        }
     }  
//-----------------------------------------------------------------------------------------                                    
      //----Fractals down
     
   if(MA_Long>High[i] && MA_Short>High[i] && MA_Final>High[i])
     {        
      bFound=false;
      tCurrent= Time[i];
      dCurrent=Low[i];
      if(dCurrent<Low[i+1] && dCurrent<Low[i+2] && dCurrent<Low[i-1] && dCurrent<Low[i-2])
        {
         bFound=true;
         ExtDownFractalsBuffer[i]=dCurrent;
         DrawArrow(tCurrent,NormalizeDouble(dCurrent-(2*spread)*Point, Digits),5,clrLimeGreen);
        }
      //----6 bars Fractal
      if(!bFound && (Bars-i-1)>=3)
        {
         if(dCurrent==Low[i+1] && dCurrent<Low[i+2] && dCurrent<Low[i+3] &&
            dCurrent<Low[i-1] && dCurrent<Low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
           }                      
        }         
      //----7 bars Fractal
      if(!bFound && (Bars-i-1)>=4)
        {   
         if(dCurrent<=Low[i+1] && dCurrent==Low[i+2] && dCurrent<Low[i+3] && dCurrent<Low[i+4] &&
            dCurrent<Low[i-1] && dCurrent<Low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
           }                      
        }  
      //----8 bars Fractal                          
      if(!bFound && (Bars-i-1)>=5)
        {   
         if(dCurrent<=Low[i+1] && dCurrent==Low[i+2] && dCurrent==Low[i+3] && dCurrent<Low[i+4] && dCurrent<Low[i+5] && 
            dCurrent<Low[i-1] && dCurrent<Low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
           }                      
        } 
      //----9 bars Fractal                                        
      if(!bFound && (Bars-i-1)>=6)
        {   
         if(dCurrent<=Low[i+1] && dCurrent==Low[i+2] && dCurrent<=Low[i+3] && dCurrent==Low[i+4] && dCurrent<Low[i+5] && 
            dCurrent<Low[i+6] && dCurrent<Low[i-1] && dCurrent<Low[i-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[i]=dCurrent;
           }                      
        } 
     }                                   
      i--;
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//-------------------------------------------------------------------------------------------  
void DrawArrow(datetime x1, double vPrice, int vcode, color vcolor)
{//DrawArrow(Time[shift],Close[shift],200,Aqua);
 //if (!Draw_Arrow) return;
 string label = "ArrowCodeFractals - "+DoubleToStr(x1, 0);
 //ObjectDelete(label);
 ObjectCreate(label, OBJ_ARROW, 0, x1, vPrice);
 ObjectSet(label, OBJPROP_ARROWCODE, vcode);
 ObjectSet(label, OBJPROP_COLOR, vcolor);
 }