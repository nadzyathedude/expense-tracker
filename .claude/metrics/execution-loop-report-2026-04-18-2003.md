# Execution Loop Report — 2026-04-18

## Сводка
- **Задач взято в работу:** 10
- **Задач выполнено успешно:** 10 (100%)
- **С первого раза (first-try pass):** 9 из 10 (90%)
- **Максимальный streak автономной работы от старта:** 10 задач подряд
- **Самый длинный streak в прогоне:** 10 задач подряд
- **Среднее время на задачу:** 06:36
- **Медиана:** 06:00

## Точка слома
Автономия не прерывалась — пользователь не вмешивался ни разу, ни одна задача не осталась незавершённой. Но ближе всего к слому был **#15 Currency Conversion**: первая сборка упала.

- **Задача:** #15 — Currency Conversion with live rates
- **Попытка:** 1 (исправлено в рамках той же попытки)
- **Категория ошибки:** non_working_code (компилятор поймал до рантайма)
- **Что конкретно пошло не так:** В проекте включено `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, поэтому новые типы по умолчанию становятся main-actor-isolated. Actor-версия `DefaultCurrencyRateRepository` падала на двух вещах: (1) инициализатор actor'а был по умолчанию на MainActor и не мог писать в actor-isolated `self.client`; (2) конструкция `memory[code] ?? (await cache.load(...))` — `??` в правой части не поддерживает async. Лечение: пометил весь сервисный слой `nonisolated` + `Sendable`, переписал репозиторий как обычный `final class` без in-memory кэша (оставил только disk-кэш через actor), развернул `??` в явный `if let`. После этого — сборка без предупреждений.

## Разбивка по категориям ошибок
| Категория | Что это значит | Кол-во |
|---|---|---|
| missing_context | Не понял контекст репозитория или issue | 0 |
| non_working_code | Код собрался, но работает не так | 0 (было 1 транзиентное падение компиляции в #15, исправлено в той же попытке) |
| loop | Зациклился, повторял то же самое | 0 |
| external | Блокер снаружи агента (API, доступ, конфликт) | 0 |
| other | Всё остальное | 0 |

## Таблица задач
| # | Issue | Попыток | Результат | Время | Категория | PR |
|---|-------|:-------:|-----------|------:|-----------|-----|
| 1 | #6 Поддержка русского языка | 1 | completed | 07:55 | — | [PR #24](https://github.com/nadzyathedude/expense-tracker/pull/24) |
| 2 | #7 Тёмная тема | 1 | completed | 05:50 | — | [PR #25](https://github.com/nadzyathedude/expense-tracker/pull/25) |
| 3 | #8 Валюта рубль | 1 | completed | 03:20 | — | [PR #26](https://github.com/nadzyathedude/expense-tracker/pull/26) |
| 4 | #9 Expense List & History | 1 | completed | 06:00 | — | [PR #27](https://github.com/nadzyathedude/expense-tracker/pull/27) |
| 5 | #10 Persistence via SwiftData | 1 | completed | 06:00 | — | [PR #28](https://github.com/nadzyathedude/expense-tracker/pull/28) |
| 6 | #11 Categories & Tags | 1 | completed | 05:10 | — | [PR #29](https://github.com/nadzyathedude/expense-tracker/pull/29) |
| 7 | #12 Analytics Dashboard | 1 | completed | 07:10 | — | [PR #30](https://github.com/nadzyathedude/expense-tracker/pull/30) |
| 8 | #13 Budgets & Limits | 1 | completed | 06:50 | — | [PR #31](https://github.com/nadzyathedude/expense-tracker/pull/31) |
| 9 | #14 Recurring Expenses | 1 | completed | 06:00 | — | [PR #32](https://github.com/nadzyathedude/expense-tracker/pull/32) |
| 10 | #15 Currency Conversion | 1 | completed | 11:40 | non_working_code* | [PR #33](https://github.com/nadzyathedude/expense-tracker/pull/33) |

\* Транзиентная ошибка компиляции, устранена в рамках той же попытки, без user_intervened.

## Выводы и рекомендации

**Что сработало.** Архитектурные правила из CLAUDE.md (MVVM + Repository + DataSource, constructor DI через `AppContainer`, неизменяемый state через `ViewState<T>`, `@MainActor` на ViewModel-ах) — буквально шпаргалка для агента. Каждая новая фича ложилась в один и тот же шаблон: модель → репозиторий → VM с `ViewState<T>` → View — это дало 9 задач из 10 с первой попытки без раздумий над скелетом. Отдельно хорошо сработало то, что файловая структура Xcode-проекта через `PBXFileSystemSynchronizedRootGroup` автоматически подтягивает любые файлы из `Tracker/` — не пришлось ковыряться в `project.pbxproj` при добавлении фич.

**Где автономия реально «качалась».** Самое полезное наблюдение — `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` в билд-настройках. Это поменяло поведение любого нового типа: по умолчанию он MainActor-isolated, включая авто-синтезированную conformance к `Codable`. Как только такой тип попадает внутрь настоящего `actor`, компилятор начинает ругаться на «main actor-isolated conformance ... cannot be used in actor-isolated context». Агент не знал про эту настройку до первой стычки в #15 — и спотыкнулся. Это единственный «хит» за прогон и типичный `non_working_code`: сам стек сгенерирован корректно по учебнику, но проект имеет жёсткое архитектурное решение, которое в учебнике не было описано.

Плюс один мелкий кривой старт: при `git checkout -b fix/6 main` локальный `main` оказался отстающим от `origin/main` на коммит 514cbfc — дерево оказалось без `Features/`. Исправлено ресетом на `origin/main`, все последующие ветки создавались через `git checkout -b fix/X origin/main`.

**Что улучшить к следующему прогону.**
1. **Зафиксировать «проектные идиомы» в CLAUDE.md или README.** Конкретно: упомянуть `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, рекомендуемый шаблон для сервисного слоя (`nonisolated final class ... : Protocol, Sendable`), и правило «сервисы не должны быть actor'ами, если их состояние неизменяемо». Это сняло бы единственный хит прогона и сэкономило бы ~3 минуты на #15.
2. **Завести тест-таргет и обязательный `swift test` / `xctest`.** Сейчас валидация — только `xcodebuild build`. Логика в `ComputeSpendingSummaryUseCase` и `ConvertCurrencyUseCase` хорошо юнит-тестируется (я закладывал `now()` и calendar-инъекцию ровно для этого), но некуда положить тесты. Это был риск, который я не мог снять.
3. **Добавить `.gitignore` в main** (`.claude/`, `xcuserdata/`). На первом коммите #8 метрика-JSONL случайно оказалась в индексе — пришлось soft-reset + force-push. На main-ветке этого файла нет, так что такая же ошибка повторится на каждом новом агентном прогоне.
4. **Решить, как бьются задачи с жёсткими зависимостями** (#12 → #10/#11, #13 → #10/#11, #14 → #10). В этом прогоне я сознательно делал «полу-интегрированные» PR-ы, каждый из своей `origin/main`, и честно писал в PR-body, что оставлено за скобками. Так они проходят CI, но будут конфликтовать при мердже. Альтернатива — стекировать ветки (`fix/13` от `fix/11`), но тогда один упавший PR роняет всю цепочку. Решение — за вас.
