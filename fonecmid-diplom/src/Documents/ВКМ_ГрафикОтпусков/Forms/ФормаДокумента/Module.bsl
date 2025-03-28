
&НаКлиенте
Процедура ОтпускаСотрудниковПриИзменении(Элемент)
	ТекущиеДанные = Элементы.ОтпускаСотрудников.ТекущиеДанные;	
	ТекущиеДанные.КоличествоДней = (НачалоДня(ТекущиеДанные.ДатаОкончания) - НачалоДня(ТекущиеДанные.ДатаНачала)) / (60 * 60 * 24);
КонецПроцедуры

&НаКлиенте
Процедура АнализГрафика(Команда)   
	АдресОтпусковВХранилище = ПоместитьТоварыВХранилище(); 
	ПараметрыПодбора = Новый Структура("АдресОтпусковВХранилище", АдресОтпусковВХранилище);  
	ПараметрыПодбора.Вставить("Год",Объект.Год);
	ФормаПодбора = ОткрытьФорму("Документ.ВКМ_ГрафикОтпусков.Форма.Форма_АнализГрафика", ПараметрыПодбора, ЭтаФорма);
КонецПроцедуры

&НаСервере
Функция ПоместитьТоварыВХранилище()
	Возврат ПоместитьВоВременноеХранилище(Объект.ОтпускаСотрудников.Выгрузить(,"Сотрудник,ДатаНачала,ДатаОкончания"));
КонецФункции