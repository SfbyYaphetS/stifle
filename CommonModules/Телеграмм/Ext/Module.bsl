﻿
#Область ОСНОВНЫЕ_МЕТОДЫ

&НаСервере
Функция ПолучитьСообщения(ChatId = Неопределено) Экспорт

	ПоследнийАйди = СтрЗаменить(Строка(Константы.АйдиПоследнегоСообщения.Получить()), Символы.НПП, "");
	СоединениеHTTP = Новый HTTPСоединение("api.telegram.org",443,,,,,Новый ЗащищенноеСоединениеOpenSSL());
	Возврат СоединениеHTTP.Получить(Новый HTTPЗапрос("bot" + Строка(Константы.ТокенБота.Получить()) + "/getUpdates" + "?offset=" + 
									ПоследнийАйди)).ПолучитьТелоКакСтроку();

КонецФункции

#КонецОбласти

&НаСервере
Процедура ОтправитьШуткуВЧат() Экспорт
	
	
	
КонецПроцедуры

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
	Массив.Добавить("<b>Доброго времени суток!!!</b>" + Символы.ПС);
	Массив.Добавить("<b>Я - ВАНЕССА, а ты ХУЙ!</b>" + Символы.ПС);
	Массив.Добавить("______________" + Символы.ПС);
	
	Массив.Добавить(ПолучитьОтчетНаСервере());
	Массив.Добавить(ПолучитьРасшифровкуОтчета());
	Массив.Добавить(ПолучитьДатуПоследнегоИзменения());
	ОдноСообщениее = ПолучитьСообщениеПолностью(Массив);
	
	Попытка
		//Отправляем сообщение с указанными AccessToken, ChatId и ТекстСообщения
		ОтправкаВТелеграм = Новый HTTPСоединение("api.telegram.org",443,,,,15,Новый ЗащищенноеСоединениеOpenSSL());
		ОтправкаВТелеграм.Получить(Новый HTTPЗапрос("bot" + Константы.ТокенБота.Получить() + "/sendMessage?chat_id=" + ChatId + "&text=" + ОдноСообщениее + "&parse_mode=HTML"));
	Исключение
		// Здесь может быть обработчик ошибки или вход в резервную функцию
		Сообщить(ОписаниеОшибки());
	КонецПопытки
	
КонецПроцедуры

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
	
	Если НЕ ЗначениеЗаполнено(ChatId) ИЛИ НЕ ЗначениеЗаполнено(ТекстСообщения) Тогда
		Сообщить("Проверьте входящие данные в процедуру");
		Возврат;
	КонеЦЕсли;
	

	Попытка
		//Отправляем сообщение с указанными AccessToken, ChatId и ТекстСообщения
		ОтправкаВТелеграм = Новый HTTPСоединение("api.telegram.org",443,,,,15,Новый ЗащищенноеСоединениеOpenSSL());
		ОтправкаВТелеграм.Получить(Новый HTTPЗапрос("bot" + Константы.ТокенБота.Получить() + "/sendMessage?chat_id=" + ChatId + "&text=" + ТекстСообщения + "&parse_mode=HTML"));
	Исключение
		// Здесь может быть обработчик ошибки или вход в резервную функцию
		Сообщить(ОписаниеОшибки());
	КонецПопытки
	

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
	Попытка
		//Отправляем сообщение с указанными AccessToken, ChatId и ТекстСообщения
		ОтправкаВТелеграм = Новый HTTPСоединение("api.telegram.org",443,,,,15,Новый ЗащищенноеСоединениеOpenSSL());
		ОтправкаВТелеграм.Получить(Новый HTTPЗапрос("bot" + Константы.ТокенБота.Получить() 
													+ "/sendMessage?chat_id=" 
													+ Константы.ИдентификаторГлавнойГруппы.Получить() 
													+ "&text=" + ТекстСообщения 
													+ "&parse_mode=HTML"));
	Исключение
		// Здесь может быть обработчик ошибки или вход в резервную функцию
		Сообщить(ОписаниеОшибки());
	КонецПопытки
КонецПроцедуры

&НаСервере
Функция ПолучитьОтветНаСообщение(Тег)
	
	Запрос = Новый Запрос;
	Если НРег(Тег) = "/инфо" Тогда
		
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ТегиВаннессы.Тег КАК Тег
			|ИЗ
			|	РегистрСведений.ТегиВаннессы КАК ТегиВаннессы";
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		МассивТегов = Новый Массив;
		МассивТегов.Добавить("<code>");
		Пока Выборка.Следующий() Цикл
			МассивТегов.Добавить(Выборка.Тег);
		КонецЦикла;
		МассивТегов.Добавить("</code>");
		
		//МассивТегов = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Тег");
		
		Возврат СтрСоединить(МассивТегов, Символы.ПС);
		
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
		
	ИначеЕсли СтрНайти(Тег, "/добавить") Тогда
		
		СтруктураСообщения = РазделитьСообщение(Тег);
		Если СтруктураСообщения.Количество() Тогда
			
			СоздатьЗаписьВРегистреТегов(СтруктураСообщения.Тег, СтруктураСообщения.Ответ)
			
		КонецЕсли;
		
		Возврат "Добавила!";
		
	
	ИначеЕсли СтрНайти(Тег, "/списокшуток") Тогда
		
		Возврат ВывестиНазванияШуток();

	Иначе
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ТегиВаннессы.Ответ КАК Ответ
			|ИЗ
			|	РегистрСведений.ТегиВаннессы КАК ТегиВаннессы
			|ГДЕ
			|	ТегиВаннессы.Тег = &Тег";
		
		Запрос.УстановитьПараметр("Тег", Тег);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Возврат ВыборкаДетальныеЗаписи.Ответ;
		КонецЦикла;
	КонецЕсли;
	
	Возврат "";
	
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
Процедура СоздатьЗаписьВРегистреТегов(Тег, Ответ)

	МенеджерЗаписи = РегистрыСведений.ТегиВаннессы.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Тег = Тег;
	МенеджерЗаписи.Ответ = Ответ;
	МенеджерЗаписи.Записать();

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

&НаСервере
Функция ВывестиНазванияШуток()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Шутки.НазваниеШутки КАК НазваниеШутки
		|ИЗ
		|	РегистрСведений.Шутки КАК Шутки";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Массив = Новый Массив;
	Массив.Добавить("<code>");
	Пока Выборка.Следующий() Цикл
		Массив.Добавить(Выборка.НазваниеШутки);
	КонецЦикла;
	Массив.Добавить("</code>");
	Возврат СтрСоединить(Массив, Символы.ПС);

КонецФункции // ВывестиНазванияШуток()





