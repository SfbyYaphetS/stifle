﻿
Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОстаткиПоДушнилам.Записывать = Истина;
	Для Каждого ТекСтрокаНачислениеБаллов Из НачислениеБаллов Цикл
		Движение = Движения.ОстаткиПоДушнилам.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.ФизЛицо = ТекСтрокаНачислениеБаллов.ФизЛицо;
		Движение.Свойство = ТекСтрокаНачислениеБаллов.Свойство;
		Движение.Балл = ТекСтрокаНачислениеБаллов.Балл;
		Движение.Комментарий = Комментарий;
	КонецЦикла;

КонецПроцедуры
