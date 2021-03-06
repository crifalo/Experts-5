
#property copyright "Jin Song"
#property link      "http://www.mql-design.ru"
#property version   "1.00"
#include "mql4compat.mqh"

string Copyright="jin song";
string WritingExpertAdvisors="Indicators_Scripts";
string e_mail= "everjs_2002@hotmail.com";
string Skype = "everjs_2002";

input int x_peak=4;//波峰左侧K线
input int y_peak=4;//波峰右侧K线
input int n_trough=4;//波谷左侧K线
input int m_trough=4;//波谷右侧K线
input int buy_depth=4;//做多入场深度
input int sell_depth=4;//做空入场深度
input int win_close=4;//盈利时间(分)
input int lose_close=1;//止损时间(分)
input bool bReverse=true;//fals为假突破交易

double cur_peak=0;
double pre_peak=0;
double high_peak=0;
int positon_peak=0,positon_trough=0;
double cur_trough=0;
double pre_trough=0;
double low_trough=0;

input double Lots=0.1;
input int fST=25000;//止损
input int fLI=27000;//止盈
input bool bCanTrade=false;//进行交易吗？true is run
int dev= 30;
//----+
int level_p = 5;
int level_m = 5;
//----+
input bool bTradeTime=false;//false为不使用特定时间段进行交易,true为在特定时间段进行交易并日内平仓 
input int tradeTime1=0;//交易开始时间【欧洲】
input int tradeTime2=0;//交易结束时间【欧洲】
input int tradeTime4=8;//交易开始时间【欧洲数据】
input int tradeTime5=17;//交易结束时间【美国美国数据】
input int IntervalTrade=1;//1为每天只允许一次交易，每天允许的交易次数
input int peakScanCount=300;//向前扫描K线个数
int OnInit(){
   InitMQL4Env();
   //PeakTrough(240);   
   return(0);
}
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
void OnTick()
  {
  

   MqlDateTime str1; 
   TimeToStruct(TimeCurrent(),str1);   
   int weekday=str1.day_of_week; 

   //Comment(StringFormat("MainTrend = %G\n Ask = %G \n QuickRSI[0] = %G \n BAND_UP[0] = %G \n BAND_LOW[0] = %G",MainTrend,SymbolInfoDouble(Symbol(),SYMBOL_ASK), QuickRSI[0], BAND_UP[0], BAND_LOW[0])); 

   switch(weekday)
   {
      case 1:
      case 2:
      
      //break;
      case 3:
      case 4:
      case 5:
      if(bTradeTime){
         if( (str1.hour>=tradeTime4 && str1.hour <= tradeTime5 ) || ( str1.hour >= tradeTime1 && str1.hour <= tradeTime2 )) 
         {
            PeakTrough(peakScanCount);
         }      
         if(str1.hour==22 && str1.min==01){ DeleteAllOrdersByMagic(Magic_Buy,ChartSymbol());  DeleteAllOrdersByMagic(Magic_Sell,ChartSymbol());   }//日内交易      
      }
      else{
         PeakTrough(peakScanCount);      
      }
      CurrentPositionManagement(0,"");
      break;
      default:
      break;
      
   }
  


//----+  
  }
int Magic_Sell=100;
int Magic_Buy=101;




void PeakTrough(int InitCount=200){//价格突破峰谷及峰谷以来开单
//---
   bool bHaveTrough=false,bHavePeak=false;
   bHaveTrough=false;
   bHavePeak=false;
   if(MathAbs(pre_trough -iLow(NULL,0,positon_trough))>0.00001)//不等于
      for(int i=0;i<InitCount ;i++){
         
         cur_trough=iLow(NULL,0,m_trough+1+i);
         double left_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,n_trough,m_trough+2+i));
         double right_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,m_trough,1+i));
         if( left_trough > cur_trough  && right_trough > cur_trough ){
            //找到谷
            bHaveTrough=true;
            positon_trough=m_trough+1+i;
            pre_trough=cur_trough;//记住谷底
            low_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,positon_trough,1+0));
            if(low_trough<cur_trough) cur_trough=low_trough;
            break;
         }
         else{
         
         }      
         if(i==InitCount-1) {Alert("在前面K线中没有找到谷");cur_trough=0; }
   
      }
    else   bHaveTrough=true;
   //printf("right_trough-bar=%d,Ask=%f,left_trough=%f ,cur_trough=%f ,right_trough =%f Ask=%f",iLowest(NULL,0,MODE_LOW,m_trough,1),Ask,left_trough,cur_trough,right_trough,SymbolInfoDouble(Symbol(),SYMBOL_ASK));            
   if(  SymbolInfoDouble(Symbol(),SYMBOL_BID) <  cur_trough - sell_depth*Point() && bHaveTrough  ){//&& FobidTradeByHour(8,NewsMagicSell)==1      
         if(!ExtPos(Magic_Sell) && FobidTradeByDay(IntervalTrade,0)==1) {
            if(DeleteAllOrdersByMagic(Magic_Buy,ChartSymbol())==-1) Alert("Can not delete position");
            OP(0,Magic_Sell,fST,fLI); 
   
         }

      }


   if(MathAbs(pre_peak -iHigh(NULL,0,positon_peak))>0.00001)//不等于
      for(int i=0;i<InitCount ;i++){
         
         cur_peak= iHigh(NULL,0,y_peak+1+i); 
         double left_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,x_peak,y_peak+2+i));
         double right_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,y_peak,1+i));
         if( cur_peak > left_peak  && cur_peak > right_peak ){
            //找到峰
            bHavePeak=true;
            positon_peak=y_peak+1+i;
            pre_peak=cur_peak;
            high_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,positon_peak,1+0));
            if(high_peak > cur_peak) cur_peak=high_peak;
            break;
         }
         else{
         
         }      
         if(i==InitCount-1) {Alert("在前面K线中没有找到峰");cur_peak=0; }
   
      }  
   else bHavePeak=true;
      
   if( SymbolInfoDouble(Symbol(),SYMBOL_ASK) > cur_peak + buy_depth*Point() &&  bHavePeak ){//    
          if(!ExtPos(Magic_Buy) && FobidTradeByDay(IntervalTrade,0)==1 ) {
            DeleteAllOrdersByMagic(Magic_Sell,ChartSymbol());  
            OP(1,Magic_Buy,fST,fLI); //1为buy,0为sell
   
                  
         }

     }
}

//----+
bool ExtPos(int mn=1)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(Symbol()==PositionGetSymbol(i))
        {
         if(PositionGetInteger(POSITION_MAGIC)==mn)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
               return(true);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
               return(true);
           }
        }
     }
   return(false);
  }
//----+
void OP(int op=1,int MAGIC=0,int SL=30,int TP=80)
  {
//---
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   MqlTradeRequest request;
   MqlTradeCheckResult check_result;
   MqlTradeResult trade_result;
   ZeroMemory(request);

   request.action=TRADE_ACTION_DEAL;
   request.magic=MAGIC;
   request.symbol=Symbol();
   request.volume=Lots;
   request.deviation=dev;
   request.type_filling=ORDER_FILLING_FOK;
//--- 
   if(bReverse){
      if(op==1) op=1;
      else op=0;    
   }   
   else{
      if(op==1) op=0;
      else op=1;
   }
   if(op==1)
     {
      request.type=ORDER_TYPE_BUY;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      request.sl= SymbolInfoDouble(Symbol(),SYMBOL_BID) - SL*Point();
      request.tp=SymbolInfoDouble(Symbol(),SYMBOL_ASK) +TP*Point();
     }
   if(op==0)
     {
      request.type=ORDER_TYPE_SELL;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      request.sl= SymbolInfoDouble(Symbol(),SYMBOL_ASK) + SL*Point();
      request.tp=SymbolInfoDouble(Symbol(),SYMBOL_BID) - TP*Point();
     }
   request.comment=Symbol();
//----+
   if(!OrderCheck(request,check_result))return;
   if(OrderSend(request,trade_result))
      Print("Trade request has been successfuly executed, order volume =",trade_result.volume);
   else
      Print("Error in trade request execution. Return code=",trade_result.retcode);
//----+
  }
//+------------------------------------------------------------------+



int FobidTradeByHour(int day=1,int mn=0){
//--- 检查持仓是否存在并显示其变化的时间
//--- 从周交易历史记录接收最后订单的标签

   ulong last_deal=GetLastDealTicket();
   if(last_deal==-1) return 1;
   if(HistoryDealSelect(last_deal))
     {
      //--- 从1970.01.01起以毫秒为单位的交易执行的时间
      long deal_time_msc=HistoryDealGetInteger(last_deal,DEAL_TIME_MSC);
      
      MqlDateTime str1,str2; 
      TimeToStruct(StringToTime(TimeToString(deal_time_msc/1000)),str1);   
      TimeToStruct(TimeCurrent(),str2);
      if(str2.hour-str1.hour< day) return 0;
      else return 1;      
      
      //PrintFormat("Deal #%d DEAL_TIME_MSC=%i64 => %s",
      //            last_deal,deal_time_msc,TimeToString(deal_time_msc/1000));
     }
   else
      PrintFormat("HistoryDealSelect() failed for #%d. Eror code=%d",
                  last_deal,GetLastError());

    return 1;      
}
int FobidTradeByDay(int day=1,int mn=0){
//--- 检查持仓是否存在并显示其变化的时间
//--- 从周交易历史记录接收最后订单的标签
   return 1; 
   ulong last_deal=GetLastDealTicket();
   if(last_deal==-1) return 1;
   if(HistoryDealSelect(last_deal))
     {
      //--- 从1970.01.01起以毫秒为单位的交易执行的时间
      long deal_time_msc=HistoryDealGetInteger(last_deal,DEAL_TIME_MSC);
      
      MqlDateTime str1,str2; 
      TimeToStruct(StringToTime(TimeToString(deal_time_msc/1000)),str1);   
      TimeToStruct(TimeCurrent(),str2);
      if(str2.day-str1.day< day) return 0;
      else return 1;      
      
      //PrintFormat("Deal #%d DEAL_TIME_MSC=%i64 => %s",
      //            last_deal,deal_time_msc,TimeToString(deal_time_msc/1000));
     }
   else
      PrintFormat("HistoryDealSelect() failed for #%d. Eror code=%d",
                  last_deal,GetLastError());

    return 1;      
}
//+------------------------------------------------------------------+ 
//| 删除所有带有指定ORDER_MAGIC的挂单                                   | 
//+------------------------------------------------------------------+ 
int DeleteAllOrdersByMagic(long const magic_number,string comment="") 
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
         
         if(magic_number==magic && StringCompare(comment,position_symbol)==0) 
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
         request.magic    =magic_number;             // 持仓幻数
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
         //PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- 发送请求
         if(!OrderSend(request,result)){
            PrintFormat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
            return -1;
            }
         //--- 操作信息   
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
           
           } 
//--- 
         } 
  return 0;
}  
  //+------------------------------------------------------------------+
//| 返回历史记录中最后交易的标签或-1                                     |
//+------------------------------------------------------------------+
ulong GetLastDealTicket()
  {
//--- 请求最近7天的历史记录
   if(!GetTradeHistory(1))
     {
      //--- 通知不成功的调用和返回-1
      //Print(__FUNCTION__," HistorySelect() returned false");
      return -1;
     }
//--- 
   ulong first_deal,last_deal,deals=HistoryOrdersTotal();
//--- 如果有，从事订单工作
   if(deals>0)
     {
      //Print("Deals = ",deals);
      first_deal=HistoryDealGetTicket(0);
      //PrintFormat("first_deal = %d",first_deal);
      if(deals>1)
        {
         last_deal=HistoryDealGetTicket((int)deals-1);
         //PrintFormat("last_deal = %d",last_deal);
         return last_deal;
        }
      return first_deal;
     }
//--- 未发现成交，返回 -1
   return -1;
  }
//+--------------------------------------------------------------------------+
//| 请求最近几日的历史记录，如果失败，则返回false                                   |
//+--------------------------------------------------------------------------+
bool GetTradeHistory(int days)
  {
//--- 设置一个星期的周期请求交易历史记录
   datetime to=TimeCurrent();
   datetime from=to-days*PeriodSeconds(PERIOD_D1);
   ResetLastError();
//--- 发出请求检察结果
   if(!HistorySelect(from,to))
     {
      //Print(__FUNCTION__," HistorySelect=false. Error code=",GetLastError());
      return false;
     }
//--- 成功接收历史记录
   return true;
  }
  
 
int CurrentPositionManagement(long const magic_number,string comment="") 
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
      //long create_time_msc=PositionGetInteger(POSITION_TIME_MSC); 
      datetime create_time=PositionGetInteger(POSITION_TIME);  
      //--- 获取毫秒为单位的所用时间 
      MqlDateTime from; 
      //TimeToStruct(create_time,from); 
      //datetime to=TimeCurrent();  
      TimeToStruct(TimeCurrent()- create_time,from ) ; 
      //PrintFormat("   => %s",TimeToString(TimeCurrent()- create_time ) );      
      //PrintFormat("str1.min => %d",from.min);

                      
      if(from.hour*60+from.min> win_close && PositionGetDouble(POSITION_PROFIT) > 0)
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
         request.magic    =magic_number;             // 持仓幻数
         //--- 根据持仓类型设置价格和订单类型 
         if(type==POSITION_TYPE_BUY){
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else{
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         //--- 输出关闭信息
         //PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- 发送请求
         if(!OrderSend(request,result)){
            PrintFormat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
            return -1;
         }
         //--- 操作信息   
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
           
         } 
      if(from.hour*60+from.min> lose_close && PositionGetDouble(POSITION_PROFIT) < 0)
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
         request.magic    =magic_number;             // 持仓幻数
         //--- 根据持仓类型设置价格和订单类型 
         if(type==POSITION_TYPE_BUY){
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else{
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         //--- 输出关闭信息
         //PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
         //--- 发送请求
         if(!OrderSend(request,result)){
            PrintFormat("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
            return -1;
         }
         //--- 操作信息   
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
           
         } 
//--- 
      } 
  return 0;
}  