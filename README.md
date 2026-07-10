<div align="center">

# 🌌 MonoUI
<img src="./assets/banner.png" alt="MonoUI Banner" width="1000"> <br>
### *Sleek, Modern, and Glassmorphic Dark-Theme UI Library for Roblox*<br>
[![Latest Release](https://img.shields.io/github/v/release/BloodLetters/mono-ui?color=775ada&label=release&style=for-the-badge)](https://github.com/BloodLetters/mono-ui/releases/latest)
[![License](https://img.shields.io/github/license/BloodLetters/mono-ui?color=775ada&style=for-the-badge)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Roblox-000000?style=for-the-badge&logo=roblox&logoColor=white)](https://www.roblox.com)

---
<p align="left">
  <strong>MonoUI</strong> is a high-performance, feature-rich, and highly customizable UI library designed specifically for Roblox script developers. It combines a beautiful glassmorphic dark aesthetic with advanced automation features, built-in state management, and smooth EasingStyle animations.
</p>

</div>

## 🚀 Getting Started

To integrate **MonoUI** into your script, execute the following `loadstring` environment:

```lua
local MonoUI = loadstring(game:HttpGet("[https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau](https://github.com/BloodLetters/mono-ui/releases/latest/download/Release.luau)"))()
```

---

## ✨ Key Features

* **🔍 Live Search Bar** – Real-time component filtering across the active tab, matching both titles and flags instantly.
* **🎛️ Draggable Control HUD** – Compact, rounded quick-toggle bar utilizing Lucide icons with smart anti-accidental click dragging.
* **🔄 Auto Teleport Reload** – Persistence engine that automatically re-registers and reloads your scripts upon server hopping or teleportation.
* **📂 Auto Configuration** – Native state serialization that instantly saves/loads complex types (`Color3`, `Enum.KeyCode`, numbers, toggles) to local storage.
* **🔔 Sliding Notifications** – Toast notification stack in the bottom-right corner featuring smooth bounce-back easing animations.
* **🖥️ Watermark Overlay** – Real-time performance HUD showing engine-accurate FPS, Ping, and local clock time.
* **🎯 Skeletal Hitbox Selector** – Interactive advanced skeleton selection system for precise combat/visual configurations.
* **🤖 Built with MCP Support** – Ready-to-use Model Context Protocol implementation to develop scripts seamlessly using your preferred AI models.

---

## 🛠️ Implementation Example

A complete, production-ready demonstration covering all UI components, callbacks, and configuration handling can be found in the repository:

👉 **[View Full Example Script (example.lua)](https://www.google.com/search?q=./example.lua)**

---

## 🔒 License

Distributed under the **MIT License**. You are completely free to fork, modify, distribute, and integrate MonoUI into both personal and commercial scripts.

```

### 💡 Perubahan yang Dilakukan:
1. **Ukuran Banner**: Menggunakan `<img src="..." width="450">` di dalam `div align="center"` agar ukuran banner tetap rapi, proporsional, dan tidak memenuhi layar (terlalu besar).
2. **Badges Release & Lisensi**: Ditambahkan *dynamic badges* menggunakan Shields.io yang otomatis mengambil tag rilis terbaru langsung dari repositori GitHub kamu (`BloodLetters/mono-ui`). Warna disesuaikan dengan tema gelap keunguan (`#775ada`).
3. **Tipografi & Struktur**: Tata letak diubah agar lebih *scannable*, menggunakan pembatas horizontal (`---`) untuk memisahkan bagian penting, serta ikon emoji yang lebih terkurasi agar terlihat profesional namun modern.

```