# Sanly Timer - Backend & WebSockets Documentation

Bu resminama, "Sanly Timer" (Bilýard Dolandyryş) ulgamynyň işleýiş logikasyny, esasan hem stollar, sessiýalar we töleg hasaplaýyş (billing) ulgamyny düşündirýär. Ulgamy offline (Isar lokal bazasy) görnüşden, **Backend + WebSockets** arhitekturasyna geçirmek üçin gollanma hökmünde taýýarlandy.

---

## 1. Esasy Dahyllylar (Entities)

### 1.1 Table (Stol)
Stol, oýun oýnalýan we müşderileriň (players) birigýän esasy nokadydyr.
* **Fields**:
  * `id`: Unique identifier (int ýa-da UUID).
  * `name`: Stoluň ady (Meselem: "Stol 1", "VIP 2").
  * `pricePerHour`: Stoluň 1 sagatlyk bahasy (TMT).
  * `status`: Stoluň ýagdaýy -> `available` (Boş) ýa-da `active` (Oýnalýar).

### 1.2 PlayerSession (Müşderi Sessiýasy)
Bir stolda oýnaýan her bir müşderi üçin açylýan sessiýany aňladýar.
* **Fields**:
  * `id`: Unique identifier.
  * `tableId`: Haýsy stolda oýnaýandygy.
  * `playerName`: Müşderiniň ady.
  * `sessionCode`: Gysgaça we täsin (unique) kod (Meselem: "Ad8K2").
  * `startTime`: Sessiýanyň başlan wagty.
  * `endTime`: Sessiýanyň tamamlanan wagty (dowam edýän bolsa `null`).
  * `status`: `active` (oýnaýar) ýa-da `finished` (tamamlandy).
  * `accumulatedCost`: Soňky checkpoint-e çenli edilen töleg (geçen wagt we şol wagtdaky adam sany esasynda).
  * `lastCheckpointTime`: Ýagdaý (adam sany) soňky gezek haçan üýtgän bolsa şol wagt.
  * `totalPrice`: Tamamlanansoň kesgitlenýän jemleýji baha.

---

## 2. Dinamiki Töleg Algoritmi (Billing Logic)

Iň çylşyrymly ýeri tölegiň **paýlaşylmagydyr**. Bir stolda 1 adam oýnasa tutuş bahasyny özi töleýär. Ýylgyryp 2-nji adam gelse, şol gelen pursadyndan başlap baha ikä bölünýär (her biri 50% töleýär). Biri oýundan çyksa (Stop), galan oýunçylar ýene galan wagty öz aralarynda paýlaşyp töleýärler.

Şuny amala aşyrmak üçin **"Checkpoint" (Bölüm/Segment)** algoritmi ulanylýar:

### Checkpoint (Nokat) haçan täzelenýär?
Stolun ýagdaýy ýa-da adamlaryň sany üýtgände (Täze müşderi goşulanda ýa-da bar bolan müşderi çykarylanda) *stoldaky ähli aktiw müşderiler üçin* täze checkpoint döredilýär.

### Algoritm Ädimleri:
Müşderi sany her üýtgände backend şu logikany işletmeli:
1. Şol stoldaky ähli `active` sessiýalaryň (öňden bar bolanlaryň) sanawyny al.
2. `now = DateTime.now()`
3. Eger şu wagt stolda `N` sany aktiw adam bar bolsa, her bir oýunçy üçin:
   - `durationSeconds = now - player.lastCheckpointTime`
   - `segmentCost = (durationSeconds / 3600) * (table.pricePerHour / N)`
   - `player.accumulatedCost += segmentCost`
   - `player.lastCheckpointTime = now`
4. Bazany (Database) şol maglumatlar bilen täzele (Update).
5. Indi täze adamy goşup bilersiňiz ýa-da çykýan adamyň `endTime` we `totalPrice` meýdançalaryny jemläp `finished` edip bilersiňiz.

> **Bellik:** Sessiýa `finished` bolanda `totalPrice = player.accumulatedCost` bolýar.

---

## 3. WebSockets (Real-time Event Architecture)

App we Web Admin arasynda Websocket ulananyňyzda, maglumat bazasyndaky (Backend) islendik üýtgeşiklik pursatlaýyn beýleki client-lere ýaýradylmaly (Broadcast). 

Töleg wagtlary we summalar *Backend-de we App-de parallel hasaplanýar* (App-de `PriceCalculator` ulanylýar), emma iň soňky tassyklanan we maglumat bazasyna ýazylan (truth) maglumat Backend-de galýar.

### Esasy Websocket Hadysalary (Events)

#### 1. `client_connect` (Client -> Server)
Programma açylanda we Websocket baglananda. Initial datany bermeli.
- **Serverden jogap**: `sync_all_data` - Ähli stollaryň, aktiw sessiýalaryň sanawy ugradylýar.

#### 2. `add_player` (Client -> Server)
Täze oýunçy ýa-da oýunçylar goşulanda.
- **Payload**: `tableId`, `playerName`, `reminderMinutes` (eger bar bolsa).
- **Backend logikasy**:
  1. Hälki **Checkpoint logikasyny** işlet: stoldaky beýleki öňki aktiw oýunçylaryň `accumulatedCost`-yny häzirki pursada çenli täzele.
  2. Täze `PlayerSession` döret (startTime = now, lastCheckpointTime = now).
  3. Stoluň ýagdaýyny `active` edip üýtget (eger `available` bolsa).
- **Broadcast on üstünlik**: `table_updated` we `session_added` eventi bilen ähli açyk clientlere ugrat.

#### 3. `stop_player` (Client -> Server)
Bir oýunçynyň wagty tamamlanyp çykanda.
- **Payload**: `sessionId`.
- **Backend logikasy**:
  1. Yene **Checkpoint logikasyny** işlet: (Şol sanda cykyan adamyn hasabynam täzele).
  2. Şol sessiýany `status = finished`, `endTime = now`, `totalPrice = accumulatedCost` diýip ýap.
  3. Taryh (HistoryLog) ýazgysyny döret.
  4. Stolda başga adam galmadymy barlag et. Galmadyk bolsa stol `status = available` edip ýapylýar.
- **Broadcast on üstünlik**: `session_stopped` we zerur bolsa `table_updated`.

#### 4. `close_table` (Client -> Server)
Stolda oýnaýanlaryň barysy birden oýuny saklap töleg edende.
- **Payload**: `tableId`, `payerName`.
- **Backend logikasy**:
  1. Stoldaky ähli `active` sessiýalary tap.
  2. Hemmesiniň soňky **Checkpoint** (segmentCost) hasabyny accumulate et we `endTime = now` goşup `finished` statusyna geçir.
  3. Stoly `available` (Boş) edip ýap.
  4. Toplumlaýyn taryh (HistoryLog) ýazgysyny döret.
- **Broadcast on üstünlik**: `table_closed` (Ähli oýunçylar we stol täzelenendigini client-lere habar berýär).

#### 5. `update_reminder` (Client -> Server)
Sessiýanyň wagt bildirişi üýtgedilende.
- **Payload**: `sessionId`, `minutes`.
- **Backend logikasy**: Sessiyanyň `reminderMinutes` bazasyna täzele (Update).
- **Broadcast**: `reminder_updated`.

---

## 4. Tehniki Maslahatlar Backend Üçin
* **Precision (Takyklyk):** Pul serişdesi hasaplanýandygy sebäpli bahalary ikilikçilerden (double/float) goraň (Meselem, `decimal` maglumat roly).
* **Time Sync:** Websocket ulgamda Client-iň iberýän wagtyna (device time) bil baglamak howply bolup biler. `startTime`, `endTime`, we `lastCheckpointTime` hemişe **Serveriň wagty (Server Now)** esasynda bellik edilmeli.
* **Socket Disconnect:** Eger internet giden ýagdaýynda socket gaçsa, täzeden baglananda Client-e ýetmeyen event-leri diňe `sync_all_data` isläp doly täzelemek maslahat berilýär.
