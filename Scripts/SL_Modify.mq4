//+------------------------------------------------------------------+
//|                                                     SL Mause.mq4 |
//|                                                 Copyright � 2012 |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012"
#property link      "http://cmillion.narod.ru"
extern bool    comment           = true;  //�������� ���������� �� �����
//+------------------------------------------------------------------+
int start()
  {
   int Ticket;
   double value = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("������ ����������� SL ",DoubleToStr(value,Digits)," ����� ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
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
            txt = StringConcatenate(txt,"\n��������� �������� ",DoubleToStr(value,Digits)," BUY ������ ",Ticket);
         else txt = StringConcatenate(txt,"\n������ ",GetLastError()," ����������� �������� BUY ������ ",Ticket);
      }
      
      if(OrderType()==OP_SELL)
      if(value>Bid) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White))   
            txt = StringConcatenate(txt,"\n��������� �������� ",DoubleToStr(value,Digits)," SELL ������ ",Ticket);
         else txt = StringConcatenate(txt,"\n������ ",GetLastError()," ����������� �������� SELL ������ ",Ticket);
      }
         
      /*if((OrderType()==OP_BUYSTOP) || (OrderType()==OP_BUYLIMIT))     
      if(value<OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White)) 
            txt = StringConcatenate(txt,"\n��������� �������� ",DoubleToStr(value,Digits)," ����������� BUY  ������ ",Ticket);
         else txt = StringConcatenate(txt,"\n������ ",GetLastError()," ����������� �������� ����������� BUY ������ ",Ticket);
      }
       
      if((OrderType()==OP_SELLSTOP) || (OrderType()==OP_SELLLIMIT))
      if(value>OrderOpenPrice()) 
      {
         if (OrderModify(Ticket,OrderOpenPrice(),value, OrderTakeProfit(),OrderExpiration(),White))                
            txt = StringConcatenate(txt,"\n��������� �������� ",DoubleToStr(value,Digits)," ����������� SELL ������ ",Ticket);
         else txt = StringConcatenate(txt,"\n������ ",GetLastError()," ����������� �������� ����������� SELL ������ ",Ticket);
      } */
      if (comment) Comment(txt);
   }   
  // if (comment) Comment(txt,"\n������ �������� ���� ������ ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
  }
//+------------------------------------------------------------------+