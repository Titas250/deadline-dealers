# 🎰 Deadline Dealers

> KTU studentų kazino žaidimas sukurtas su Godot 4.6

![Godot](https://img.shields.io/badge/Godot-4.6-blue?logo=godotengine) ![GDScript](https://img.shields.io/badge/Language-GDScript-green) ![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)

---

## Žaidimai

### 🃏 Blackjack
Klasikinis 21 žaidimas prieš dilerį.
- Hit, Stand, **Double Down**
- Ace automatiškai skaičiuojamas kaip 1 arba 11
- Dilerio paslėpta korta atsiskleidžia po Stand

### 🎡 Roulette
Europietiška ruletė su kelių tipų lažybomis.
- Raudona / Juoda (x2)
- Konkretus skaičius (x36)
- Dešimtys: 1–12, 13–24, 25–36 (x3)
- Paskutinių 5 sukimų istorija ekrane

---

## Funkcijos

- 💰 **Bendras balansas** — išlaikomas tarp abiejų žaidimų
- 📊 **Statistikos** — žaidimai, laimėjimai, pralaimėjimai, didžiausias laimėjimas
- 💀 **Game Over** — bankroto ekranas kai balansas pasiekia $0
- 🎵 **BGM** — foninė muzika pagrindiniame meniu
- 🎬 **Splash ekranas** — intro animacija su logotipu

---

## Paleidimas

1. Atsisiųsk [Godot 4.6](https://godotengine.org/)
2. Atidaryk `project.godot`
3. Spauski ▶ Run

---

## Projekto struktūra

```
Assets/
  Audio/        # BGM ir SFX failai (.ogg)
  Images/
    Cards/      # 52 kortų PNG (card_{suit}_{value}.png)
Scenes/
  Blackjack/
  Roulette/
  MainMenu/
  Stats/
  GameOver/
  Splash/
Scripts/
  Autoload/     # SceneTransition
  BalanceManager.gd
  StatsManager.gd
  AudioManager.gd
  Blackjack/
  Roulette/
  MainMenu/
```

---

## Komanda

Sukurta KTU studentų kaip SCRUM projektas.
