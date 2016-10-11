//+------------------------------------------------------------------+
//|                                                  MeasureFIBO.mq4 |
//|                                               ПавелИванович(api) |
//|                                              p231970@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "ПавелИванович(api)"
#property link      "p231970@hotmail.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
double fibo[]={0,0.034,0.056,0.09,0.146,0.236,0.382,0.5,0.618,0.764,0.854,0.91,0.944,0.966,1,1.236,1.618,2,2.618,4,4.236,6.854,11.09,-0.236,-0.618,-1,-1.618,-3,-3.236,-5.854,-10.09};
int start()
{
   int x = WindowFirstVisibleBar()-WindowBarsPerChart()-1;
   int p1 = iHighest(NULL,0,MODE_HIGH,WindowBarsPerChart()-1,x);
   int p2 = iLowest(NULL,0,MODE_LOW,WindowBarsPerChart()-1,x);
   datetime t1 = iTime(NULL,0,p1); 
   datetime t2 = iTime(NULL,0,p2);
   x = ((GetTickCount()/1000)%86400);
   string name="FIBO_"+x;
   while(ObjectFind(name)!=-1)
   {
      x++;
      name="FIBO_"+x;
   }
   ObjectCreate(name,OBJ_FIBO,0,t1,iHigh(NULL,0,p1),t2,iLow(NULL,0,p2));
   ObjectSet(name,OBJPROP_FIBOLEVELS,ArraySize(fibo));
   for(int i=0;i<ArraySize(fibo);i++)
   {
      ObjectSet(name,OBJPROP_FIRSTLEVEL+i,fibo[i]);
      if(fibo[i]>=0)
      {
         if(fibo[i]<=1 && fibo[i]!=0.5)
            ObjectSetFiboDescription(name,i,DoubleToStr(fibo[i]*100,1)+"(" + DoubleToStr((1-fibo[i])*100,1) + ")%% %$");
         else
            ObjectSetFiboDescription(name,i,DoubleToStr(fibo[i]*100,1)+"%% %$");
      }else
         ObjectSetFiboDescription(name,i,DoubleToStr((1-fibo[i])*100,1)+"%% %$");
   }
   return(0);
}
//+------------------------------------------------------------------+