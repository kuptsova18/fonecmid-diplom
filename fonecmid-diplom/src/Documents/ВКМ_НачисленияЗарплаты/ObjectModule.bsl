
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	СформироватьДвижения();
	РассчитатьОклад(); 
	РассчитатьОтпуск();
	РассчитатьУдержания(); 
	СформироватьДвиженияВзаиморасчетов();
КонецПроцедуры

Процедура СформироватьДвижения()    
	Для каждого строка из Начисления Цикл 
		Движение = Движения.ВКМ_ОсновныеНачисления.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = строка.ВидРасчета;
		Движение.ПериодДействияНачало = строка.ДатаНачала;
		Движение.ПериодДействияКонец = строка.ДатаОкончания; 
		Движение.БазовыйПериодНачало = строка.ДатаНачала;
		Движение.БазовыйПериодКонец = строка.ДатаОкончания;
		Движение.Сотрудник = строка.Сотрудник;
		Движение.ГрафикРаботы = строка.ГрафикРаботы;
		Если Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск Тогда
			Движение.КалендарныеДни = (НачалоДня(строка.ДатаОкончания) - НачалоДня(строка.ДатаНачала)) / (60 * 60 * 24);
		КонецЕсли;
		
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.БазовыйПериодНачало = строка.ДатаНачала;
		Движение.БазовыйПериодКонец = строка.ДатаОкончания;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.Сотрудник = строка.Сотрудник;
	КонецЦикла;  
	Движения.ВКМ_ОсновныеНачисления.Записать(); 
	Движения.ВКМ_Удержания.Записать();
КонецПроцедуры 

Процедура РассчитатьОклад()  
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник
		|ПОМЕСТИТЬ ВТ_ОснНачисл
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
		|			Регистратор = &Ссылка
		|				И ВидРасчета = &ВидРасчета) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.Оклад КАК Оклад,
		|	ВТ_ОснНачисл.НомерСтроки КАК НомерСтроки,
		|	ВТ_ОснНачисл.Сотрудник КАК Сотрудник
		|ИЗ
		|	ВТ_ОснНачисл КАК ВТ_ОснНачисл
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних
		|		ПО ВТ_ОснНачисл.Сотрудник = ВКМ_УсловияОплатыСотрудниковСрезПоследних.Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка); 
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад);

	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновныеНачисления[ВыборкаДетальныеЗаписи.НомерСтроки - 1];
		Движение.Результат = ВыборкаДетальныеЗаписи.Оклад;
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(,Истина);
КонецПроцедуры 

Процедура РассчитатьОтпуск()  
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеПериодДействия КАК План,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия КАК Факт,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник,
		|	РАЗНОСТЬДАТ(ВКМ_ОсновныеНачисленияДанныеГрафика.ПериодДействияНачало, ВКМ_ОсновныеНачисленияДанныеГрафика.ПериодДействияКонец, ДЕНЬ) КАК КолДней
		|ПОМЕСТИТЬ ВТ_ОснНачисл
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
		|			Регистратор = &Ссылка
		|				И ВидРасчета = &ВидРасчета) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СУММА(ВКМ_ОсновныеНачисленияДанныеГрафика.Результат) КАК Оклад12Месяцев,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник
		|ПОМЕСТИТЬ ВТ_НАчисл12Месяцев
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
		|			ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.ВКМ_ОсновныеНАчисления.Оклад)
		|				И ПериодРегистрации >= &ДатаНачала
		|				И ПериодРегистрации <= &ДатаКонец) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ОснНачисл.НомерСтроки КАК НомерСтроки,
		|	ВТ_ОснНачисл.План КАК План,
		|	ВТ_ОснНачисл.Факт КАК Факт,
		|	ВТ_ОснНачисл.Сотрудник КАК Сотрудник,
		|	ВТ_НАчисл12Месяцев.Оклад12Месяцев КАК Оклад,
		|	ЕСТЬNULL(ВТ_ОснНачисл.КолДней, 0) КАК КолДней
		|ИЗ
		|	ВТ_ОснНачисл КАК ВТ_ОснНачисл
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_НАчисл12Месяцев КАК ВТ_НАчисл12Месяцев
		|		ПО ВТ_ОснНачисл.Сотрудник = ВТ_НАчисл12Месяцев.Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);  
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск);  
	Запрос.УстановитьПараметр("ДатаКонец",Дата); 
    Запрос.УстановитьПараметр("ДатаНачала", ДобавитьМесяц(Дата,-12)); 
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновныеНачисления[ВыборкаДетальныеЗаписи.НомерСтроки - 1];
		Движение.Результат = (ВыборкаДетальныеЗаписи.Оклад / ВыборкаДетальныеЗаписи.Факт) * ВыборкаДетальныеЗаписи.КолДней;
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(,Истина);
КонецПроцедуры 

Процедура РассчитатьУдержания()  
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
	|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.РезультатБаза КАК РезультатБаза
	|ИЗ
	|	РегистрРасчета.ВКМ_Удержания.БазаВКМ_ОсновныеНачисления(&Измерения, &Измерения, &Разрезы, ) КАК ВКМ_УдержанияБазаВКМ_ОсновныеНачисления
	|ГДЕ
	|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.Регистратор = &Регистратор";
	
	Измерения = Новый Массив(1);
    Измерения[0] = "Сотрудник";
	
	Разрезы = Новый Массив(1);
    Разрезы[0] = "Регистратор";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Измерения", Измерения);
	Запрос.УстановитьПараметр("Разрезы", Разрезы);
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	//Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_Удержания.НДФЛ);
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = Движения.ВКМ_Удержания[ВыборкаДетальныеЗаписи.НомерСтроки - 1];
		Движение.Результат = ВыборкаДетальныеЗаписи.РезультатБаза * 13 / 100;
	КонецЦикла;
	
	Движения.ВКМ_Удержания.Записать(,Истина);
	
КонецПроцедуры

Процедура СформироватьДвиженияВзаиморасчетов()  
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СУММА(ВКМ_ОсновныеНачисления.Результат - ВКМ_Удержания.Результат) КАК СуммаКВыплате,
		|	ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|		ПО ВКМ_ОсновныеНачисления.Сотрудник = ВКМ_Удержания.Сотрудник
		|			И ВКМ_ОсновныеНачисления.Регистратор = ВКМ_Удержания.Регистратор
		|ГДЕ
		|	ВКМ_ОсновныеНачисления.Регистратор = &Регистратор
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ОсновныеНачисления.Сотрудник";
	
	Запрос.УстановитьПараметр("Регистратор", Ссылка);	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Движение = 	Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();  
		Движение.Период = Дата;
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Сотрудник = ВыборкаДетальныеЗаписи.Сотрудник;
		Движение.Сумма = ВыборкаДетальныеЗаписи.СуммаКВыплате;
	КонецЦикла; 
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();

КонецПроцедуры

