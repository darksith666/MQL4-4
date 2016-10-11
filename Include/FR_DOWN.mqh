//+------------------------------------------------------------------+
//|                                            YBR_Fractals_Down.mq4 |
//|                                                  Andrey Vasiliev |
//|                                                  andrey-fx@bk.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Vasiliev"
#property link      "andrey-fx@bk.ru"


bool Fractals_Down(int i)

  {
   double MA_Long,MA_Short,MA_Final,dCurrent;
   bool bFound;

   MA_Long=iMA(NULL,0,50,25,MODE_SMA,PRICE_HIGH,i);
   MA_Short=iMA(NULL,0,50,25,MODE_SMA,PRICE_LOW,i);
   MA_Final=iMA(NULL,0,200,200,MODE_SMMA,PRICE_MEDIAN,i);

   if(MA_Long<High[i] || MA_Short<High[i] || MA_Final<High[i])
     {
      return(false);
     }

   bFound=false;
   dCurrent=Low[i];
   if(dCurrent<Low[i+1] && dCurrent<Low[i+2] && dCurrent<Low[i-1] && dCurrent<Low[i-2])
     {
      bFound=true;
     }
//----6 bars Fractal
   if(!bFound && (Bars-i-1)>=3)
     {
      if(dCurrent==Low[i+1] && dCurrent<Low[i+2] && dCurrent<Low[i+3] && 
         dCurrent<Low[i-1] && dCurrent<Low[i-2])
        {
         bFound=true;
        }
     }
//----7 bars Fractal
   if(!bFound && (Bars-i-1)>=4)
     {
      if(dCurrent<=Low[i+1] && dCurrent==Low[i+2] && dCurrent<Low[i+3] && dCurrent<Low[i+4] && 
         dCurrent<Low[i-1] && dCurrent<Low[i-2])
        {
         bFound=true;
        }
     }
//----8 bars Fractal                          
   if(!bFound && (Bars-i-1)>=5)
     {
      if(dCurrent<=Low[i+1] && dCurrent==Low[i+2] && dCurrent==Low[i+3] && dCurrent<Low[i+4] && dCurrent<Low[i+5] && 
         dCurrent<Low[i-1] && dCurrent<Low[i-2])
        {
         bFound=true;
        }
     }
//----9 bars Fractal                                        
   if(!bFound && (Bars-i-1)>=6)
     {
      if(dCurrent<=Low[i+1] && dCurrent==Low[i+2] && dCurrent<=Low[i+3] && dCurrent==Low[i+4] && dCurrent<Low[i+5] && 
         dCurrent<Low[i+6] && dCurrent<Low[i-1] && dCurrent<Low[i-2])
        {
         bFound=true;
        }
     }

   return(bFound);
  }
//+------------------------------------------------------------------+
