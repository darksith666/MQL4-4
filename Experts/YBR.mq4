//+------------------------------------------------------------------+
//|                                                          YBR.mq4 |
//|                                                  Andrey Vasiliev |
//|                                                  andrey-fx@bk.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Vasiliev"
#property link      "andrey-fx@bk.ru"



#include <FR_UP.mqh>                   //include fractals up
#include <FR_DOWN.mqh>                 //include fractals down
//#include <Fractal_UPSL.mqh>            //include stop-loss fractals UP
//#include <Fractal_DownSL.mqh>          //include stop-loss fractals Down

//--------------lots voulume---------------------
double  Lot=0.01;
int spread=NormalizeDouble((Ask-Bid)/Point, Digits);  //EurUsd=2, GbpUsd=3, Gold=5, Silver=5, UsjJpy=3, GBPCHF=7, UsdChf=3, EurJpy=3, UsdCad=4, GbpJpy=7, AudUsd=3
  
//--------------error----------------------------
bool isFatalError=false;
//--------------tickets--------------------------
int buyTicket=0,sellTicket=0;
//double pointMultiplier=1; //10 - for alpari, 1 - fibo forex
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   RefreshRates();

   return 0;
  }
//-----------------Expert Starts---------------------------
int start()
  {
Comment ("Spread -  ", spread);

/*  if(isFatalError)
     {
      return -1;
     }
*/
   findOrders();

//try open initial pending orders
   tryOpenBuy();
   tryOpenSell();
//try modify pending orders
   tryModifyPendingBuy();
   tryModifyPendingSell();
//try modify opened orders
   tryModifyOpenSell();
   tryModifyOpenBuy();
//Move Stop Loss to NULL
//   tryModifySellStopLossNull();
//   tryModifyOpenBuyStopLossNULL();
   
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool tryModifyPendingSell()
  {
   if(sellTicket!=0)
     { //if we have an open buy order
      if(OrderSelect(sellTicket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_SELLSTOP)
           {

            if(Fractals_Down(3))
              {
               double POS=NormalizeDouble(Low[3]-spread*Point,Digits);   //pending order sell

               if(OrderOpenPrice()!=POS)
                 {
                  Print("Attempting to modify existing sell order ",sellTicket," with new price ",POS);

                  if(!OrderModify(sellTicket,POS,OrderStopLoss(),OrderTakeProfit(),0,clrLimeGreen))
                    {
                     Print("Error modifying pending sell order on new price");
                     PrintLastError();
                     isFatalError=true;

                     return false;
                    }

                  return true;
                 }
              }
            else if(Fractals_Up(3))
              {
               double SLS=NormalizeDouble(High[3]+(2*spread)*Point,Digits);      //order stop-loss

               Print("Attempting to modify existing sell order ",sellTicket," with new stop loss ",SLS);

               if(!OrderModify(sellTicket,OrderOpenPrice(),SLS,OrderTakeProfit(),0,clrLimeGreen))
                 {
                  Print("Error modifying pending sell order on new stop loss");
                  PrintLastError();
                  isFatalError=true;

                  return false;
                 }

               return true;
              }
           }
        }
      else
        {
         Print("Error selecting order");
         PrintLastError();
         isFatalError=true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tryModifyPendingBuy()
  {
   if(buyTicket!=0)
     { //if we have an open buy order
      if(OrderSelect(buyTicket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_BUYSTOP)
           {

            if(Fractals_Up(3))
              {
               double POB=NormalizeDouble(High[3]+(2*spread)*Point,Digits);   //pending order buy

               if(OrderOpenPrice()!=POB)
                 {
                  Print("Attempting to modify existing buy order ",buyTicket," with new price ",POB);

                  if(!OrderModify(buyTicket,POB,OrderStopLoss(),OrderTakeProfit(),0,clrLimeGreen))
                    {
                     Print("Error modifying pending buy order on new price");
                     PrintLastError();
                     isFatalError=true;

                     return false;
                    }
                 }

               return true;
              }
            else if(Fractals_Down(3))
              {
               double SLB=NormalizeDouble(Low[3]-spread*Point,Digits);    //order stop-loss

               Print("Attempting to modify existing buy order ",buyTicket," with new stop loss ",SLB);

               if(!OrderModify(buyTicket,OrderOpenPrice(),SLB,OrderTakeProfit(),0,clrLimeGreen))
                 {
                  Print("Error modifying pending buy order on new stop loss");
                  PrintLastError();
                  isFatalError=true;

                  return false;
                 }

               return true;
              }
           }
        }
      else
        {
         Print("Error selecting order");
         PrintLastError();
         isFatalError=true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tryOpenSell()
  {
   if(sellTicket==0)
     { //we dont have any sell orders
      if(Fractals_Down(3))
        {

         int c=4; //starting from candle 4 
         while(Fractals_Up(c)==false)
           { //Look for the nearest fractal down
            c++;
           }

         double POS = NormalizeDouble(Low[3] - spread *  Point,Digits);       //pending order sell
         double SLS = NormalizeDouble(High[c] + (2*spread)*Point, Digits);      //order stop-loss
         double TPS = NormalizeDouble(Low[3] - 150*Point,Digits);
         Print("Opening new pending sell order with price ",POS," and stop loss ",SLS);

         sellTicket=OrderSend(NULL,OP_SELLSTOP,Lot,POS,3,SLS,TPS,NULL,1002);  // Pending order Sell with Magic Number
         if(sellTicket<0)
           {
            Print("Failed opening pending sell order");
            PrintLastError();
            isFatalError=true;
           }

         return true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tryOpenBuy()
  {
   if(buyTicket==0)
     { //we dont have any buy orders
      if(Fractals_Up(3))
        {

         int c=4; //starting from candle 4 
         while(Fractals_Down(c)==false)
           { //look for the nearest fractal down
            c++;
           }

         double POB = NormalizeDouble(High[3] + (2*spread)*Point, Digits);   //pending order buy
         double SLB = NormalizeDouble(Low[c] - spread * Point, Digits);    //order stop-loss
         double TPB=NormalizeDouble(High[3]+150*Point,Digits);                                  //order take-profit

         Print("Opening new pending buy order with price ",POB," and stop loss ",SLB);

         buyTicket=OrderSend(NULL,OP_BUYSTOP,Lot,POB,3,SLB,TPB,NULL,1001); // Pending order Buy with Magic Number
         if(buyTicket<0)
           {
            Print("Failed opening pending buy order");
            PrintLastError();
            isFatalError=true;
           }

         return true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void findOrders()
  {
   buyTicket=0; sellTicket=0;
   for(int i=0; i<OrdersTotal(); i++)
     {

      if(OrderSelect(i,SELECT_BY_POS)==true)
        { //check the type of orders
         if(StringCompare(OrderSymbol(),Symbol())!=0)
           {
            continue; //skip orders from different charts
           }

         int type=OrderType();

         if(buyTicket==0 && (type==OP_BUY || type==OP_BUYSTOP))
           {
            buyTicket=OrderTicket();
            Print("Found existing buy ticket ",buyTicket);
           }

         if(sellTicket==0 && (type==OP_SELL || type==OP_SELLSTOP))
           {
            sellTicket=OrderTicket();
            Print("Found existing sell ticket ",sellTicket);
           }

        }
      else
        {
         PrintLastError();
         isFatalError=true;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintLastError()
  {
   Print("Last error: ",GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+-+


bool tryModifyOpenSell()
  {
   if(sellTicket!=0)
     { //if we have an open sell order
      if(OrderSelect(sellTicket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_SELL)
           {

            if(Fractals_Up(3))
              {
               double SLS=NormalizeDouble(High[3]+(2*spread)*Point,Digits);      //order stop-loss

               Print("Attempting to modify existing sell order ",sellTicket," with new stop loss ",SLS);

               if(!OrderModify(sellTicket,OrderOpenPrice(),SLS,OrderTakeProfit(),0,clrYellowGreen))
                 {
                  Print("Error modifying pending sell order on new stop loss");
                  PrintLastError();
                  isFatalError=true;

                  return false;
                 }

               return true;
              }
           }
        }
      else
        {
         Print("Error selecting order");
         PrintLastError();
         isFatalError=true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tryModifyOpenBuy()
  {
   if(buyTicket!=0)
     { //if we have an open buy order
      if(OrderSelect(buyTicket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_BUY)
           {

            if(Fractals_Down(3))
              {
               double SLB=NormalizeDouble(Low[3]-spread*Point,Digits);    //order stop-loss

               Print("Attempting to modify existing buy order ",buyTicket," with new stop loss ",SLB);

               if(!OrderModify(buyTicket,OrderOpenPrice(),SLB,OrderTakeProfit(),0,clrYellowGreen))
                 {
                  Print("Error modifying pending buy order on new stop loss");
                  PrintLastError();
                  isFatalError=true;

                  return false;
                 }

               return true;
              }
           }
        }
      else
        {
         Print("Error selecting order");
         PrintLastError();
         isFatalError=true;
        }
     }

   return false;
  }
bool tryModifySellStopLossNull()
  {
   if(sellTicket!=0)
     { //if we have an open sell order
      if(OrderSelect(sellTicket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_SELL)
           {

            if(NormalizeDouble(OrderOpenPrice() -(150)*Point,Digits)==Ask && !Fractals_Up(3)) //modify S/L to NULL
              {
               do
                 {
                  double SLS=NormalizeDouble(OrderOpenPrice()-1*Point,Digits);

                  if(!OrderModify(sellTicket,OrderOpenPrice(),SLS,OrderTakeProfit(),0,clrYellowGreen))
                    {
                     Print("Error modifying pending sell order on new stop loss");
                     PrintLastError();
                     isFatalError=true;

                     return false;
                    }
                  break;
                 }
               while(!Fractals_Down(3));

               return true;
              }

           }// end of OP_SELL
        }
      else
        {
         Print("Error selecting order");
         PrintLastError();
         isFatalError=true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tryModifyOpenBuyStopLossNULL()
  {
   if(buyTicket!=0)
     { //if we have an open buy order
      if(OrderSelect(buyTicket,SELECT_BY_TICKET))
        {
         if(OrderType()==OP_BUY)
           {

            if(NormalizeDouble(OrderOpenPrice()+150*Point,Digits)==Bid && !Fractals_Down(3)) //modiy S/L to NULL
              {
               do
                 {

                  double SLB=NormalizeDouble(OrderOpenPrice()+1*Point,Digits);

                  if(!OrderModify(buyTicket,OrderOpenPrice(),SLB,OrderTakeProfit(),0,clrYellowGreen))
                    {
                     Print("Error modifying NULL stop loss");
                     PrintLastError();
                     isFatalError=true;

                     return false;
                    }
                  break;
                 }
               while(!Fractals_Down(3));

               return true;
              }
           }
        }
      else
        {
         Print("Error selecting order");
         PrintLastError();
         isFatalError=true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+/
//+------------------------------------------------------------------+/