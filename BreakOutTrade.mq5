//+------------------------------------------------------------------+
//|                                                         _ADX.mq5 |
//|                                                     Yuriy Tokman |
//|                                         http://www.mql-design.ru |
//+------------------------------------------------------------------+
#property copyright "Jin Song"
#property link      "http://www.mql-design.ru"
#property version   "1.00"

string Copyright="jin song";
string WritingExpertAdvisors="Indicators_Scripts";
string e_mail= "everjs_2002@hotmail.com";
string Skype = "everjs_2002";

input ENUM_TIMEFRAMES TimeFrames=0;
int shift=1;
//----ADX
int h_adx=INVALID_HANDLE;
double b_adxP[];
double b_adxM[];
int adx_period=28;
//----+

input double Lots=0.1;
input int fST=50;//止损
input int fLI=130;//止盈
input bool bCanTrade=false;//进行交易吗？true is run
int dev= 30;
//----+
int level_p = 5;
int level_m = 5;
//----+
input int tradeTime1=0;//交易开始时间【欧洲】
input int tradeTime2=0;//交易结束时间【欧洲】
input int tradeTime4=8;//交易开始时间【欧洲数据】
input int tradeTime5=17;//交易结束时间【美国美国数据】
int OnInit(){return(0);}
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
void OnTick()
  {
  
   if(!bCanTrade) return;  
   IndicatorRun();
   MqlDateTime str1; 
   TimeToStruct(TimeCurrent(),str1);   
   int weekday=str1.day_of_week; 

   Comment(StringFormat("MainTrend = %G\n Ask = %G \n QuickRSI[0] = %G \n BAND_UP[0] = %G \n BAND_LOW[0] = %G",MainTrend,SymbolInfoDouble(Symbol(),SYMBOL_ASK), QuickRSI[0], BAND_UP[0], BAND_LOW[0])); 

   switch(weekday)
   {
      case 1:
      case 2:
      
      //break;
      case 3:
      case 4:
      case 5:
      if( (str1.hour>=tradeTime4 && str1.hour <= tradeTime5 ) || ( str1.hour >= tradeTime1 && str1.hour <= tradeTime2 )) 
      {
         NewsTrade();
      }      
      break;
      default:
      break;
      
   }
  


//----+  
  }
int NewsMagicBuy=6000;
int NewsMagicSell=6010;

input int QuickRSI_high=60;//买快RSI值
input int QuickRSI_low=40;//卖快RSI值
input bool OneDirection=true;//false for two direction
void NewsTrade(){
   double stoploss=0;
   double takeprofit;
   int trend=JudgeTrendByHour(80);

   if( QuickRSI[0] >QuickRSI_high && SymbolInfoDouble(Symbol(),SYMBOL_ASK) > BAND_UP[0] && FobidTradeByHour(4,NewsMagicBuy)==1 ){//&& MainTrend ==1 

        //----+
      if(!ExtPos(NewsMagicBuy))
        {
            OP(1,NewsMagicBuy,fST,fLI);       
            if(OneDirection) DeleteAllOrdersByMagic(NewsMagicSell,ChartSymbol());  
            
        }

      }
      
   if( QuickRSI[0] < QuickRSI_low && SymbolInfoDouble(Symbol(),SYMBOL_BID) < BAND_LOW[0]  && FobidTradeByHour(4,NewsMagicSell)==1){//&& MainTrend ==2
        //sell

      if(!ExtPos(NewsMagicSell))
        {
         OP(0,NewsMagicSell,fST,fLI);       
         if(OneDirection) DeleteAllOrdersByMagic(NewsMagicBuy,ChartSymbol());    
            
        }

             
    }

     

}
input int QuickRSI_P=64;
input int STOCHASTKC_MAIN_P1=180;
input int STOCHASTKC_MAIN_P2=80;
input int STOCHASTKC_MAIN_P3=160;
//extern int STOCHASTKC=120*60;
//extern int STOCHASTKC=60*60;
//extern int STOCHASTKC=80*60;
input int iBands_P1=200;
input double iBands_P2=2.4;
int RSIHandle=INVALID_HANDLE;
int STOCHASTKC_Handle=INVALID_HANDLE;
int BAND_Handle=INVALID_HANDLE;
double QuickRSI[1],RSI[1],STOCHASTKC[1],STOCHASTKC_MAIN[1],BAND_MAIN[1],BAND_UP[1],BAND_LOW[1],IMA[1],IMA1[1];
void IndicatorRun(){
   //RSI = iRSI(NULL,0,RSI_P,PRICE_CLOSE,0);

   if(RSIHandle==INVALID_HANDLE)  {
      RSIHandle=iRSI(Symbol(),TimeFrames,QuickRSI_P,PRICE_CLOSE);
   }
   else{
   if(CopyBuffer(RSIHandle,0,0,1,QuickRSI)!=1)
     {
      Print("CopyBuffer from RSI failed, no data");
      return;
     }   
   }



   if(STOCHASTKC_Handle==INVALID_HANDLE)
     {
      STOCHASTKC_Handle=iStochastic(Symbol(),TimeFrames,STOCHASTKC_MAIN_P1,STOCHASTKC_MAIN_P2,STOCHASTKC_MAIN_P3,MODE_SMA,STO_CLOSECLOSE); 
     }
   else
     {
       if(CopyBuffer(STOCHASTKC_Handle,0,0,1,STOCHASTKC_MAIN)!=1)
       {
         Print("CopyBuffer from STOCHASTKC_MAIN failed, no data");
         return;
       }
       if(CopyBuffer(STOCHASTKC_Handle,1,0,1,STOCHASTKC)!=1)
       {
         Print("CopyBuffer from STOCHASTKC_1 failed, no data");
         return;
       }
         
     }

   if(BAND_Handle==INVALID_HANDLE)
     {
      BAND_Handle=iBands(Symbol(),TimeFrames,iBands_P1,0,iBands_P2,PRICE_HIGH); 
     }
   else
     {
       if(CopyBuffer(BAND_Handle,0,0,1,BAND_LOW)!=1)
       {
         Print("CopyBuffer from BAND_UP failed, no data");
         return;
       }
       if(CopyBuffer(BAND_Handle,1,0,1,BAND_UP)!=1)
       {
         Print("CopyBuffer from BAND_LOW failed, no data");
         return;
       }
       if(CopyBuffer(BAND_Handle,2,0,1,BAND_MAIN)!=1)
       {
         Print("CopyBuffer from BAND_MAIN failed, no data");
         return;
       }         
     }  
} 
//+------------------------------------------------------------------+
int Sig_ADX()
  {
   int sig=0;

   if(h_adx==INVALID_HANDLE)
     {
      h_adx=iADXWilder(Symbol(),TimeFrames,adx_period);return(0);
     }
   else
     {
      if(CopyBuffer(h_adx,1,0,3+shift,b_adxP)<3+shift) return(0);
      if(CopyBuffer(h_adx,2,0,3+shift,b_adxM)<3+shift) return(0);
      if(!ArraySetAsSeries(b_adxP,true))return(0);
      if(!ArraySetAsSeries(b_adxM,true))return(0);
     }

   if(b_adxP[0+shift]>level_p && b_adxP[1+shift]<level_p)sig=+1;
   if(b_adxM[0+shift]>level_m && b_adxM[1+shift]<level_m)sig=-1;

   return(sig);
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


int MainTrend=0;//
int JudgeTrendByHour(int barCount=100){
   if(STOCHASTKC_MAIN[0] > STOCHASTKC[0] )MainTrend=1;//up
   else if(STOCHASTKC_MAIN[0]  < STOCHASTKC[0] ) MainTrend=2;//down
   else MainTrend=0;
   
   return MainTrend;
   


}


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

//+------------------------------------------------------------------+ 
//| 删除所有带有指定ORDER_MAGIC的挂单                                   | 
//+------------------------------------------------------------------+ 
void DeleteAllOrdersByMagic(long const magic_number,string comment="") 
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
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // 如果不能发送请求，输出错误代码
         //--- 操作信息   
         //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
           } 
//--- 
  } 
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