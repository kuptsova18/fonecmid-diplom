
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Движения.ВКМ_ДниОтпуска.Записывать = Истина; 
	Для каждого стр из ОтпускаСотрудников Цикл
		Движение = Движения.ВКМ_ДниОтпуска.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Сотрудник = стр.Сотрудник;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск;
		Движение.ДнейОтпуска = (НачалоДня(стр.ДатаОкончания) - НачалоДня(стр.ДатаНачала)) / (60 * 60 * 24);; 
		Движение.ДатаНачалаОтпуска = стр.ДатаНачала;
		Движение.ДатаОкончанияОтпуска = стр.ДатаОкончания;
	КонецЦикла;
КонецПроцедуры
