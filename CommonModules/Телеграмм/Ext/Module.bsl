﻿
#Область ОСНОВНЫЕ_МЕТОДЫ

&НаСервере
Функция ПолучитьСообщения(ChatId = Неопределено) Экспорт

	ПоследнийАйди = СтрЗаменить(Строка(Константы.АйдиПоследнегоСообщения.Получить()), Символы.НПП, "");
	СоединениеHTTP = Новый HTTPСоединение("api.telegram.org",443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	Возврат СоединениеHTTP.Получить(Новый HTTPЗапрос("bot" + Строка(Константы.ТокенБота.Получить()) + "/getUpdates" + "?offset=" + 
									ПоследнийАйди)).ПолучитьТелоКакСтроку();

КонецФункции

&НаСервере
Процедура ПолучитьСообщенияНаСервере() Экспорт
	
	Сообщения = Телеграмм.ПолучитьСообщения();
	
	//читаем собщения
	ЧтениеJSON= Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Сообщения);
	СтруктураСобщений = ПрочитатьJSON(ЧтениеJSON);
	
	ПоследнийАйдиСообщения = Константы.ПоследнийАйдиСообщения.Получить();
	
	Если СтруктураСобщений.ok Тогда
		ОтправитьСообщенияНаСервере(Константы.ИдентификаторГлавнойГруппы.Получить());
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОтправитьСообщенияНаСервере(ChatId)
	
	Массив = Новый Массив;
	Массив.Добавить(ПолучитьПриветствие());
	Массив.Добавить(Символы.ПС);
	
	Массив.Добавить(ПолучитьОтчетНаСервере());
	Массив.Добавить(ПолучитьРасшифровкуОтчета());
	Массив.Добавить(ПолучитьДатуПоследнегоИзменения());
	ОдноСообщениее = ПолучитьСообщениеПолностью(Массив);
	
	ПростоОтправитьСообщениеВчатНаСервере(ОдноСообщениее);

КонецПроцедуры

&НаСервере
Функция ПолучитьПриветствие() Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Приветствия.Текст КАК Текст
		|ИЗ
		|	РегистрСведений.Приветствия КАК Приветствия";
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		ТабТекстыПриветствий = Запрос.Выполнить().Выгрузить();
		КоличествоТекстов = ТабТекстыПриветствий.Количество();
		
		ГСЧ = Новый ГенераторСлучайныхЧисел();
		СлучайноеЧисло = ГСЧ.СлучайноеЧисло(0, КоличествоТекстов - 1);
		
		Возврат ТабТекстыПриветствий[СлучайноеЧисло].Текст;
	КонецЕсли;
	
	Возврат "<b>Привет я Ванесса!!!</b>";
	
КонецФункции

&НаСервере
Функция ПолучитьОтчетНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОстаткиПоДушниламОстатки.ФизЛицо.ФИОПолностью КАК ФизЛицо,
		|	ОстаткиПоДушниламОстатки.БаллОстаток КАК Балл
		|ИЗ
		|	РегистрНакопления.ОстаткиПоДушнилам.Остатки КАК ОстаткиПоДушниламОстатки";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Массив = Новый Массив;
	Массив.Добавить("<b>Текущий результат:</b>" + Символы.ПС);
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ФизЛицо = ВыровнятьФизЛицо(ВыборкаДетальныеЗаписи.ФизЛицо, Константы.КоличествоСимволовВИмени.Получить());

		Строка = СтрШаблон("<code>%1 | (%2) %3</code>", ФизЛицо, ВыборкаДетальныеЗаписи.Балл, Символы.ПС);
		Массив.Добавить(Строка);
		
	КонецЦикла;
	
	Массив.Добавить(Символы.ПС + "______________" + Символы.ПС);
	СообщениеВЧат = СтрСоединить(Массив);
	
	Возврат СообщениеВЧат;

КонецФункции

&НаСервере
Функция ПолучитьРасшифровкуОтчета()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОстаткиПоДушниламОстатки.ФизЛицо.ФИОПолностью КАК ФизЛицо,
		|	ПРЕДСТАВЛЕНИЕ(ОстаткиПоДушниламОстатки.Свойство) КАК Свойство,
		|	ОстаткиПоДушниламОстатки.БаллОстаток КАК Балл
		|ИЗ
		|	РегистрНакопления.ОстаткиПоДушнилам.Остатки КАК ОстаткиПоДушниламОстатки
		|ГДЕ
		|	ОстаткиПоДушниламОстатки.БаллОстаток < 0";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Массив = Новый Массив;
	Массив.Добавить(Символы.ПС + "<b>На дне:</b>" + Символы.ПС);
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ФизЛицо = ВыровнятьФизЛицо(ВыборкаДетальныеЗаписи.ФизЛицо, Константы.КоличествоСимволовВИмени.Получить());

		Строка = СтрШаблон("<code>%1 | %2 | %3%4</code>", ФизЛицо, ВыборкаДетальныеЗаписи.Свойство, ВыборкаДетальныеЗаписи.Балл, Символы.ПС);
		Массив.Добавить(Строка);
		
	КонецЦикла;
	
	Массив.Добавить(Символы.ПС + "______________" + Символы.ПС);
	СообщениеВЧат = СтрСоединить(Массив);
	
	Возврат СообщениеВЧат;


КонецФункции

&НаСервере
Функция ПолучитьДатуПоследнегоИзменения()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МАКСИМУМ(ОстаткиПоДушнилам.Период) КАК Дата
		|ИЗ
		|	РегистрНакопления.ОстаткиПоДушнилам КАК ОстаткиПоДушнилам";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Массив = Новый Массив;
	Массив.Добавить(Символы.ПС + "<b>Дата внесения изменений:</b>" + Символы.ПС);
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл

		Строка = СтрШаблон("<code>%1</code>", ВыборкаДетальныеЗаписи.Дата);
		Массив.Добавить(Строка);
		
	КонецЦикла;
	
	Массив.Добавить(Символы.ПС + "______________" + Символы.ПС);
	СообщениеВЧат = СтрСоединить(Массив);
	
	Возврат СообщениеВЧат;


КонецФункции

&НаСервере
Функция ВыровнятьФизЛицо(Знач ФизЛицо, КоличествоСимволов)
	
	Пока СтрДлина(ФизЛицо) <= КоличествоСимволов Цикл
		ФизЛицо = ФизЛицо + Символы.НПП;
	КонецЦикла;
	
	Возврат ФизЛицо;
	
КонецФункции

&НаСервере
Функция ПолучитьСообщениеПолностью(МассивСообщений)
	
	Возврат СтрСоединить(МассивСообщений);
	
КонецФункции

&НаСервере
Процедура ОтправитьИзмененияНаСервере() Экспорт
	
	МассивСообщений = Новый Массив;
	
	ПоследняяДатаИменений = Константы.ДатаИмененей.Получить();
	ТекущаяДатаИменений = ПолучитьДатуИзменений();
	Если ПоследняяДатаИменений <> ТекущаяДатаИменений Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ПРЕДСТАВЛЕНИЕ(ОстаткиПоДушнилам.ФизЛицо.ФИОПолностью) КАК ФизЛицо,
			|	ПРЕДСТАВЛЕНИЕ(ОстаткиПоДушнилам.Свойство) КАК Свойство,
			|	ВЫБОР
			|		КОГДА ОстаткиПоДушнилам.ВидДвижения = &ВидДвиженияПриход
			|			ТОГДА ОстаткиПоДушнилам.Балл
			|		ИНАЧЕ -ОстаткиПоДушнилам.Балл
			|	КОНЕЦ КАК Балл,
			|	ОстаткиПоДушнилам.Комментарий КАК Комментарий
			|ИЗ
			|	РегистрНакопления.ОстаткиПоДушнилам КАК ОстаткиПоДушнилам
			|ГДЕ
			|	ОстаткиПоДушнилам.Период > &ПоследняяДатаИменений";
		
		Запрос.УстановитьПараметр("ПоследняяДатаИменений", ПоследняяДатаИменений);
		Запрос.УстановитьПараметр("ВидДвиженияПриход", ВидДвиженияНакопления.Приход);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		МассивСообщений.Добавить("<b>В базе данных произошли изменения</b>" + Символы.ПС);
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			МассивСообщений.Добавить(СтрШаблон("<code>%1 | %2 | %3 | Комментарий: %4%5</code>", 
												ВыборкаДетальныеЗаписи.ФизЛицо,
												ВыборкаДетальныеЗаписи.Свойство,
												ВыборкаДетальныеЗаписи.Балл,
												ВыборкаДетальныеЗаписи.Комментарий, 
												Символы.ПС));
		КонецЦикла;
	
	КонецЕсли;
	
	
	Если МассивСообщений.Количество() > 1 Тогда
		
		ОтправитьСообщение(Константы.ИдентификаторГлавнойГруппы.Получить(), СтрСоединить(МассивСообщений));
		ПолучитьСообщенияНаСервере();
		
	КонецЕсли;
	
	Константы.ДатаИмененей.Установить(ТекущаяДатаИменений);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьДатуИзменений()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МАКСИМУМ(ОстаткиПоДушнилам.Период) КАК ДатаИменений
		|ИЗ
		|	РегистрНакопления.ОстаткиПоДушнилам КАК ОстаткиПоДушнилам";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.ДатаИменений;
	КонецЕсли;

	Возврат Дата(1,1,1);
	
КонецФункции

&НаСервере
Процедура ОтправитьСообщение(ChatId, ТекстСообщения)
	
	ПростоОтправитьСообщениеВчатНаСервере(ТекстСообщения);

КонецПроцедуры

&НаСервере
Процедура ПрочитатьПоследниеСообщенияНаСервере() Экспорт
	
	Сообщения = Телеграмм.ПолучитьСообщения();
	АйдиПоследнегоСообщения = Константы.АйдиПоследнегоСообщения.Получить();
	ИдентификаторГлавнойГруппы = Константы.ИдентификаторГлавнойГруппы.Получить();
	
	//читаем собщения
	ЧтениеJSON= Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Сообщения);
	СтруктураСобщений = ПрочитатьJSON(ЧтениеJSON);
	
	ПоследнийАйдиСообщения = Константы.ПоследнийАйдиСообщения.Получить();
	
	Если СтруктураСобщений.ok Тогда
		РезультатСообщения = СтруктураСобщений.result;
		//теперь читаем результат
		Если РезультатСообщения.Количество() Тогда
			Для Каждого Сообщение Из РезультатСообщения Цикл
				Если Сообщение.Свойство("message") Тогда
					АйдиЧата = Сообщение.message.chat.id;
					Если АйдиЧата = Число(ИдентификаторГлавнойГруппы) И Сообщение.update_id > АйдиПоследнегоСообщения Тогда
						Если Сообщение.message.Свойство("text") Тогда
							
							//
							СообщниеИзЧата = Сообщение.message.text;
							// проверяем что сообщение для ванессы
							Если Лев(СообщниеИзЧата, 1) = "/" Тогда
								
								Ответ = ПолучитьОтветНаСообщение(СообщниеИзЧата);
								
								Если  Не ПустаяСтрока(Ответ) Тогда
									//Автор = Сообщение.message.from.first_name;
									Если Сообщение.message.from.Свойство("username") Тогда
										Автор = Сообщение.message.from.username;
									Иначе
										Автор = Сообщение.message.from.first_name;
									КонецЕсли;
									
									ТекстСообщения = СтрШаблон("%1, %2", Автор, Ответ);
									ПростоОтправитьСообщениеВчатНаСервере(ТекстСообщения);
									
									Константы.АйдиПоследнегоСообщения.Установить(Сообщение.update_id);
								КонецЕсли; 
							КонецЕсли;
							
							
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПростоОтправитьСообщениеВчатНаСервере(ТекстСообщения = "")
	
	ОтправкаВТелеграм = Новый HTTPСоединение("api.telegram.org",443,,,,15,Новый ЗащищенноеСоединениеOpenSSL());
	ОтправкаВТелеграм.Получить(Новый HTTPЗапрос(ПолучитьСтрокуHTTPЗапроса(,ТекстСообщения)));

КонецПроцедуры

&НаСервере
Функция ПолучитьОтветНаСообщение(Тег)
	
	Если НРег(Тег) = "/инфо" Тогда
		
		МассивСообщений = ВыслатьИнфо();
		МассивСообщений = ОбрамитьВТегHTML(МассивСообщений, "<code>");
		ПолучитьМассивКоманд(МассивСообщений);
		
		Возврат СтрСоединить(МассивСообщений, Символы.ПС);
		
	ИначеЕсли СтрНайти(Тег, "/шутка") Тогда
		
		НазваниеШутки = РазделитьСообщениеСДвухЭлементов(Тег);

		Возврат НайтиШуткуПоНазванию(НазваниеШутки);

	ИначеЕсли НРег(Тег) = "/статистика" Тогда
		
		ПолучитьСообщенияНаСервере();
		
		Возврат "Выслала";
		
	ИначеЕсли СтрНайти(Тег, "/добавитьшутку") Тогда
		
		СтруктураСообщения = РазделитьСообщение(Тег);
		Если СтруктураСообщения.Количество() Тогда
			
			СоздатьЗаписьВРегистреШуток(СтруктураСообщения.Тег, СтруктураСообщения.Ответ);
			
		КонецЕсли;
		
		Возврат "Добавила шутку!";
		
	ИначеЕсли СтрНайти(Тег, "/добавитьпривет") Тогда
		
		СтруктураСообщения = РазделитьСообщение(Тег);
		Если СтруктураСообщения.Количество() Тогда
			
			СоздатьЗаписьВРегистреПриветствий(СтруктураСообщения.Ответ);
			
		КонецЕсли;
		
		Возврат "Добавила приветствие!";
		
	ИначеЕсли СтрНайти(Тег, "/добавить") Тогда
		
		СтруктураСообщения = РазделитьСообщение(Тег);
		Если СтруктураСообщения.Количество() Тогда
			
			СоздатьЗаписьВРегистреТегов(СтруктураСообщения.Тег, СтруктураСообщения.Ответ)
			
		КонецЕсли;
		
		Возврат "Добавила!";
	
	
	ИначеЕсли СтрНайти(Тег, "/списокшуток") Тогда
		
		МассивШуток = ВывестиНазванияШуток();
		МассивШуток = ОбрамитьВТегHTML(МассивШуток, "<code>");
		
		Возврат СтрСоединить(МассивШуток, Символы.ПС);

	ИначеЕсли СтрНайти(Тег, "/тестирование") Тогда
		
		Возврат НачатьТестирование();
		
	ИначеЕсли СтрНайти(Тег, "/шар") Тогда
		
		ПутьКфайлу = ПолучитьЗначениеШараНаСервере();
		ОтправитьФотоВЧатНаСервере(ПутьКФайлу);
		Возврат "...";
		
	ИначеЕсли СтрНайти(Тег, "/новости") Тогда
		
		Возврат "Пока новостей нет";
		
	ИначеЕсли СтрНайти(Тег, "/случайное") Тогда
		
		СтруктураСообщения = РазделитьСообщениеНа2Числа(Тег);
		Если СтруктураСообщения.Количество() Тогда
			
			Возврат СлучайноеЧисло(СтруктураСообщения.Начальное, СтруктураСообщения.Конечное)

		Иначе
			
			Возврат СлучайноеЧисло()
			
		КонецЕсли;
	Иначе

		ОтветноеСообщение = ВыслатьОтветПоТегу(Тег);
		
		Возврат СтрСоединить(ОтветноеСообщение, "");
		
	КонецЕсли;
	
	Возврат "Что-то пошло не так!";
	
КонецФункции

&НаСервере
Процедура ОтправитьФотоВЧатНаСервере(ПутьКФайлу)
	 
	
	ИмяФайла = ПолучитьИмяВременногоФайла("jpg");
	
	// мТекущееОсновноеИзображение.Записать(ИмяФайла);
	
	ФайлСФото = Новый Файл(ИмяФайла);
	
	СтрокаСоединения = "bot" + Константы.ТокенБота.Получить() + "/sendPhoto";
	
	Boundary = "----"+Строка(Новый УникальныйИдентификатор());
	
	//Определяем массив для процедуры ОбъединитьФайлы
	
	МассивФайловДляОбъединения = Новый Массив;
	
	//Формируем начальный фрагмент файла POST-запроса
	
	ИмяФайлаОтправкиНачало = ПолучитьИмяВременногоФайла("txt");
	ФайлОтправкиНачало = Новый ЗаписьТекста(ИмяФайлаОтправкиНачало, КодировкаТекста.UTF8);
	
	//Формируем конечный фрагмент файла POST-запроса
	
	ИмяФайлаОтправкиКонец = ПолучитьИмяВременногоФайла("txt");
	ФайлаОтправкиКонец = Новый ЗаписьТекста(ИмяФайлаОтправкиКонец, КодировкаТекста.UTF8);
	
	ТекстДляОтправки = "";
	
	ТекстДляОтправки = ТекстДляОтправки + "--" + Boundary + Символы.ПС;
	ТекстДляОтправки = ТекстДляОтправки + "Content-Disposition: form-data; name=""chat_id""" + Символы.ПС + Символы.ПС + СтрЗаменить(Формат(Константы.ИдентификаторГлавнойГруппы.Получить(), "ЧДЦ=0; ЧС=; ЧРГ=.; ЧГ=0"), ".", "") + Символы.ПС;
	
	ТекстДляОтправки = ТекстДляОтправки + "--" + Boundary + Символы.ПС;
	ТекстДляОтправки = ТекстДляОтправки + "Content-Disposition: form-data; name=""photo""; filename=""/" + ФайлСФото.Имя + """" + Символы.ПС;
	ТекстДляОтправки = ТекстДляОтправки + "Content-Type: image/jpeg" + Символы.ПС;
	
	ФайлОтправкиНачало.ЗаписатьСтроку(ТекстДляОтправки);
	ФайлОтправкиНачало.Закрыть();
	
	МассивФайловДляОбъединения.Добавить(ИмяФайлаОтправкиНачало);
	
	МассивФайловДляОбъединения.Добавить(СокрЛП(ПутьКФайлу));
	
	ТекстДляОтправки = "" + Символы.ПС;
	ТекстДляОтправки = ТекстДляОтправки + "--" +  Boundary+"--";
	
	ФайлаОтправкиКонец.ЗаписатьСтроку(ТекстДляОтправки);
	ФайлаОтправкиКонец.Закрыть();
	МассивФайловДляОбъединения.Добавить(ИмяФайлаОтправкиКонец);
	
	ИмяФайлаОтправки = ПолучитьИмяВременногоФайла("txt");
	ОбъединитьФайлы(МассивФайловДляОбъединения, ИмяФайлаОтправки);
	
	HTTPЗапрос = Новый HTTPЗапрос;
	Заголовки = Новый Соответствие;
	
	HTTPЗапрос.Заголовки.Вставить("Connection", "keep-alive");
	HTTPЗапрос.Заголовки.Вставить("Content-Type", "multipart/form-data; boundary="+Boundary);
	
	HTTPЗапрос.УстановитьИмяФайлаТела(ИмяФайлаОтправки);
	HTTPЗапрос.АдресРесурса = СтрокаСоединения;
	
	HTTPСоединение = Новый HTTPСоединение("api.telegram.org",443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	
	Попытка
		Ответ = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
		
		КодСостояния     = Ответ.КодСостояния;
		СтрокаОтвета     = Ответ.ПолучитьТелоКакСтроку();
		
		
		Если КодСостояния = 200 тогда
			ЧтениеОтвета = Новый ЧтениеJSON;
			ЧтениеОтвета.УстановитьСтроку(СтрокаОтвета);
			РезультатСтруктура = ПрочитатьJSON(ЧтениеОтвета);
			Если РезультатСтруктура.ok = Истина Тогда
				СтруктураMessage = РезультатСтруктура.result;
			КонецЕсли;
		Иначе
			Сообщить("КодСостояния "+КодСостояния);
			Сообщить(СтрокаОтвета);
		КонецЕсли;
	Исключение
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
КонецПроцедуры

&НаСервере
Функция ПолучитьЗначениеШараНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ШарСудьбы.Текст КАК Текст
		|ИЗ
		|	РегистрСведений.ШарСудьбы КАК ШарСудьбы";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	

	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		ТабТекстыПриветствий = Запрос.Выполнить().Выгрузить();
		КоличествоТекстов = ТабТекстыПриветствий.Количество();
		
		ГСЧ = Новый ГенераторСлучайныхЧисел();
		СлучайноеЧисло = ГСЧ.СлучайноеЧисло(0, КоличествоТекстов - 1);
		
		Возврат ТабТекстыПриветствий[СлучайноеЧисло].Текст;
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция РазделитьСообщениеНа2Числа(Сообщение)
	
	МассивСообщения = СтрРазделить(Сообщение, " ");
	
	Структура = Новый Структура;
	Если МассивСообщения.Количество() = 3 Тогда
		
		Если МассивСообщения[0] = "/случайное" Тогда
			
			Структура.Вставить("Начальное", МассивСообщения[1]);
			Структура.Вставить("Конечное", МассивСообщения[2]);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Структура;

КонецФункции

&НаСервере
Процедура СоздатьЗаписьВРегистреТегов(Тег, Ответ)

	МенеджерЗаписи = РегистрыСведений.ТегиВаннессы.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Тег = Тег;
	МенеджерЗаписи.Ответ = Ответ;
	МенеджерЗаписи.Записать();

КонецПроцедуры

&НаСервере
Процедура СоздатьЗаписьВРегистреПриветствий(Текст)

	МенеджерЗаписи = РегистрыСведений.Приветствия.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Период = ТекущаяДата();
	МенеджерЗаписи.Текст = Текст;
	МенеджерЗаписи.Записать();

КонецПроцедуры

&НаСервере
Процедура ПолучитьМассивКоманд(МассивСообщений)

	МассивСообщений.Добавить("Команды:");
	МассивСообщений.Добавить(Символы.ПС);
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	(ВЫРАЗИТЬ(КомандыВанессы.Команда КАК СТРОКА(100))) + "" "" + (ВЫРАЗИТЬ(КомандыВанессы.Описание КАК СТРОКА(100))) КАК Сообщение
		|ИЗ
		|	РегистрСведений.КомандыВанессы КАК КомандыВанессы";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		МассивСообщений.Добавить(ВыборкаДетальныеЗаписи.Сообщение + Символы.ПС);
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура СоздатьЗаписьВРегистреШуток(НазваниеШутки, ТекстШутки)

	МенеджерЗаписи = РегистрыСведений.Шутки.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Период = ТекущаяДата();
	МенеджерЗаписи.НазваниеШутки = НазваниеШутки;
	МенеджерЗаписи.ТекстШутки = ТекстШутки;
	МенеджерЗаписи.Записать();

КонецПроцедуры

&НаСервере
Функция НайтиШуткуПоНазванию(НазваниеШутки)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Шутки.ТекстШутки КАК ТекстШутки
		|ИЗ
		|	РегистрСведений.Шутки КАК Шутки
		|ГДЕ
		|	Шутки.НазваниеШутки = &НазваниеШутки";
	Запрос.УстановитьПараметр("НазваниеШутки", НазваниеШутки);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	МассивШуток = РезультатЗапроса.Выгрузить().ВыгрузитьКолонку("ТекстШутки");

	Возврат СтрСоединить(МассивШуток, Символы.ПС);
	
КонецФункции

#КонецОбласти

#Область ОБРАБОТКА_ВХОДЯЩИХ_СООБЩЕНИЙ

&НаСервере
Функция ВыслатьИнфо(Тег = "")

	Запрос = Новый Запрос();
	УслованиеТестирования = "";
	ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ТегиВаннессы.Тег КАК Тег
		|ИЗ
		|	РегистрСведений.ТегиВаннессы КАК ТегиВаннессы
		|УслованиеТестирования";
	
	Если Не ПустаяСтрока(Тег) Тогда
		УслованиеТестирования = "
		|ГДЕ
		|	ТегиВаннессы.Тег = &Тег";

		Запрос.УстановитьПараметр("Тег", Тег);
	КонецЕсли;
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "УслованиеТестирования", УслованиеТестирования);
	
	Запрос.Текст = ТекстЗапроса;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат ПолучитьМассивИзРезультатаЗапроса(РезультатЗапроса, "Тег")

КонецФункции

&НаСервере
Функция ВыслатьОтветПоТегу(Тег)

	Запрос = Новый Запрос();
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТегиВаннессы.Ответ КАК Ответ
		|ИЗ
		|	РегистрСведений.ТегиВаннессы КАК ТегиВаннессы
		|ГДЕ
		|	ТегиВаннессы.Тег = &Тег";
	
	Запрос.УстановитьПараметр("Тег", Тег);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат ПолучитьМассивИзРезультатаЗапроса(РезультатЗапроса, "Ответ")

КонецФункции

&НаСервере
Функция ВывестиНазванияШуток(НазваниеШутки = "")

	Запрос = Новый Запрос;
	УслованиеТестирования = "";
	ТекстЗапроса = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Шутки.НазваниеШутки КАК НазваниеШутки
		|ИЗ
		|	РегистрСведений.Шутки КАК Шутки
		|УслованиеТестирования";
	
	Если Не ПустаяСтрока(НазваниеШутки) Тогда
		УслованиеТестирования = "
		|ГДЕ
		|	Шутки.НазваниеШутки = &НазваниеШутки";
		Запрос.УстановитьПараметр("НазваниеШутки", НазваниеШутки);
	КонецЕсли;
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "УслованиеТестирования", УслованиеТестирования);
	
	Запрос.Текст = ТекстЗапроса;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат ПолучитьМассивИзРезультатаЗапроса(РезультатЗапроса, "НазваниеШутки")

КонецФункции // ВывестиНазванияШуток()


#КонецОбласти

#Область ВСПОМОГАТЕЛЬНЫЕ_ПРОЦЕДУРЫ_И_ФУНКЦИИ

&НаСервере
Функция ОбрамитьВТегHTML(СообщениеМассив, ТегHTML = "<b>")
	
	ЗакрывающийТег = ПолучитьЗакрывающийТегHTML(ТегHTML);
	Массив = Новый Массив;
	
	Массив.Добавить(ТегHTML);
	Для Каждого ЭлементМассива Из СообщениеМассив Цикл
		Массив.Добавить(ЭлементМассива);
	КонецЦикла;
	Массив.Добавить(ЗакрывающийТег);
	
	Возврат Массив;
	
КонецФункции

&НаСервере
Функция ПолучитьЗакрывающийТегHTML(ТегHTML)

	Если Не ПустаяСтрока(ТегHTML) Тогда
		
		Возврат СтрЗаменить(ТегHTML, "<", "</");

	КонецЕсли;

	Возврат ТегHTML;
	
КонецФункции

&НаСервере
Функция ПолучитьМассивИзРезультатаЗапроса(РезультатЗапроса, Колонка)

	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		Возврат РезультатЗапроса.Выгрузить().ВыгрузитьКолонку(Колонка);
		
	КонецЕсли;
	
	Возврат Новый Массив;

КонецФункции

&НаСервере
Функция РазделитьСообщение(Сообщение)

	Структура = Новый Структура;
	
	Массив = СтрРазделить(Сообщение, " ");
	Сч = 2;
	Если Массив.Количество() >= 3 Тогда
		
		Если Массив[0] = "/добавить" 
			или Массив[0] = "/добавитьшутку" 
			ИЛИ Массив[0] = "/шутка" Тогда //проверка что первый элемент является правильным
			
			НовыйТег = НРег(СтрШаблон("/%1", Массив[1]));
			Ответ = "";
			
			Пока Сч <= Массив.Количество()-1 Цикл
				
				Ответ = Ответ + " " + Массив[Сч];
				
				Сч = Сч + 1;
				
			КонецЦикла;
			
			Структура.Вставить("Тег", НовыйТег);
			Структура.Вставить("Ответ", Ответ);
			
		ИначеЕсли Массив[0] = "/добавитьпривет" Тогда
			
			Сч = 1;
			Ответ = "";
			Пока Сч <= Массив.Количество()-1 Цикл
				
				Ответ = Ответ + " " + Массив[Сч];
				
				Сч = Сч + 1;
				
			КонецЦикла;
			
			Структура.Вставить("Тег", НовыйТег);
			Структура.Вставить("Ответ", Ответ);
			
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Структура;

КонецФункции // РазделитьСообщение()

&НаСервере
Функция РазделитьСообщениеСДвухЭлементов(Сообщение)

	Массив = СтрРазделить(Сообщение, " ");
	
	Если Массив.Количество() = 2 Тогда
		
		Возврат Массив[1];
		
	КонецЕсли;

	Возврат "";

КонецФункции

&НаСервере
Функция ПолучитьСтрокуHTTPЗапроса(Структура = Неопределено, ПроизвольноеСообщение = "")
	
	Если ЗначениеЗаполнено(Структура) Тогда
		
		Возврат СтрШаблон("bot%1/sendMessage?chat_id=%2&text=%3&parse_mode=HTML", 
						Структура.Токен,
						Структура.АйдиЧата,
						Структура.Сообщение);

	КонецЕсли;

	Возврат СтрШаблон("bot%1/sendMessage?chat_id=%2&text=%3&parse_mode=HTML",
						Константы.ТокенБота.Получить(),
						Константы.ИдентификаторГлавнойГруппы.Получить(),
						ПроизвольноеСообщение
	);
	
КонецФункции

&НаСервере
Функция СлучайноеЧисло(Начальное = 0, Конечное = 3999)
	
	Попытка
		НачальноеЧило = Число(Начальное);
	Исключение
		НачальноеЧило = 0;
	КонецПопытки;
	
	Попытка
		КонечноеЧисло = Число(Конечное);
	Исключение
		КонечноеЧисло = 3999;
	КонецПопытки;
	
	ГСЧ = Новый ГенераторСлучайныхЧисел;
	Попытка
		
		СлучайноеЧило = ГСЧ.СлучайноеЧисло(НачальноеЧило, КонечноеЧисло);
		
	Исключение
		
		СлучайноеЧило = ГСЧ.СлучайноеЧисло(0, 3999);
		
	КонецПопытки;
	
	
	Шаблон = СтрШаблон("%1: %2", "Ваше число", СлучайноеЧило);
	Возврат СлучайноеЧило;
	
КонецФункции


#КонецОбласти

#Область ТЕСТИРОВАНИЕ

&НаСервере
Функция НачатьТестирование() Экспорт

	Структура = Новый Структура;
	Структура.Вставить("ВыслатьОтветПоТегу"		, ТестВыслатьОтветПоТегу());
	Структура.Вставить("ВывестиНазванияШуток"	, ТестВывестиНазванияШуток());
	Структура.Вставить("ВыслатьИнфо"			, ТестВыслатьИнфо());
	
	СообщениеМассив = ОбрамитьВТегHTML(ОтправитьРезультатТестирования(Структура), "<code>");
	Возврат СтрСоединить(СообщениеМассив, Символы.ПС);

КонецФункции

&НаСервере
Функция ОтправитьРезультатТестирования(Структура)
	
	Массив = Новый Массив;
	Для Каждого КлючЗначение Из Структура Цикл
		
		Шаблон = СтрШаблон("%1 - %2%3", КлючЗначение.Ключ,
															?(КлючЗначение.Значение, "Пройден", "Не пройден"),
															Символы.НПП);
		Массив.Добавить(Шаблон);
		
	КонецЦикла;
	
	Возврат Массив;
	
КонецФункции

&НаСервере
Функция ТестВыслатьОтветПоТегу()

	ТестПройден = Ложь;
	ОжидаемыйОтвет = "ОК";
	ПолучаемыйРезультат = ВыслатьОтветПоТегу("/тестирование ванессы");
	Если ПолучаемыйРезультат.Количество() Тогда
		Если ПолучаемыйРезультат[0] = ОжидаемыйОтвет ТогДа
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;

	Возврат ТестПройден;
	
КонецФункции

&НаСервере
Функция ТестВывестиНазванияШуток()
	
	ТестПройден = Ложь;
	ОжидаемыйОтвет = "/тестирование ванессы";
	
	ПолучаемыйРезультат = ВывестиНазванияШуток("/тестирование ванессы");

	Если ПолучаемыйРезультат.Количество() Тогда
		Если ПолучаемыйРезультат[0] = ОжидаемыйОтвет ТогДа
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;

	Возврат ТестПройден;
	
КонецФункции

&НаСервере
Функция ТестВыслатьИнфо()

	ТестПройден = Ложь;
	ОжидаемыйОтвет = "/тестирование ванессы";
	
	ПолучаемыйРезультат = ВыслатьИнфо("/тестирование ванессы");

	Если ПолучаемыйРезультат.Количество() Тогда
		Если ПолучаемыйРезультат[0] = ОжидаемыйОтвет ТогДа
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;

	Возврат ТестПройден;

КонецФункции
 

#КонецОбласти

