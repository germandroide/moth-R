# moth-R: MOD-SVS (Module-Sequenced Vocal Synthesis) Specification v0.1

This document outlines how to control the moth-R voice engine using a standard Amiga sound tracker (like ProTracker). The engine's custom player interprets a designated voice channel in a unique way.

**Designated Channel:** By convention, Channel 4 (el de más a la derecha en ProTracker) is the voice control channel.

## Core Mapping

| Tracker Element | moth-R Interpretation                                           |
| :-------------- | :-------------------------------------------------------------- |
| **Note (C-4 etc.)**  | **Triggers a Syllable & Sets Pitch:** The player synthesizes the next syllable from the lyrics script and plays it back at the specified note's frequency. |
| **Instrument #**| **Selects Vocal Timbre/Language:** Instrument numbers are used to switch between active voice packs. Ex: `Inst 1` = `es-ES-M`, `Inst 2` = `es-ES-F`, `Inst 3` = `en-UK-M`, etc. |
| **Note OFF**    | Mutes the voice channel, creating rests and staccato effects.   |
| **Volume Column** | Controls the gain/volume of the currently playing syllable.     |

## Effects Mapping (ProTracker Commands)

| Command | Effect Name       | Vocal Interpretation                                        |
| :------ | :---------------- | :---------------------------------------------------------- |
| **1xx** | Portamento Up     | Slides the pitch of the voice upwards.                      |
| **2xx** | Portamento Down   | Slides the pitch of the voice downwards.                    |
| **3xx** | Porta to Note     | **Glissando:** Creates a smooth slide from the previous note's pitch to the new one. The core of realistic singing. |
| **4xy** | Vibrato           | **Vocal Vibrato:** Applies a pitch modulation (LFO) to the voice. `x` for speed, `y` for depth. |
| **Axy** | Volume Slide      | Fades the voice volume up or down.                          |
| **Cxy** | Set Volume        | Sets the volume abruptly.                                   |
| **E9x** | Retrigger Note    | **Stutter Effect:** Re-triggers the same syllable rapidly.    |
| **EFx** | Set Filter        | **(Custom)** Could be mapped to a filter/EQ effect on the voice (e.g., telephone effect). |

*(This specification is preliminary and will be expanded as the engine develops.)*
