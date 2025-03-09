&НаСервере
Функция ВКМ_МассовоеСозданиеАктовПоПериоду(Период,ТабЧасть) экспорт    
	ТЗРеализации = Новый ТаблицаЗначений; 
	ТЗРеализации.Колонки.Добавить("ВКМ_Договор") ;
	ТЗРеализации.Колонки.Добавить("ВКМ_ДокументРеализация");
	Для каждого стр из ТабЧасть Цикл   
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	РеализацияТоваровУслуг.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|ГДЕ
		|	МЕСЯЦ(РеализацияТоваровУслуг.Дата) = &Месяц
		|	И РеализацияТоваровУслуг.Договор = &Договор";
		
		Запрос.УстановитьПараметр("Договор", стр.ВКМ_Договор);
		Запрос.УстановитьПараметр("Месяц", МЕсяц(Период));
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда 
			НоваяСтрока = ТЗРеализации.Добавить(); 
			НоваяСтрока.ВКМ_Договор = стр.ВКМ_Договор;
			НоваяСтрока.ВКМ_ДокументРеализация = ВыборкаДетальныеЗаписи.Ссылка;
		Иначе
			НовыйДокументРеализация = Документы.РеализацияТоваровУслуг.СоздатьДокумент();  
			ДанныеЗаполнения = Новый Структура; 
			НовыйДокументРеализация.Договор = стр.ВКМ_Договор;
			НовыйДокументРеализация.Организация = стр.ВКМ_Договор.Организация;     
			НовыйДокументРеализация.Ответственный = Пользователи.ТекущийПользователь();
			НовыйДокументРеализация.Дата = ТекущаяДата();   
			//НовыйДокументРеализация.Основание = стр.ВКМ_Основание;
			НовыйДокументРеализация.Контрагент = стр.ВКМ_Договор.Владелец;
            НовыйДокументРеализация.Записать();
			НовыйДокументРеализация.ВКМ_ВыполнитьАвтозаполнение();
			Если НовыйДокументРеализация.ПроверитьЗаполнение() Тогда
				НовыйДокументРеализация.Записать(РежимЗаписиДокумента.Проведение); 
			Иначе
				НовыйДокументРеализация = Документы.РеализацияТоваровУслуг.ПустаяСсылка();
			КонецЕсли;
			НоваяСтрока = ТЗРеализации.Добавить(); 
			НоваяСтрока.ВКМ_Договор = стр.ВКМ_Договор;
			НоваяСтрока.ВКМ_ДокументРеализация = НовыйДокументРеализация.Ссылка;
		КонецЕсли;
	КонецЦикла; 
	возврат ТЗРеализации;
КонецФункции