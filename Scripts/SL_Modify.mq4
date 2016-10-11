//+------------------------------------------------------------------+
//|                                                     SL Mause.mq4 |
//|                                                 Copyright © 2012 |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012"
#property link      "http://cmillion.narod.ru"
extern bool    comment           = true;  //выводить информацию на экран
//+------------------------------------------------------------------+
int start()
  {
   int Ticket;
   double value = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("Скрипт выставления SL ",DoubleToStr(value,Digits)," старт ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   RefreshRates();
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      
      Ticket = OrderTicket();
      if(OrderType()==OP_BUY)     
      if(value<Ask) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value,OrderTakeProfit() ,OrderExpiration(),White))
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," BUY ордеру ",Ticket);
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс BUY ордеру ",Ticket);
      }
      
      if(OrderType()==OP_SELL)
      if(value>Bid) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White))   
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," SELL ордеру ",Ticket);
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс SELL ордеру ",Ticket);
      }
         
      /*if((OrderType()==OP_BUYSTOP) || (OrderType()==OP_BUYLIMIT))     
      if(value<OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White)) 
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," отложенному BUY  ордеру ",Ticket);
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс отложенному BUY ордеру ",Ticket);
      }
       
      if((OrderType()==OP_SELLSTOP) || (OrderType()==OP_SELLLIMIT))
      if(value>OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White))                
            txt = StringConcatenate(txt,"\nВыставлен стоплосс ",DoubleToStr(value,Digits)," отложенному SELL ордеру ",Ticket);
         else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления стоплосс отложенному SELL ордеру ",Ticket);
      } */
      if (comment) Comment(txt);
   }   
  // if (comment) Comment(txt,"\nСкрипт закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
  }
//+------------------------------------------------------------------+