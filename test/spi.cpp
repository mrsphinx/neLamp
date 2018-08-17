#define INH 6//Закрепление выводов
#define CE 5//за сигналами управления
#define SCL 2//экраном
#define DN 4
//Объявление массива для записи изображения на экран
byte buf[13];
String in_line;
//Кодирование изображения цифр(знаков) именами сегментов
//
const unsigned char
dig[10][7] =
{
  {'a', 'b', 'c', 'd', 'e', 'f'}, //Цифра0
  {'b', 'c'}, //Цифра1
  {'a', 'b', 'd', 'e', 'g'}, //Цифра2
  {'a', 'b', 'c', 'd', 'g'}, //Цифра3
  {'b', 'c', 'f', 'g'}, //Цифра4
  {'a', 'c', 'd', 'f', 'g'}, //Цифра5
  {'a', 'c', 'd', 'e', 'f', 'g'},//Цифра6
  {'a', 'b', 'c'}, //Цифра7
  {'a', 'b', 'c', 'd', 'e', 'f', 'g'}, //Цифра8
  {'a', 'b', 'c', 'd', 'f', 'g'}, //Цифра9
};
//Номера бит которые должны быть равны 1
//для отображения нужного сегмента в нужном знакоместе
const byte sega[] = {5, 13, 21, 29, 37, 45, 57, 65, 73, 81};
const byte segb[] = {7, 15, 23, 31, 39, 47, 59, 67, 75, 83};
const byte segc[] = {3, 11, 19, 27, 35, 43, 51, 63, 71, 79};
const byte segd[] = {0, 8, 16, 24, 32, 40, 48, 60, 68, 76};
const byte sege[] = {2, 10, 18, 26, 34, 42, 50, 62, 70, 78};
const byte segf[] = {4, 12, 20, 28, 36, 44, 56, 64, 72, 80};
const byte segg[] = {6, 14, 22, 30, 38, 46, 58, 66, 74, 82};
const byte segh[] = {1, 9, 17, 25, 33, 41, 49, 61, 69, 77};
const byte bat[] = {99, 104, 102, 100, 98};
void setup()
{
  Serial.begin(9600);
  pinMode(CE, OUTPUT);
  pinMode(SCL, OUTPUT);
  pinMode(DN, OUTPUT);
  pinMode(INH, OUTPUT);
  CLS();
  OUTSCR();
}
void loop()
{
  while (!Serial.available())
  {
  }
  in_line = Serial.readString();
  CLS();
  SSL(in_line);
  Serial.flush();
}
void SSL(String thisline)
{
  byte pos = 0;
  byte inlong = thisline.length() - 1;
  for (int i = inlong; i > -1; i--)
  {
    switch (thisline[i])
    {
      case'a': BS(bat[0]); break;
      case'b': BS(bat[1]); break;
      case'c': BS(bat[2]); break;
      case'd': BS(bat[3]); break;
      case'e': BS(bat[4]); break;
      case' ': pos++; break;
      case'-': BS(segg[pos]); pos++; break;
      case'.': BS(segh[pos]); break;
      case'0': SAVCIF(pos, 0); pos++; break;
      case'1': SAVCIF(pos, 1); pos++; break;
      case'2': SAVCIF(pos, 2); pos++; break;
      case'3': SAVCIF(pos, 3); pos++; break;
      case'4': SAVCIF(pos, 4); pos++; break;
      case'5': SAVCIF(pos, 5); pos++; break;
      case'6': SAVCIF(pos, 6); pos++; break;
      case'7': SAVCIF(pos, 7); pos++; break;
      case'8': SAVCIF(pos, 8); pos++; break;
      case'9': SAVCIF(pos, 9); pos++; break;
    }
  }
  OUTSCR();
}
//=============Подпрограмма очистки buf=================
//
void CLS(void)
{
  register byte internalCounter;
  for (internalCounter = 0; internalCounter < 13; internalCounter++)
  {
    buf[internalCounter] = 0;
  }
  buf[internalCounter] = 1;
}
//
//=================================================================
//==Подпрограмма записи еденицы сегмента(знака) в массив экрана ==
//
void BS(byte hbit)
{
  byte this_byte = hbit / 8;
  byte this_bit = 7 - hbit % 8;
  bitSet(buf[this_byte], this_bit);
}
//
//================================================================
//=======Подпрограмма отправки  изображения на экран==============
//
void OUTSCR(void)
{
  digitalWrite(CE, HIGH);
  for (register byte i = 0; i < 14; i++)
  {
    shiftOut(DN, SCL, MSBFIRST, buf[i]);
  }
  digitalWrite(CE, LOW);
  digitalWrite(INH, HIGH);
}
//=================================================================
//=======Подпрограмма записи изображения цифры в массив экрана========
//
//
void SAVCIF(byte pozicia, byte znak)
{
  byte counter = 0;
  while (dig[znak][counter] != 0)
  {
    switch (dig[znak][counter])
    {
      case 'a': BS(sega[pozicia]); break;
      case 'b': BS(segb[pozicia]); break;
      case 'c': BS(segc[pozicia]); break;
      case 'd': BS(segd[pozicia]); break;
      case 'e': BS(sege[pozicia]); break;
      case 'f': BS(segf[pozicia]); break;
      case 'g': BS(segg[pozicia]); break;
    }
    counter++;
  }
}
//
//=====================================================================