# CupTaster 

CupTaster - бесплатное приложения для барист, продавцов и кофеманов, которые занимаются профессиональной дегустацией кофе.

Приложение, которое скоро появится в AppStore, актуально в современном кофейном мире и не имеет других бесплатных или локализованных на русский язык аналогов.

## Суть в кратце

Каппинг (cup-testing) - процесс дегустации кофе.

Дегустацию кофе проводят для оценки качества продукции при закупке и для присуждения кофе категории спешалти. Бариста посещают каппинги, чтобы понять, как лучше работать с тем или иным сортом. Любители кофе могут поучаствовать в каппинге для того, чтобы лучше разбираться в сортах и вкусах. Люди, заинтересованные в кофе, регулярно ходят на каппинги. 

На этих мероприятиях подгатавливается несколько образцов для дегустации и расставляются чашки (от 1 до 5) рядом с каждым образцом. Затем открываются образцы, настраивается помол и т.д. в соответствии с выбранным протоколом для каппинга (у каждой формы для каппинга свой протокол). После образцы оцениваются по выбранной форме для каппинга.

Само приложение нужно для записи и хранения каппингов. Пока предстоит еще много работы, но в приоритете - сделать его удобнее, чем каппинг на бумаге и продуктивнее, чем записи в заметках, а самое главное добавить русскую локализацию.

## Core Data

В приложении используется CoreData для хранения и записи данных о проведенных каппингах.

Основные сущности:

- Cupping - хранит в себе информацию о событии, а так же образцы.
- CuppingForm - хранит информацию о добаленных формах для каппинга.
- Sample - информация об образце, которая заполняется на основе несколких чашек одного сорта кофе.
- QCGroup (quality criteria group) - группа критериев оценки зерна.
- QualityCriterua - критерий оценки зерна, который заполняется относительно указанного свойства evaluationType, все варианты заполнения и соответсвуйщий интерфейс рассмотрены в папке [Evaluation](https://github.com/nnnkbrrr/CupTaster/tree/main/CupTaster/Sample/Evaluation), где HeaderValues - структуры с отображением и анимациней изменения критерия оценки, SubViews - структуры с отображением способов ввода значений, а так же дополнительные файлы с отображением отдельных частей ввода значений.

Ниже можно посмотреть на все сущности базы данных и их зависимости друг от друга:

<img width="988" alt="CupTaster DB" src="https://user-images.githubusercontent.com/101638182/203571054-a2008333-9a19-4d67-a9b6-13754e3e6b4a.png">
