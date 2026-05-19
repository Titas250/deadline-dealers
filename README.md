# 🎰 Deadline Dealers

> KTU studentų kazino žaidimas sukurtas su Godot 4.6 naudojant SCRUM metodologiją.

![Godot](https://img.shields.io/badge/Godot-4.6-blue?logo=godotengine)
![GDScript](https://img.shields.io/badge/Language-GDScript-green)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## Turinys

- [Apie projektą](#apie-projektą)
- [Žaidimai](#žaidimai)
- [Funkcijos](#funkcijos)
- [Paleidimas](#paleidimas)
- [Valdymas](#valdymas)
- [Techninė informacija](#techninė-informacija)
- [Projekto struktūra](#projekto-struktūra)
- [Garso failai](#garso-failai)
- [Komanda](#komanda)

---

## Apie projektą

**Deadline Dealers** — tai kazino stiliaus žaidimas su dviem klasikiniais azartiniais žaidimais. Projektas sukurtas KTU studentų kaip SCRUM komandinis projektas. Žaidėjas pradeda su **$1000** ir bando kuo daugiau laimėti. Balansas išlaikomas tarp abiejų žaidimų — bankroto atveju rodomas Game Over ekranas.

---

## Žaidimai

### 🃏 Blackjack

Klasikinis 21 kortų žaidimas prieš dilerį.

| Veiksmas | Aprašymas |
|---|---|
| **Hit** | Gauti papildomą kortą |
| **Stand** | Sustoti ir leisti dileriui žaisti |
| **Double Down** | Padvigubinti statymą, gauti 1 kortą ir automatiškai Stand |

**Taisyklės:**
- Minimalus statymas: **$10**
- Ace skaičiuojamas kaip **11** arba **1** (automatiškai, kad neviršytų 21)
- Dileris traukia kortą kol pasiekia **≥17**
- Laimėjimas moka **2x** statymą
- Lygiosios (Push) — statymas grąžinamas
- Dilerio paslėpta korta atsiskleidžia po žaidėjo Stand

### 🎡 Roulette

Europietiška ruletė (0–36) su kelių tipų lažybomis.

| Lažybų tipas | Sąlyga | Išmoka |
|---|---|---|
| 🔴 Raudona | Skaičius raudonuose | x2 |
| ⚫ Juoda | Skaičius juoduose | x2 |
| 🔢 Skaičius | Tikslus skaičius | x36 |
| 1–12 | Skaičius 1–12 | x3 |
| 13–24 | Skaičius 13–24 | x3 |
| 25–36 | Skaičius 25–36 | x3 |

**Papildomos funkcijos:**
- Paskutinių **5 sukimų** istorija ekrane
- Animuotas rato sukimas
- Vizuali skaičių pasirinkimo lentelė (0–36)

---

## Funkcijos

- 💰 **Bendras balansas** — vienas $1000 balansas naudojamas abiejuose žaidimuose
- 📊 **Statistikos ekranas** — žaidimai, laimėjimai, pralaimėjimai, didžiausias laimėjimas, laimėjimų %
- 💀 **Game Over** — bankroto ekranas kai balansas = $0, galimybė pradėti iš naujo su $1000
- 🎬 **Splash ekranas** — intro animacija su Gamba Lyngg logotipu
- 🎵 **Foninė muzika** — BGM pagrindiniame meniu su loopinimo palaikymu
- 🔊 **Garso efektai** — kortų dalinimas, laimėjimas, pralaimėjimas, sukimas
- 🎴 **52 unikalios kortos** — pilnas kaladės sprite sheet padalintas į atskirus PNG
- ✨ **Animacijos** — kortų fade-in, dilerio kortos apvertimas, laimėjimo overlay, mygtukų hover

---

## Paleidimas

### Reikalavimai
- [Godot Engine 4.6](https://godotengine.org/download/)

### Žingsniai

```bash
git clone https://github.com/YOUR_USERNAME/deadline-dealers.git
cd deadline-dealers
```

1. Atidaryti **Godot 4.6**
2. Spausti **Import** → pasirinkti `project.godot`
3. Spausti ▶ **Run** (F5)

### Eksportas (Windows .exe)

`Project → Export → Windows Desktop → Export Project`

---

## Valdymas

Visas žaidimas valdomas **pele** — mygtukai, spinbox'ai, kortų lentelė.

| Veiksmas | Kaip |
|---|---|
| Pasirinkti statymo sumą | SpinBox laukelis |
| Patvirtinti statymą | „PLACE BET" mygtukas |
| Blackjack veiksmai | Hit / Stand / Double Down mygtukai |
| Ruletės lažybos | Spalvos, dešimtys arba skaičių lentelė |
| Sukinėti ruletę | „🎰 SPIN!" mygtukas |
| Grįžti į meniu | „← Back to Menu" mygtukas |

---

## Techninė informacija

### Architektūra

```
Autoloads (globalūs):
  BalanceManager   — žaidėjo balansas, signalai
  SceneTransition  — scenų keitimas su fade animacija
  StatsManager     — statistikų sekimas
  AudioManager     — SFX grojimas

Scenos:
  Splash → MainMenu → Blackjack / Roulette
                    → Stats
                    → GameOver → MainMenu
```

### Autoloads

| Autoload | Paskirtis |
|---|---|
| `BalanceManager` | Balansas, `balance_changed` signalas |
| `SceneTransition` | Fade in/out tarp scenų |
| `StatsManager` | `record_result(won, amount)`, statistikos |
| `AudioManager` | `play_sfx(key)`, kraunа failus iš `Assets/Audio/` |

### Kortų sistema

Kortos saugomos kaip `card_{suit}_{value}.png`:
- **suit**: `0`=♠ Spades, `1`=♥ Hearts, `2`=♦ Diamonds, `3`=♣ Clubs
- **value**: `1`=Ace, `2–10`, `11`=J, `12`=Q, `13`=K

Padalinta iš `deck_sheet_fixed.png` (4823×2096 px, 371×524 px per kortą).

---

## Projekto struktūra

```
deadline-dealers/
├── project.godot
├── Assets/
│   ├── Audio/
│   │   ├── main_menu_bgm.ogg
│   │   ├── card_deal.ogg
│   │   ├── blackjack_win.ogg
│   │   ├── blackjack_lose.ogg
│   │   ├── roulette_spin.ogg
│   │   ├── roulette_win.ogg
│   │   └── roulette_lose.ogg
│   └── Images/
│       ├── Cards/               # 52x card_{suit}_{value}.png + card_back.png
│       ├── MainMenu/
│       └── GAMBA_LYNGG.png
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

## Garso failai

`AudioManager` automatiškai aptinka `.ogg` failus `Assets/Audio/`. Jei failų nėra — žaidimas veikia be garso (klaidos nekyla).

Rekomenduojami nemokamų garsų šaltiniai: [freesound.org](https://freesound.org), [opengameart.org](https://opengameart.org)

---

## Komanda

Sukurta KTU studentų kaip SCRUM komandinis projektas.

> *"KTU student addiction intensifies"*
