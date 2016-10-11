//+------------------------------------------------------------------+
//|                                                      _SET_BU.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start(){
  int stlw=MarketInfo(Symbol(),MODE_STOPLEVEL);
  int spr =MarketInfo(Symbol(),MODE_SPREAD);  
  double prise=WindowPriceOnDropped();
  if(prise==0){
    Alert("Цена не определена!");
    return;
  } 
//----  
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
      if(OrderSymbol()==Symbol()){
        if(OrderCloseTime()==0){
          if(MathAbs(OrderOpenPrice()-prise)<spr*Point*2){
            int ticket=OrderTicket();
          }
        }  
      }
    }
  }
  if(ticket<1){
    Alert("ордер не найден!");
    return;  
  }
//----
  while(!IsStopped()){
    if(OrderSelect(ticket,SELECT_BY_TICKET)){
      if(OrderType()>1){Alert("Неверный тип ордера");return;}
      if(OrderCloseTime()!=0){Alert("ордер закрыт");return;}
      if(NormalizeDouble(OrderOpenPrice(),Digits)==NormalizeDouble(OrderStopLoss(),Digits)){Alert("БУ установлен");return;}
      if(OrderType()==0){  
        if(Bid-OrderOpenPrice()>stlw*Point){
          if(!OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue)){
            Alert("Ошибка установки БУ №",GetLastError());
            return;
          }else{PlaySound("expert.wav");}
        }else{
          RefreshRates();
          if(MathAbs(Bid-OrderOpenPrice())<2*Point){
            if(!OrderClose(ticket,OrderLots(),Bid,spr,Blue)){
              Print("Ошибка закрытия ордера BUY  №",GetLastError());
            }else{PlaySound("expert.wav");}
          }
        }
      }
      if(OrderType()==1){  
        if(OrderOpenPrice()-Ask>stlw*Point){
          if(!OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue)){
            Alert("Ошибка установки БУ №",GetLastError());
            return;
          }else{PlaySound("expert.wav");}
        }else{
          RefreshRates();
          if(MathAbs(Ask-OrderOpenPrice())<2*Point){
            if(!OrderClose(ticket,OrderLots(),Ask,spr,Blue)){
              Print("Ошибка закрытия ордера BUY  №",GetLastError());
            }else{PlaySound("expert.wav");}
          }
        }        
      }        
    }
  }
return;}
//+------------------------------------------------------------------+