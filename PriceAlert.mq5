#property copyright "André Augusto Giannotti Scotá"
#property link "https://sites.google.com/view/a2gs"
#property version "1.0"
#property description "A Simple Price Alert"

enum side_t
{
   LT = 0, // Less than
   GT      // Greater than
};

/* https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants */
enum price_t
{
   BID,      // BID - best sell offer
   ASK,      // ASK - best buy offer
   BIDHIGH,  // Maximal Bid of the day
   BIDLOW,   // Minimal Bid of the day
   ASKHIGH,  // Maximal Ask of the day
   ASKLOW,   // Minimal Ask of the day
   LAST,     // Price of the last deal
   LASTHIGH, // Maximal Last of the day
   LASTLOW   // Minimal Last of the day
};

input side_t       SIDE            = LT;              // Alarm when
input double       ALARMPRICE      = 0.0;             // Price to alert
input price_t      ALARMCOMPARE    = ASK;             // Compared with Ask/Bid price
input string       ALARMMSG        = "=== ALERT ==="; // Message to alert
input unsigned int MSG_TIMES       = 1;               // How may times to print log
input unsigned int PUSHNOTIF_TIMES = 1;               // How may times to send P.N.
input unsigned int SOUND_TIMES     = 1;               // How may times to play sound
input string       SOUND_FILE      = "timeout.wav";   // Alert sound file
input bool         PRINTCURRENT    = true;            // Print current alert test?

ENUM_SYMBOL_INFO_DOUBLE compSymb;

ENUM_SYMBOL_INFO_DOUBLE userTomql5def(price_t p)
{
   switch(p){
      case BID:
         return(SYMBOL_BID);
      case BIDHIGH:
         return(SYMBOL_BIDHIGH);
      case BIDLOW:
         return(SYMBOL_BIDLOW);
      case ASK:
         return(SYMBOL_ASK);
      case ASKHIGH:
         return(SYMBOL_ASKHIGH);
      case ASKLOW:
         return(SYMBOL_ASKLOW);
      case LAST:
         return(SYMBOL_LAST);
      case LASTHIGH:
         return(SYMBOL_LASTHIGH);
      case LASTLOW:
         return(SYMBOL_LASTLOW);
   }

   return(SYMBOL_BID);
}

int OnInit(void)
{
   if(ALARMPRICE == 0.0)
      return(INIT_PARAMETERS_INCORRECT);

   compSymb = userTomql5def(ALARMCOMPARE);
   printf("ALERT when price [%s] than value [%f]", (SIDE == LT ? "less" : "greater"), ALARMPRICE);

   return(INIT_SUCCEEDED);
}

void OnTick(void)
{
   double lastPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, compSymb), _Digits);

   if(PRINTCURRENT == true) printf("Price: %f | Alarm: %f", lastPrice, ALARMPRICE);
   
   if(SIDE == LT && lastPrice <= ALARMPRICE) doAlert();
   if(SIDE == GT && lastPrice >= ALARMPRICE) doAlert();
}

void OnDeinit(const int reason)
{
   Print("ALERT OFF");
}

void doAlert(void)
{
   unsigned int times;

   for(times = 0; times < MSG_TIMES; times++) Print(ALARMMSG);

   for(times = 0; times < SOUND_TIMES; times++){
      Alert(ALARMMSG);
      PlaySound(SOUND_FILE);
   }

   for(times = 0; times < PUSHNOTIF_TIMES; times++){
      if(SendNotification(ALARMMSG) == false)
         Print("ERRO SENDING PUSH NOTIFICATION: [" + ALARMMSG + "]. Reason: [" + PushNotificationErrorMessages(GetLastError()) + "]");
   }

   ExpertRemove();
}

string PushNotificationErrorMessages(int err)
{
   string msg;

   switch(err){
      case ERR_NOTIFICATION_SEND_FAILED:
         msg = "Envio falhou";
         break;

      case ERR_NOTIFICATION_WRONG_PARAMETER:
         msg = "Parametros errados";
         break;

      case ERR_NOTIFICATION_WRONG_SETTINGS:
         msg = "Configuracoes errados";
         break;

      case ERR_NOTIFICATION_TOO_FREQUENT:
         msg = "Notificacoes muito frequentes";
         break;

      default:
         msg = "UNKNOWN";
   }

   return(msg);
}