# 🎰 Deadline Dealers

> KTU studentų kazino žaidimas sukurtas su Godot 4.6 naudojant SCRUM metodologiją.

![Godot](https://img.shields.io/badge/Godot-4.6-blue?logo=godotengine)
![GDScript](https://img.shields.io/badge/Language-GDScript-green)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## Turinys

- [Techninė užduotis](#techninė-užduotis)
- [Paleidimas](#paleidimas)
- [Žaidimai](#žaidimai)
- [Paaiškinimas](#paaiškinimas)
- [Projekto struktūra](#projekto-struktūra)
- [Testavimas](#testavimas)
- [Komanda](#komanda)

---

## Techninė užduotis

**Užsakovas:** kazino žaidimų kūrėjai

### Funkciniai reikalavimai

- Žaidimas skirtas PC platformai (Windows)
- Žaidimas apima **Blackjack** ir **Ruletės** žaidimus
- Žaidėjas pradeda su **1000 USD** pradiniu balansu
- Žaidėjas varžosi Blackjack'e prieš virtualų dalintuvą (AI)
- Ruletėje galima lažintis dėl raudonų/juodų skaičių arba konkretaus skaičiaus (0–36)
- Žaidėjas gali bet kada pereiti tarp žaidimų per pagrindinį meniu
- Sistema rodo žaidėjo balansą **realiu laiku**
- Kai balansas pasiekia 0, rodomas **bankroto pranešimas**
- Žaidėjas gali iš naujo pradėti žaidimą po bankroto su 1000 USD

### Nefunkciniai reikalavimai

- Žaidimas valdomas **pele**
- Palaikoma OS: **Windows 10/11**
- Variklis: **Godot 4.6** (Direct3D 12, Jolt Physics)
- Minimalus RAM: 4 GB
- Disko vieta: ≤ 200 MB

**Reikšminiai žodžiai:** Casino, Blackjack, Roulette, Gambling, Cards

---

## Paleidimas

Jums reikia įdiegti **Godot Engine 4.6**. Parsisiųskite iš [godotengine.org](https://godotengine.org/download/) — papildomi įskiepiai ar priklausomybės nereikalingos.

```bash
git clone https://github.com/DomaMili/deadline-dealers.git
cd deadline-dealers
```

Atidarykite projektą Godot:

1. Paleiskite **Godot 4.6**
2. Spausti **Import** → pasirinkti `project.godot`
3. Spausti **▶ Run** arba **F5**

### Eksportas į .exe

```
Project → Export → Windows Desktop → Export Project
```

---

## Žaidimai

### 🃏 Blackjack

Klasikinis 21 kortų žaidimas prieš dilerį.

| Veiksmas | Aprašymas |
|---|---|
| **Hit** | Gauti papildomą kortą |
| **Stand** | Sustoti ir leisti dileriui žaisti |
| **Double Down** | Padvigubinti statymą, gauti 1 kortą ir automatiškai Stand |

- Minimalus statymas: **$10**
- Ace skaičiuojamas kaip **11** arba **1** (automatiškai)
- Dileris traukia kortą kol pasiekia **≥17**
- Laimėjimas: **2x** statymas; lygiosios grąžina statymą

### 🎡 Roulette

Europietiška ruletė (0–36) su kelių tipų lažybomis.

| Lažybų tipas | Išmoka |
|---|---|
| 🔴 Raudona / ⚫ Juoda | x2 |
| 1–12 / 13–24 / 25–36 | x3 |
| 🔢 Tikslus skaičius | x36 |

Paskutinių **5 sukimų** istorija rodoma ekrane kairėje.

### 💸 Balanso valdymas

- Pradinis balansas: **1000 USD** (kiekvienam naujam žaidimui)
- Balansas rodomas viršutiniame kampe **visuose ekranuose realiu laiku**
- Kai balansas pasiekia **0** — automatiškai rodoma bankroto scena
- Bankroto ekrane paspauskite **„Bandyti vėl"** — balansas atstatomas į 1000 USD ir grįžtama į pagrindinį meniu

---

## Paaiškinimas

Šiame projekte naudojama **Autoload (singleton) architektūra**, kurią Godot siūlo kaip bendrų paslaugų sluoksnį. Kiekvienas autoload yra globalus ir prieinamas iš bet kurios scenos.

```
Autoload sluoksnis (globalus):
  BalanceManager   — žaidėjo pinigai
  StatsManager     — laimėjimų statistika
  AudioManager     — garsai
  SceneTransition  — scenų keitimas

Scenų sluoksnis (naudoja Autoloads):
  Blackjack.gd / Roulette.gd — žaidimo logika
  MainMenu.gd                — navigacija
  Stats.gd / GameOver.gd     — informaciniai ekranai
```

Svarbu: scenų skriptai **nežino vienas apie kitą** — jie bendrauja tik per Autoload sluoksnį.

### BalanceManager (duomenų sluoksnis)

`BalanceManager.gd` saugo žaidėjo balansą ir skleidžia `balance_changed` signalą kiekvieną kartą kai pinigai keičiasi.

```gdscript
# Failas: Scripts/BalanceManager.gd

extends Node

var balance: int = 1000
signal balance_changed(new_balance: int)

func add_balance(amount: int) -> void:
    balance += amount
    balance_changed.emit(balance)

func subtract_balance(amount: int) -> bool:
    if amount > balance:
        return false
    balance -= amount
    balance_changed.emit(balance)
    return true

func can_afford(amount: int) -> bool:
    return balance >= amount
```

`BalanceManager` nežino kas jį iškviečia ar kaip rodomas balansas — jis tik saugo duomenis ir praneša apie pasikeitimus.

### Žaidimo logika (logikos sluoksnis)

Žaidimo skriptai naudoja `BalanceManager` neturėdami žinoti kaip jis veikia viduje. Jiems tereikia žinoti kokias funkcijas jis eksponuoja.

Štai kaip `Blackjack.gd` tvarkosi su statomis ir išmokomis:

```gdscript
# Failas: Scripts/Blackjack/Blackjack.gd

func place_bet() -> void:
    var amount := get_bet_amount()
    if not validate_bet(amount):
        return
    current_bet = amount
    BalanceManager.subtract_balance(current_bet)  # nežinome kaip BalanceManager veikia viduje
    await start_round()

func end_round(player_wins: bool) -> void:
    if player_wins:
        var winnings := current_bet * 2
        BalanceManager.add_funds(winnings)        # tiesiog kviečiame eksponuotą metodą
        StatsManager.record_result(true, winnings - current_bet)
    else:
        StatsManager.record_result(false, 0)
    _check_game_over()

func _check_game_over() -> void:
    if BalanceManager.get_balance() == 0:
        await get_tree().create_timer(1.8).timeout
        get_tree().change_scene_to_file("res://Scenes/GameOver/GameOver.tscn")
```

`Roulette.gd` naudoja tą patį `BalanceManager` — jei pakeistume kaip balansas saugomas, nereikėtų keisti nei Blackjack, nei Roulette kodo.

### UI sluoksnis (pateikimo sluoksnis)

UI nereikia žinoti kaip skaičiuojamas balansas. Jis tiesiog **prisijungia prie signalo** ir atsinaujina kai tik kažkas pasikeičia:

```gdscript
# Failas: Scripts/MainMenu/MainMenu.gd

func _ready() -> void:
    _balance_label.text = "$ " + str(BalanceManager.get_balance())
    BalanceManager.balance_changed.connect(_on_balance_changed)

func _on_balance_changed(new_balance: int) -> void:
    _balance_label.text = "$ " + str(new_balance)
```

Tas pats signalas veikia ir Blackjack, ir Roulette ekranuose — visi automatiškai atsinaujina po kiekvieno laimėjimo ar pralaimėjimo.

### Pilnas srautas

Paimkime pavyzdį: žaidėjas laimi ruletėje.

1. **UI** — žaidėjas pasirenka „Raudona" ir paspaudžia SPIN
2. **Logikos sluoksnis** — `Roulette.gd` apskaičiuoja rezultatą ir iškviečia `BalanceManager.add_balance(winnings)`
3. **Duomenų sluoksnis** — `BalanceManager` atnaujina `balance` ir skleidžia `balance_changed` signalą
4. **UI** — `Roulette.gd` ir `MainMenu.gd` automatiškai gauna signalą ir atnaujina ekrane rodomą skaičių

```
Žaidėjas spauda SPIN
       ↓
Roulette.gd → BalanceManager.add_balance(winnings)
                      ↓
             balance_changed signalas
                      ↓
      ┌───────────────┴───────────────┐
 Roulette UI                    MainMenu UI
 atsinaujina                   atsinaujina
```

---

## Projekto struktūra

```
deadline-dealers/
├── project.godot
├── Assets/
│   ├── Audio/                   # .ogg garso failai
│   └── Images/
│       ├── Cards/               # card_{suit}_{value}.png + card_back.png
│       └── MainMenu/
├── Scenes/
│   ├── Splash/
│   ├── MainMenu/
│   ├── Blackjack/
│   ├── Roulette/
│   ├── Stats/
│   └── GameOver/
└── Scripts/
    ├── Autoload/
    │   └── SceneTransition.gd
    ├── Blackjack/
    │   ├── Blackjack.gd
    │   └── Card.gd
    ├── Roulette/
    │   └── Roulette.gd
    ├── MainMenu/
    │   └── MainMenu.gd
    ├── Stats/
    │   └── Stats.gd
    ├── GameOver/
    │   └── GameOver.gd
    ├── Splash/
    │   └── Splash.gd
    ├── UI/
    │   ├── AnimatedButton.gd
    │   ├── AnimatedBalanceLabel.gd
    │   └── WinParticles.gd
    ├── BalanceManager.gd
    ├── StatsManager.gd
    └── AudioManager.gd
```

---

## Testavimas

Testavimas atliktas **rankiniu būdu** — kiekviena funkcija tikrinama tiesiogiai žaidžiant žaidimą.

| Nr. | Testo aprašymas | Laukiamas rezultatas | Faktinis rezultatas | Statusas |
|-----|-----------------|----------------------|---------------------|----------|
| 1 | Blackjack: Hit paspaudimas kai rankoje < 21 taškų | Nauja korta išdalinama žaidėjui | Korta išdalinama, taškai atnaujinami | ✅ PRAĖJO |
| 2 | Blackjack: Bust — taškai viršija 21 | Žaidėjas pralaimi, rodomas pranešimas | Pranešimas rodomas, balansas atnaujinamas | ✅ PRAĖJO |
| 3 | Blackjack: Ace logika — ranka = 21 su Ace | Ace skaičiuojamas kaip 11 | Ace = 11, teisingas rezultatas | ✅ PRAĖJO |
| 4 | Blackjack: Ace kaip 1 — bust prevencija | Ace pakeičiamas į 1 jei suma > 21 | Ace = 1, žaidimas tęsiamas | ✅ PRAĖJO |
| 5 | Blackjack: Dalintuvas traukia iki 17 | Dalintuvas sustoja ties 17+ | Teisingas elgesys | ✅ PRAĖJO |
| 6 | Blackjack: Double Down | Lažybos dvigubinamos, tik viena korta | Veikia teisingai | ✅ PRAĖJO |
| 7 | Ruletė: Lažybos raudonam, laimimas raudono | Balansas padidinamas x2 | Teisingas mokėjimas | ✅ PRAĖJO |
| 8 | Ruletė: Lažybos skaičiui, teisingas atspėjimas | Balansas padidinamas x36 | Teisingas mokėjimas | ✅ PRAĖJO |
| 9 | Balansas pasiekia 0 Blackjack žaidime | Rodoma bankroto scena | GameOver scena rodoma | ✅ PRAĖJO |
| 10 | Bankrotas: Bandyti Vėl mygtukas | Balansas = 1000, grįžta į meniu | Veikia teisingai | ✅ PRAĖJO |
| 11 | Scenos perėjimas tarp Blackjack ir pagrindinio meniu | Fade in/out animacija | Animacija veikia | ✅ PRAĖJO |
| 12 | Lažybos > balansas (Blackjack) | Klaidos pranešimas | Pranešimas rodomas | ✅ PRAĖJO |

**Rezultatas: 12/12 testų praėjo (100%)**

---

## Komanda

Sukurta KTU studentų kaip SCRUM komandinis projektas.

| Vardas | Rolė | Indėlis |
|--------|------|---------|
| **Andrius Dobravolskas** | Scrum Master | BalanceManager, kodo peržiūros, repozitorija, dokumentacija |
| **Domantas Miliauskas** | Product Owner | Bet Red funkcija, UI apdaila, klaidų taisymas |
| **Džiugas Kaluina** | Kūrėjas | Ruletės lažybų mechanika (x2), Play Again mygtukas |
| **Titas Lendraitis** | Kūrėjas / Menininkas | Blackjack logika, kortų grafika, GAMBA_LYNGG masktas, scenos perėjimai |
| **Mantas Svetnickis** | Kūrėjas | Win/lose pranešimai, bankroto scena, Ruletės Spin ir x36 mechanika |

> *"KTU student addiction intensifies"*
