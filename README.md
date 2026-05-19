# 🎰 Deadline Dealers

> KTU studentų kazino žaidimas sukurtas su Godot 4.6 naudojant SCRUM metodologiją.

![Godot](https://img.shields.io/badge/Godot-4.6-blue?logo=godotengine)
![GDScript](https://img.shields.io/badge/Language-GDScript-green)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## Turinys

- [Paleidimas](#paleidimas)
- [Žaidimai](#žaidimai)
- [Paaiškinimas](#paaiškinimas)
- [Projekto struktūra](#projekto-struktūra)
- [Komanda](#komanda)

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

## Komanda

Sukurta KTU studentų kaip SCRUM komandinis projektas.

> *"KTU student addiction intensifies"*
