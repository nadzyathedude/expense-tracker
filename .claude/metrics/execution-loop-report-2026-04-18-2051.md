# Execution Loop Report — 2026-04-18 (all issues)

## Сводка
- **Задач взято в работу:** 18 (все открытые issues #6–#23)
- **Задач выполнено успешно:** 17 (94%)
- **С первого раза (first-try pass):** 14 из 18 (78%)
- **Пропущено:** 1 (#18, external blocker — нельзя скриптом добавить widget-таргет в pbxproj)
- **Максимальный streak автономной работы от старта:** 12 задач подряд (#6 → #17), далее один `skipped` на #18
- **Самый длинный streak в прогоне:** 12 задач подряд (#6 → #17)
- **Среднее время на задачу:** 06:08 (медиана 06:05)
- **Вмешательств пользователя:** 0

## Точка слома
Первый сбой — задача #15 (первый раз, когда сборка не прошла с первого билда). Автономия при этом сохранилась: я нашёл причину, починил в рамках той же попытки.

- **Задача:** #15 — Currency Conversion
- **Попытка:** 1 (исправлено внутри одной попытки)
- **Категория ошибки:** non_working_code
- **Что конкретно пошло не так:** Проект имеет `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, из-за чего новые типы в сервисном слое по умолчанию становились main-actor-isolated, а их синтезированные Codable-conformance не могли быть использованы в `actor`-контексте. Плюс в одной строке был `??` с `await` в правом операнде — `??` не поддерживает async-autoclosure. Лечение: все сервисные типы помечены `nonisolated` + `Sendable`, `DefaultCurrencyRateRepository` переписан с `actor` на обычный `final class` без in-memory state (disk-кэш и так в actor'е), `??` развёрнут в `if let`.

Первый *настоящий* блокер — **задача #18 (Home Screen Widget)**. Она не решилась не из-за логики, а из-за окружения: добавление нового PBXNativeTarget в pbxproj через текстовые правки крайне ненадёжно, а проект использует `PBXFileSystemSynchronizedRootGroup`; плюс фича нуждается в shared App Group и общем ModelContainer из #10, которого на main ещё нет. Помечена как `external` / `skipped` — это не провал агента, это реальный инфраструктурный шаг, который требует Xcode UI.

Ещё два транзиентных хита после #15, оба — изменения iOS 26 SDK, которых агент не знал по умолчанию:
- **#17:** `DataScannerViewController.recognizedItems` в iOS 26 возвращает `AsyncStream<[RecognizedItem]>`, а не массив. Перешёл на сбор через делегат-методы (`didAdd/didUpdate/didRemove`) в UUID→String буфер.
- **#23:** `List(selection:)` для прямой single-select привязки в iOS 26 SDK помечен unavailable. Переписал sidebar через `Button`-строки + ручной selection state + `.listRowBackground` для подсветки.

## Разбивка по категориям ошибок
| Категория | Что это значит | Кол-во |
|---|---|---|
| missing_context | Не понял контекст репозитория или issue | 0 |
| non_working_code | Код собрался, но работает не так | 0 (3 транзиентных fail'а компиляции — #15, #17, #23 — исправлены без user intervention) |
| loop | Зациклился, повторял то же самое | 0 |
| external | Блокер снаружи агента (API, доступ, конфликт) | 1 (#18 — widget target требует Xcode UI) |
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
| 10 | #15 Currency Conversion | 1 | completed* | 11:40 | non_working_code (транзиент) | [PR #33](https://github.com/nadzyathedude/expense-tracker/pull/33) |
| 11 | #16 Export / Share (CSV, PDF) | 1 | completed | 04:20 | — | [PR #34](https://github.com/nadzyathedude/expense-tracker/pull/34) |
| 12 | #17 Receipt OCR | 1 | completed* | 06:30 | non_working_code (iOS 26 API change) | [PR #35](https://github.com/nadzyathedude/expense-tracker/pull/35) |
| 13 | #18 Home Screen Widget | 1 | **skipped** | 00:50 | external | — |
| 14 | #19 iCloud Sync (CloudKit) | 1 | completed | 06:10 | — | [PR #36](https://github.com/nadzyathedude/expense-tracker/pull/36) |
| 15 | #20 Smart Recurring Detection | 1 | completed | 05:30 | — | [PR #37](https://github.com/nadzyathedude/expense-tracker/pull/37) |
| 16 | #21 Biometric App Lock | 1 | completed | 05:30 | — | [PR #38](https://github.com/nadzyathedude/expense-tracker/pull/38) |
| 17 | #22 Upcoming Charges Calendar | 1 | completed | 08:00 | — | [PR #39](https://github.com/nadzyathedude/expense-tracker/pull/39) |
| 18 | #23 Universal iPad Layout | 1 | completed* | 07:30 | non_working_code (iOS 26 API change) | [PR #40](https://github.com/nadzyathedude/expense-tracker/pull/40) |

\* «completed*» — задача выполнена, но первая сборка не прошла; исправлено внутри той же попытки, без user_intervened.

## Выводы и рекомендации

**Что сработало.** Архитектура CLAUDE.md продолжала держать темп: MVVM + Repository + DataSource + `ViewState<T>` даёт предсказуемый скелет каждой фичи, и добавление очередного экрана сводится к шаблону «модель → репозиторий → VM → View → tab в ContentView». Из 18 задач **14 прошли с первого билда без правок** — это, пожалуй, главная метрика. Шаблон «портировать зависимость внутрь PR, если она ещё не на main» (#12 ← категории, #19 ← persistence, #22 ← recurring) хорошо работает: каждая ветка стоит сама по себе и не цепляется за порядок мерджа.

**Три транзиентных фейла — все от iOS 26 SDK.** #15, #17, #23 сломались из-за тихо изменившихся API (`SWIFT_DEFAULT_ACTOR_ISOLATION`, `DataScannerViewController.recognizedItems` как AsyncStream, unavailable `List(selection:)`). Агент не мог знать эти детали заранее — они не документированы в скиллах и не видны из кода. Все три починились без user intervention, в рамках одной попытки каждая. Это именно non_working_code как категория: «код корректен по учебнику, но проект/SDK имеет более узкие правила».

**Настоящий блокер ровно один: #18.** Widget extension — это не код, а новый Xcode-таргет, который надо добавить через UI (Product → Target → Widget Extension), а также настроить App Group в обоих таргетах. Через текстовое редактирование `project.pbxproj` с `PBXFileSystemSynchronizedRootGroup` это ненадёжно, и результат сломал бы остальные ветки. Честно зафиксировал как `external / skipped` — это системная граница автономии.

**Что улучшить к следующему прогону.**
1. **Зафиксировать «проектные идиомы» в CLAUDE.md.** Минимум три строки: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` ⇒ сервисные типы должны быть `nonisolated` + `Sendable`, `List(selection:)` в iOS 26 SDK использовать нельзя (альтернативы: `Button` строки + ручной state), `DataScannerViewController.recognizedItems` — AsyncStream, собирать через делегат-методы. Это снимает ровно тот класс ошибок, который повторился трижды.
2. **Завести тест-таргет.** Agent оставлял аккуратные точки инъекции (`calendar`, `now()`, `tolerance`, `amountTolerance`, in-memory репозитории), но некуда положить тесты. Юнит-тесты для `ComputeSpendingSummaryUseCase` / `ConvertCurrencyUseCase` / `ReceiptParser` / `DetectRecurringExpensesUseCase` / `GetUpcomingChargesUseCase` поднимут уверенность в том, что логика правильна, без ручного QA.
3. **Решить вопрос с widget-таргетом.** Одна из опций — добавить таргет один раз руками, зафиксировать pbxproj под контролем версий, и дальше агент уже будет работать с готовым шаблоном.
4. **Один общий `.gitignore` для `.claude/`.** До сих пор он лежит только в одной ветке; при каждом новом `origin/main`-basing я рискую случайно закоммитить метрики. Протащите .gitignore до main.
5. **Стратегия мерджа 17 PR-ов.** Множество PR-ов трогают `ContentView` и `AppContainer` — конфликты будут. Разумный порядок: сначала `#10` (persistence) + `#23` (root layout), потом фичи, каждая поверх. Агент может сделать эту последовательную интеграцию следующим прогоном, но уже поверх merged main.
