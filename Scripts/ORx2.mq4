//+------------------------------------------------------------------+
//|                                        YBR_Open_Order_Double.mq4 |
//|                                                  Andrey Vasiliev |
//|                                                  andrey-fx@bk.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Vasiliev"
#property link      "andrey-fx@bk.ru"


#property strict
#include <FR_UP.mqh>
#include <FR_DOWN.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
double MS_Price=WindowPriceOnDropped(),
TP_B = NormalizeDouble(Ask + 250*Point, Digits),
TP_S = NormalizeDouble(Bid - 250*Point, Digits),
Lot=0.06;
int spread=NormalizeDouble((Ask-Bid)/Point, Digits);  //EurUsd=2, GbpUsd=3, Gold=5, Silver=5, UsjJpy=3, GBPCHF=7, UsdChf=3, EurJpy=3, UsdCad=4, GbpJpy=7, AudUsd=3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {

   if(MS_Price>Bid)
     {
      int c=4;
      while(Fractals_Down(c)==false)
        { //look for the nearest fractal down
         c++;
        }
      Comment("MS=",MS_Price,"; Bid=",Bid);
      double SLB=NormalizeDouble(Low[c]-spread*Point,Digits);    //order stop-loss
      int open_ticket=OrderSend(Symbol(),OP_BUY,Lot,Ask,3,SLB,TP_B);
      Alert("Order Buy");
     }

   if(MS_Price<Bid)
     {
      int c=4;
      while(Fractals_Up(c)==false)
        { //look for the nearest fractal down
         c++;
        }
      Comment("MS=",MS_Price,"; Bid=",Bid);
      double SLS=NormalizeDouble(High[c]+(2*spread)*Point,Digits);    //order stop-loss      
      int open_ticket=OrderSend(Symbol(),OP_SELL,Lot,Bid,3,SLS,TP_S);
      Alert("Order Sell");
     }

   Alert(GetLastError());
//---
   return;
  }
