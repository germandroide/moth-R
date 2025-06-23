# moth-R: a voice for the system

![moth-R Banner](https://via.placeholder.com/800x200.png/000000/FFFFFF?text=moth-R)
> *"I can't lie to you about your chances, but... you have my sympathies."*

**moth-R** is a next-generation, multilingual voice synthesis engine for the AmigaOS 68k ecosystem. Inspired by the iconic computer voice from the 'Alien' saga, this project aims to provide a unique, high-quality, and highly efficient voice for the system, for applications, and for the demoscene.

## The Vision

We are creating two distinct, exclusive synthetic voice personas: **moth-R Male** and **moth-R Female**. These are not mere voice samples, but complete "digital actors" with their own unique timbre.

*   **Truly Multilingual:** Each voice will be able to speak multiple languages (starting with Spanish and English) with correct pronunciation, while maintaining its core vocal identity.
*   **Highly Efficient:** By using an advanced hybrid synthesis model (LPC analysis offline, lightweight concatenation online), the engine is designed to run flawlessly on classic 68k hardware.
*   **An Artistic Instrument:** moth-R is designed for creators. The voice can be controlled like a musical instrument within a tracker (MOD-SVS), enabling sung vocals and expressive effects in demos and games.

## Technical Strategy: The "Chimera" Engine

The core of moth-R is a hybrid engine that performs heavy computational work offline on a modern PC, leaving only fast, lightweight tasks for the Amiga.

1.  **Offline (PC):** We analyze a human voice to extract its mathematical "vocal DNA" (LPC coefficients). This DNA is then used to synthetically generate a complete set of phonemes for a target language.
2.  **Online (Amiga):** The Amiga's `moth-r-engine.library` simply receives text, looks up the pre-synthesized phonemes in a compact voice pack (`.vpack`), and concatenates them. This is extremely fast and requires very little CPU power.

This approach gives us a unique, synthetic sound, minimal file sizes, and optimal performance on real hardware.

## How to Contribute

This is an ambitious open-source project. We are looking for:
*   **C/Assembly Developers:** To help build the core engine and tools for AmigaOS 68k.
*   **Demosceners & Musicians:** To push the MOD-SVS system to its limits.
*   **Linguists:** To help build the phonetic dictionaries for new languages.
*   **Testers:** To run and validate the engine on real hardware (A500, A1200, Vampire, PiStorm).

Join us in giving the Amiga a new soul.
