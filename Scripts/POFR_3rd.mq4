//+------------------------------------------------------------------+
//|                                        YBR_Pending_Order_3rd.mq4 |
//|                                                  Andrey Vasiliev |
//|                                                  andrey-fx@bk.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Vasiliev"
#property link      "andrey-fx@bk.ru"
#property strict
#property strict
#include <FR_UP.mqh>
#include <FR_DOWN.mqh>
//#include <Fractal_UPSL.mqh>
//#include <Fractal_DownSL.mqh>
double MS_Price=WindowPriceOnDropped();             // Открывает ордер по указателю мыши
//double SL_S=NormalizeDouble(MS_Price+100*Point,Digits);                         // Стоп-лосс в 100 пунктов SELL
double TP_S=NormalizeDouble(MS_Price-250*Point,Digits);                          // Тейк-Профит в 100 пунктов SELL
//double SL_B = NormalizeDouble(MS_Price - 100*Point, Digits);
double TP_B = NormalizeDouble(MS_Price + 250*Point, Digits);
extern double Lot=0.09;
int spread=NormalizeDouble((Ask-Bid)/Point, Digits);  //EurUsd=2, GbpUsd=3, Gold=5, Silver=5, UsjJpy=3, GBPCHF=7, UsdChf=3, EurJpy=3, UsdCad=4, GbpJpy=7, AudUsd=3
int open_ticket;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

   if(MS_Price<Bid)
     {
      int c=4;
      int o=1;
      while (Fractals_Down(o)==false)
         { 
            o++; // look for the nearest fractal up)
         }
      while(Fractals_Up(c)==false)
        { //look for the nearest fractal down
         c++;
        }
      double SLS=NormalizeDouble(High[c]+(2*spread)*Point,Digits);    //order stop-loss
      open_ticket=OrderSend(Symbol(),OP_SELLSTOP,Lot,NormalizeDouble(Low[o] - spread*Point, Digits),3,SLS,TP_S); // open order
                              

      Comment("Order - ",open_ticket);
     }

   if(MS_Price>Bid)
     {
      int c=4;
      int o=1;
      while (Fractals_Up(o)==false)
         { 
            o++; // look for the nearest fractal up)
         }
       while(Fractals_Down(c)==false)
           { //look for the nearest fractal down
            c++;
           }
        
         double SLB = NormalizeDouble(Low[c] - spread * Point, Digits);    //order stop-loss
         open_ticket=OrderSend(Symbol(),OP_BUYSTOP,Lot,NormalizeDouble(High[o] + (2*spread)*Point, Digits),3,SLB,TP_B); // open order

      Comment("Order - ",open_ticket);
     }

   int Error=GetLastError();

   Alert("Order accepted");
//---
   return;
  }
//+------------------------------------------------------------------+