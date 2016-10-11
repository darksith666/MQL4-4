//+------------------------------------------------------------------+
//|                                              YBR_Fractals_UP.mq4 |
//|                                                  Andrey Vasiliev |
//|                                                  andrey-fx@bk.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Vasiliev"
#property link      "andrey-fx@bk.ru"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fractals_Up(int i)

  {
   double MA_Long,MA_Short,MA_Final, dCurrent;
   bool bFound;

    MA_Long=iMA(NULL,0,50,25,MODE_SMA,PRICE_HIGH,i);
   MA_Short=iMA(NULL,0,50,25,MODE_SMA,PRICE_LOW,i);
   MA_Final=iMA(NULL,0,200,200,MODE_SMMA,PRICE_MEDIAN,i);

   if(MA_Long>Low[i] || MA_Short>Low[i] || MA_Final>Low[i]) //странная логика
     {
      return(false);
     }
//----Fractals up

   bFound=false;
   dCurrent=High[i];
   if(dCurrent>High[i+1] && dCurrent>High[i+2] && dCurrent>High[i-1] && dCurrent>High[i-2])
     {
      bFound=true;
     }
//----6 bars Fractal
   if(!bFound && (Bars-i-1)>=3)
     {
      if(dCurrent==High[i+1] && dCurrent>High[i+2] && dCurrent>High[i+3] && 
         dCurrent>High[i-1] && dCurrent>High[i-2])
        {
         bFound=true;
        }
     }
//----7 bars Fractal
   if(!bFound && (Bars-i-1)>=4)
     {
      if(dCurrent>=High[i+1] && dCurrent==High[i+2] && dCurrent>High[i+3] && dCurrent>High[i+4] && 
         dCurrent>High[i-1] && dCurrent>High[i-2])
        {
         bFound=true;
        }
     }
//----8 bars Fractal                          
   if(!bFound && (Bars-i-1)>=5)
     {
      if(dCurrent>=High[i+1] && dCurrent==High[i+2] && dCurrent==High[i+3] && dCurrent>High[i+4] && dCurrent>High[i+5] && 
         dCurrent>High[i-1] && dCurrent>High[i-2])
        {
         bFound=true;
        }
     }
//----9 bars Fractal                                        
   if(!bFound && (Bars-i-1)>=6)
     {
      if(dCurrent>=High[i+1] && dCurrent==High[i+2] && dCurrent>=High[i+3] && dCurrent==High[i+4] && dCurrent>High[i+5] && 
         dCurrent>High[i+6] && dCurrent>High[i-1] && dCurrent>High[i-2])
        {
         bFound=true;
        }
     }
   return(bFound);
  }

//+------------------------------------------------------------------+
