
//////////////////////////////////////////////////////////////////////

#ifdef __MQL5__
//bool His =false;
//bool PositionOpened = false;

#define DoubleToStr DoubleToString
#define TimeToStr TimeToString
#define StrToTime StringToTime 

int Digits=_Digits;
double High[],Low[],Open[],Close[];
double Ask,Bid;
datetime Time[];

extern int ArrayMax=MathMax(shift1,shift2)+1;


#define ObjectSetText(x, y, z,a, b) \      
      ObjectSetInteger(0,x,OBJPROP_COLOR,b); \
      ObjectSetString(0,x,OBJPROP_TEXT, y); \
      ObjectSetString(0,x,OBJPROP_FONT,a); \
      ObjectSetInteger(0,x,OBJPROP_FONTSIZE,z); 

int TimeMinute(datetime T){
   MqlDateTime dow;
   TimeToStruct(T,dow);
   return(dow.min);
}

int TimeHour(datetime T){
   MqlDateTime dow;
   TimeToStruct(T,dow);
   return(dow.hour);
}

int TimeDayOfWeek(datetime T){
   MqlDateTime dow;
   TimeToStruct(T,dow);
   return(dow.day_of_week);
}

double AccountBalance(){
   return(0);
}

#define MODE_POINT 11
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25

double MarketInfo(string symbol,int type){
   return(0);
}

string OrderSymbol(){
   return(OrderGetString(ORDER_SYMBOL));
}
int OrderMagicNumber(){
   return(OrderGetInteger(ORDER_MAGIC));
}
int OrderType(){
   return(OrderGetInteger(ORDER_TYPE));
}
double OrderOpenPrice(){
   return(OrderGetDouble(ORDER_PRICE_OPEN));
}
double OrderClosePrice(){
   return(0);//need to modified需要修改
}
double OrderProfit(){
   return(PositionGetDouble(POSITION_PROFIT));//need to modified需要修改
}
double OrderStopLoss(){
   return(OrderGetDouble(ORDER_SL));
}
double OrderTakeProfit(){
   return(OrderGetDouble(ORDER_TP));
}
double OrderLots(){
   return(OrderGetDouble(ORDER_VOLUME_CURRENT));
}
bool RefreshRates(){
   return(true);//
}
bool IsTradeAllowed(){
   return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED));
}
int OrdersHistoryTotal(){
   //His=true;
   return(HistoryOrdersTotal());
}
datetime OrderOpenTime(){
   return(OrderGetInteger(ORDER_TIME_DONE));
}
datetime OrderCloseTime(){
   return(OrderGetInteger(ORDER_TIME_DONE));//need to modified需要修改
}

int OrderTicket(){
  return(OrderGetInteger(ORDER_TICKET));
}

#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
bool OrderSelect(int index,int select){
   //His=false;
   if( select==SELECT_BY_POS) return(OrderSelect(OrderGetTicket(index)));   
   else if( select==SELECT_BY_TICKET) return(OrderSelect(index));
   else return(false);
}
#define MODE_TRADES 0
#define MODE_HISTORY 1
bool OrderSelect(int index,int select,int pool){
   if( pool == MODE_HISTORY && select==SELECT_BY_POS)  return(HistoryOrderSelect(HistoryOrderGetTicket(index))); //need to modified需要修改
   else if( pool == MODE_HISTORY && select==SELECT_BY_TICKET)  return(HistoryOrderSelect(index)); //need to modified需要修改
   else if( pool==MODE_TRADES && select==SELECT_BY_POS) {//His=false;
            return(OrderSelect(OrderGetTicket(index)));}   
   else if( pool==MODE_TRADES && select==SELECT_BY_TICKET) {//His=false;
            return(OrderSelect(index));}
   else return(false);
}

#define OP_BUY ORDER_TYPE_BUY
#define OP_SELL ORDER_TYPE_SELL
#define OP_BUYSTOP ORDER_TYPE_BUY_STOP
#define OP_SELLSTOP ORDER_TYPE_SELL_STOP
#define OP_BUYLIMIT ORDER_TYPE_BUY_LIMIT
#define OP_SELLLIMIT ORDER_TYPE_SELL_LIMIT
MqlTradeRequest  request;      // query structure 
MqlTradeResult   result;        // structure of the answer 

int  OrderSend( 
   string   symbol,              // symbol 
   int      cmd,                 // operation 
   double   volume,              // volume 
   double   price,               // price 
   int      slippage,            // slippage 
   double   stoploss,            // stop loss 
   double   takeprofit,          // take profit 
   string   comment=NULL,        // comment 
   int      magic=0,             // magic number 
   datetime expiration=0,        // pending order expiration 
   color    arrow_color=clrNONE  // color 
   ){
   request.symbol=symbol;
   request.type=cmd;
   if(cmd==OP_BUY ||cmd==OP_SELL) request.action=TRADE_ACTION_DEAL;
   else request.action=TRADE_ACTION_PENDING;
   request.volume=volume;
   request.price=price;
   request.deviation=slippage;
   request.sl=stoploss;
   request.tp=takeprofit;
   request.comment=comment;
   request.magic=magic;
   request.expiration=expiration;
   OrderSend(request,result);   
   return(result.order);
}

bool  OrderClose( 
   int        ticket,      // ticket 
   double     lots,        // volume 
   double     price,       // close price 
   int        slippage    // slippage 
   ){
   request.order=ticket;
   request.action=TRADE_ACTION_DEAL;   
   request.volume=lots;
   request.price=price;
   request.deviation=slippage;
   if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY) request.type=ORDER_TYPE_SELL;
   if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL) request.type=ORDER_TYPE_BUY;
   return(OrderSend(request,result) );
}

bool OrderDelete(int ticket){
   request.action=TRADE_ACTION_REMOVE ;
   request.order=ticket;
   return(OrderSend(request,result));
}

bool  OrderModify( 
   int        ticket,      // ticket 
   double     price,       // price 
   double     stoploss,    // stop loss 
   double     takeprofit,  // take profit 
   datetime   expiration,  // expiration 
   color      arrow_color  // color 
   ){
   request.order=ticket;
   request.price=price;
   request.sl=stoploss;
   request.tp=takeprofit;
   request.expiration=expiration;
   return(OrderSend(request,result));
}

bool  OrderModify( 
   int        ticket,      // ticket 
   double     price,       // price 
   double     stoploss,    // stop loss 
   double     takeprofit,  // take profit 
   datetime   expiration  // expiration 
   ){
   request.order=ticket;
   request.price=price;
   request.sl=stoploss;
   request.tp=takeprofit;
   request.expiration=expiration;
   return(OrderSend(request,result));
}

//////////////////////////////////////

int OnTick(void){

   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID); 

   int copied = CopyHigh(Symbol(), Period() ,0,ArrayMax,High);
   copied = CopyLow(Symbol(), Period() ,0,ArrayMax,Low);
   copied = CopyLow(Symbol(), Period() ,0,ArrayMax,Close);
   copied = CopyLow(Symbol(), Period() ,0,ArrayMax,Open);

   CopyTime(Symbol(),Period(),0,1,Time);

#else
int start() {
#endif





//////////////////////////////////////////////////////////////////////////////////////////



 MQL5参考  / 标准常量，列举和架构  / 交易常数 / 交易操作类型  НазадВперед  
 


交易操作类型

使用OrderSend()函数通过向开仓位置发送命令进行交易，和放置、修改或删除待办订单命令一样。每个交易命令引用要求操作类型。交易操作在ENUM_TRADE_REQUEST_ACTIONS项目中描述。

ENUM_TRADE_REQUEST_ACTIONS



标识符
 
描述
 

TRADE_ACTION_DEAL
 
为规定参数的立即执行放置交易命令（市场命令）
 

TRADE_ACTION_PENDING
 
在制定环境下执行放置交易命令（待办订单）
 

TRADE_ACTION_SLTP
 
修改折仓并取走开仓利润值
 

TRADE_ACTION_MODIFY
 
修改先前放置的命令参量
 

TRADE_ACTION_REMOVE
 
删除先前放置的待办订单命令
 

TRADE_ACTION_CLOSE_BY
 
通过反向持仓来平仓
 

打开买入持仓TRADE_ACTION_DEAL 交易操作的示例：



#define EXPERT_MAGIC 123456   // EA交易的幻数
//+------------------------------------------------------------------+
//| 打开买入持仓                                                       |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- 请求的参数
   request.action   =TRADE_ACTION_DEAL;                     // 交易操作类型
   request.symbol   =Symbol();                              // 交易品种
   request.volume   =0.1;                                   // 0.1手交易量 
   request.type     =ORDER_TYPE_BUY;                        // 订单类型
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // 持仓价格
   request.deviation=5;                                     // 允许价格偏差
   request.magic    =EXPERT_MAGIC;                          // 订单幻数
//--- 发送请求
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // 如果不能发送请求，输出错误代码
//--- 操作信息
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }
//+------------------------------------------------------------------+
 

 
打开卖出持仓TRADE_ACTION_DEAL 交易操作的示例：



#define EXPERT_MAGIC 123456   // EA交易的幻数
//+------------------------------------------------------------------+
//| 打开卖出持仓                                                       |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- 请求参数
   request.action   =TRADE_ACTION_DEAL;                     // 交易操作类型
   request.symbol   =Symbol();                              // 交易品种
   request.volume   =0.2;                                   // 0.2 手交易量
   request.type     =ORDER_TYPE_SELL;                       // 订单类型
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // 持仓价格
   request.deviation=5;                                     // 允许价格偏差
   request.magic    =EXPERT_MAGIC;                          // 订单幻数
//--- 发送请求
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // 如果不能发送请求，输出错误代码
//--- 操作信息
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }
//+------------------------------------------------------------------+
 

 
平仓TRADE_ACTION_DEAL 交易操作的示例：



#define EXPERT_MAGIC 123456   // EA交易的幻数
//+------------------------------------------------------------------+
//| 关闭全部持仓                                                       |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // 持仓数   
//--- 重做所有持仓
   for(int i=total-1; i>=0; i--)
     {
      //--- 订单的参数
      ulong  position_ticket=PositionGetTicket(i);                                      // 持仓价格
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // 交易品种 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // 小数位数
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // 持仓的幻数
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // 持仓交易量
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // 持仓类型
      //--- 输出持仓信息
      PrintFormat("#%I64u %s  %s  %.2f  %s [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  magic);
      //--- 如果幻数匹配
      if(magic==EXPERT_MAGIC)
        {
         //--- 归零请求和结果值
         ZeroMemory(request);
         ZeroMemory(result);
         //--- 设置操作参数
         request.action   =TRADE_ACTION_DEAL;        // 交易操作类型
         request.position =position_ticket;          // 持仓价格
         request.symbol   =position_symbol;          // 交易品种 
         request.volume   =volume;                   // 持仓交易量
         request.deviation=5;                        // 允许价格偏差
         request.magic    =EXPERT_MAGIC;             // 持仓幻数
         //--- 根据持仓类型设置价格和订单类型 
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         //--- 输出关闭信息
         PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- 发送请求
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
         //--- 操作信息   
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         //---
        }
     }
  }
//+------------------------------------------------------------------+
 

 
下挂单 TRADE_ACTION_PENDING 交易操作的示例：



#property description "Example of placing pending orders"
#property script_show_inputs
#define EXPERT_MAGIC 123456                             // EA交易的幻数
input ENUM_ORDER_TYPE orderType=ORDER_TYPE_BUY_LIMIT;   // 订单类型
//+------------------------------------------------------------------+
//| 下挂单                                                            |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- 下挂单的参数
   request.action   =TRADE_ACTION_PENDING;                             // 交易操作类型
   request.symbol   =Symbol();                                         // 交易品种
   request.volume   =0.1;                                              //0.1手交易量
   request.deviation=2;                                                // 允许价格偏差
   request.magic    =EXPERT_MAGIC;                                     // 订单幻数
   int offset = 50;                                                    // 以点数从当前价抵消下单
   double price;                                                       // 订单触动价
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);                // value of point
   int digits=SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);                // 小数位数 (精确度)
   //--- 检查操作类型
   if(orderType==ORDER_TYPE_BUY_LIMIT)
     {
      request.type     =ORDER_TYPE_BUY_LIMIT;                          // 订单类型
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;        // 持仓价格 
      request.price    =NormalizeDouble(price,digits);                 //正常开盘价 
     }
   else if(orderType==ORDER_TYPE_SELL_LIMIT)
     {
      request.type     =ORDER_TYPE_SELL_LIMIT;                          // order type
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point;         // 持仓价 
      request.price    =NormalizeDouble(price,digits);                  // 正常开盘价 
     }
   else if(orderType==ORDER_TYPE_BUY_STOP)
     {
      request.type =ORDER_TYPE_BUY_STOP;                                // 订单类型
      price        =SymbolInfoDouble(Symbol(),SYMBOL_ASK)+offset*point; // 开盘价 
      request.price=NormalizeDouble(price,digits);                      // 正常开盘价 
     }
   else if(orderType==ORDER_TYPE_SELL_STOP)
     {
      request.type     =ORDER_TYPE_SELL_STOP;                           // 订单类型
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point;         // 开盘价 
      request.price    =NormalizeDouble(price,digits);                  // 正常开盘价 
     }
   else Alert("This example is only for placing pending orders");   // 如果没有挂单被选择
//--- 发送请求
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());                 // 如果不能发送请求，输出错误代码
//--- 操作信息
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  }
//+------------------------------------------------------------------+
 

 
更改持仓止损和止赢值的 TRADE_ACTION_SLTP 交易操作的示例：



#define EXPERT_MAGIC 123456  // EA交易的幻数
//+------------------------------------------------------------------+
//| 更改持仓的止损和止赢                                                |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // 持仓数   
//--- 重做所有持仓
   for(int i=0; i<total; i++)
     {
      //--- 订单的参数
      ulong  position_ticket=PositionGetTicket(i);// 持仓价格
      string position_symbol=PositionGetString(POSITION_SYMBOL); // 交易品种 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // 小数位数
      ulong  magic=PositionGetInteger(POSITION_MAGIC); // 持仓的幻数
      double volume=PositionGetDouble(POSITION_VOLUME);    // 持仓交易量
      double sl=PositionGetDouble(POSITION_SL);  // 持仓止损
      double tp=PositionGetDouble(POSITION_TP);  // 持仓止赢
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
      //--- 输出持仓信息
      PrintFormat("#%I64u %s  %s  %.2f  %s  sl: %s  tp: %s  [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  DoubleToString(sl,digits),
                  DoubleToString(tp,digits),
                  magic);
      //--- 如果幻数匹配，不定义止损和止赢
      if(magic==EXPERT_MAGIC && sl==0 && tp==0)
        { 
         //--- 计算当前价格水平
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         int    stop_level=(int)SymbolInfoInteger(position_symbol,SYMBOL_TRADE_STOPS_LEVEL);
         double price_level;
         //--- 如果最小值被接受，那么当前平仓价的点数偏距不设置
         if(stop_level<=0)
            stop_level=150; // 设置当前平仓价的150点偏距
         else
            stop_level+=50; // 为了可靠性而设置偏距到(SYMBOL_TRADE_STOPS_LEVEL + 50) 点
 
         //--- 计算并凑整止损和止赢值
         price_level=stop_level*SymbolInfoDouble(position_symbol,SYMBOL_POINT);
         if(type==POSITION_TYPE_BUY)
           {
            sl=NormalizeDouble(bid-price_level,digits);
            tp=NormalizeDouble(ask+price_level,digits);
           }
         else
           {
            sl=NormalizeDouble(ask+price_level,digits);
            tp=NormalizeDouble(bid-price_level,digits);
           }
         //--- 归零请求和结果值
         ZeroMemory(request);
         ZeroMemory(result);
         //--- 设置操作参数
         request.action  =TRADE_ACTION_SLTP; // 交易操作类型
         request.position=position_ticket;   // 持仓价格
         request.symbol=position_symbol;     // 交易品种 
         request.sl      =sl;                // 持仓止损
         request.tp      =tp;                // 持仓止赢
         request.magic=EXPERT_MAGIC;         // 持仓的幻数
         //--- 输出更改信息
         PrintFormat("Modify #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- 发送请求
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
         //--- 操作信息   
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
     }
  }
//+------------------------------------------------------------------+
 

 
更改挂单价格水平的TRADE_ACTION_MODIFY 交易操作的示例：



#define EXPERT_MAGIC 123456  // EA交易的幻数
//+------------------------------------------------------------------+
//| 更改挂单                                                          |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   int total=OrdersTotal(); // 已下挂单的总数
//--- 重做所有已下的挂单
   for(int i=0; i<total; i++)
     {
      //--- 订单参数
      ulong  order_ticket=OrderGetTicket(i);                             // 订单价格
      string order_symbol=Symbol();                                      // 交易品种
      int    digits=(int)SymbolInfoInteger(order_symbol,SYMBOL_DIGITS);  // 小数位数
      ulong  magic=OrderGetInteger(ORDER_MAGIC);                         // 订单的幻数
      double volume=OrderGetDouble(ORDER_VOLUME_CURRENT);                // 订单的当前交易量
      double sl=OrderGetDouble(ORDER_SL);                                // 订单的当前止损
      double tp=OrderGetDouble(ORDER_TP);                                // 订单的当前止赢
      ENUM_ORDER_TYPE type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); // 订单类型
      int offset = 50;                                                   // 以点数从当前价抵消下单
      double price;                                                      // 订单触动价
      double point=SymbolInfoDouble(order_symbol,SYMBOL_POINT);          // 点值
      //--- 输出订单信息
      PrintFormat("#%I64u %s  %s  %.2f  %s  sl: %s  tp: %s  [%I64d]",
                  order_ticket,
                  order_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  DoubleToString(sl,digits),
                  DoubleToString(tp,digits),
                  magic);
      //--- 如果幻数匹配，不定义止损和止赢
      if(magic==EXPERT_MAGIC && sl==0 && tp==0)
        {
         request.action=TRADE_ACTION_MODIFY;                           // 交易操作类型
         request.order = OrderGetTicket(i);                            // 订单价格
         request.symbol   =Symbol();                                   // symbol
         request.deviation=5;                                          // 允许价格偏差
        //--- 根据持仓类型设置价格水平，订单的止损和止赢
         if(type==ORDER_TYPE_BUY_LIMIT)
           {
            price = SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point; 
            request.tp = NormalizeDouble(price+offset*point,digits);
            request.sl = NormalizeDouble(price-offset*point,digits);
            request.price    =NormalizeDouble(price,digits);                // 正常开盘价
           }
         else if(type==ORDER_TYPE_SELL_LIMIT)
           {
           price = SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point; 
            request.tp = NormalizeDouble(price-offset*point,digits);
            request.sl = NormalizeDouble(price+offset*point,digits);
            request.price    =NormalizeDouble(price,digits);                 // 正常开盘价
           }
         else if(type==ORDER_TYPE_BUY_STOP)
           {
           price = SymbolInfoDouble(Symbol(),SYMBOL_BID)+offset*point; 
            request.tp = NormalizeDouble(price+offset*point,digits);
            request.sl = NormalizeDouble(price-offset*point,digits);
            request.price    =NormalizeDouble(price,digits);                 // 正常开盘价
           }
         else if(type==ORDER_TYPE_SELL_STOP)
           {
           price = SymbolInfoDouble(Symbol(),SYMBOL_ASK)-offset*point; 
            request.tp = NormalizeDouble(price-offset*point,digits);
            request.sl = NormalizeDouble(price+offset*point,digits);
            request.price    =NormalizeDouble(price,digits);                 // 正常开盘价
           }
         //--- 发送请求
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
         //--- 操作信息   
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         //--- 归零请求和结果值
         ZeroMemory(request);
         ZeroMemory(result);
        }
     }
  }
//+------------------------------------------------------------------+
 

 
删除挂单的TRADE_ACTION_REMOVE 交易操作的示例：



#define EXPERT_MAGIC 123456  // EA交易的幻数 
//+------------------------------------------------------------------+
//| 删除挂单                                                          |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
   int total=OrdersTotal(); // 下挂单的总数
//--- 重做所有已下的挂单
   for(int i=total-1; i>=0; i--)
     {
      ulong  order_ticket=OrderGetTicket(i);                   // order ticket
      ulong  magic=OrderGetInteger(ORDER_MAGIC);               // 订单的幻数
      //--- 如果幻数匹配
      if(magic==EXPERT_MAGIC)
        {
         //--- 归零请求和结果值
         ZeroMemory(request);
         ZeroMemory(result);
         //--- 设置持仓参数     
         request.action=TRADE_ACTION_REMOVE;                   // 交易操作的类型
         request.order = order_ticket;                         // 订单价格
         //--- 发送请求
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
         //--- 操作信息   
         PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
     }
  }
//+------------------------------------------------------------------+
 

 
关闭反向持仓的TRADE_ACTION_CLOSE_BY 交易操作的示例：



#define EXPERT_MAGIC 123456  // EA交易的幻数
//+------------------------------------------------------------------+
//| 关闭所有反向持仓                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- 声明并初始化交易请求和交易请求结果
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // 持仓数   
//--- 重做所有持仓
   for(int i=total-1; i>=0; i--)
     {
      //--- 订单的参数
      ulong  position_ticket=PositionGetTicket(i);                                    // 持仓价格
      string position_symbol=PositionGetString(POSITION_SYMBOL);                      // 交易品种 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);            // 持仓价格
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                // 持仓的幻数
      double volume=PositionGetDouble(POSITION_VOLUME);                               // 持仓交易量
      double sl=PositionGetDouble(POSITION_SL);                                       // 持仓的止损
      double tp=PositionGetDouble(POSITION_TP);                                       // 持仓的止赢
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // 持仓类型
      //--- 输出持仓信息
      PrintFormat("#%I64u %s  %s  %.2f  %s  sl: %s  tp: %s  [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  DoubleToString(sl,digits),
                  DoubleToString(tp,digits),
                  magic);
      //--- 如果幻数匹配
      if(magic==EXPERT_MAGIC)
        {
         for(int j=0; j<i; j++)
           {
            string symbol=PositionGetSymbol(j); // 反向持仓交易品种
            //--- 如果反向持仓交易品种和初始交易品种匹配
            if(symbol==position_symbol && PositionGetInteger(POSITION_MAGIC))
              {
               //--- 设置反向持仓类型
               ENUM_POSITION_TYPE type_by=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               //--- 离开，如果初始持仓和反向持仓类型匹配
               if(type==type_by)
                  continue;
               //--- 归零请求和结果值
               ZeroMemory(request);
               ZeroMemory(result);
               //--- 设置操作参数
               request.action=TRADE_ACTION_CLOSE_BY;                         // 交易操作类型
               request.position=position_ticket;                             // 持仓价格
               request.position_by=PositionGetInteger(POSITION_TICKET);      // 反向持仓价格
               //request.symbol     =position_symbol;
               request.magic=EXPERT_MAGIC;                                   // 持仓的幻数
               //--- 输出反向持仓平仓的信息
               PrintFormat("Close #%I64d %s %s by #%I64d",position_ticket,position_symbol,EnumToString(type),request.position_by);
               //--- 发送请求
               if(!OrderSend(request,result))
                  PrintFormat("OrderSend error %d",GetLastError()); // 如果不能发送请求，输出错误代码
 
               //--- 操作信息   
               PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
 

 

 







































////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
#ifdef __MQL5__
int OnInit() {

ArrayResize(High,ArrayMax);
ArrayResize(Low,ArrayMax);
ArrayResize(Close,ArrayMax);
ArrayResize(Open,ArrayMax);

ArraySetAsSeries(High,true);
ArraySetAsSeries(Low,true);
ArraySetAsSeries(Close,true);
ArraySetAsSeries(Open,true);

ArrayResize(Time,1);
ArraySetAsSeries(Time,true);

#else
int init() {
#endif 
//////////////////////////////////////////////////////////////////////