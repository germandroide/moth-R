# moth-R: a voice for the system

![moth-R Banner](https://raw.githubusercontent.com/germandroide/moth-R/main/docs/assets/moth-r-banner.png)
> *"I can't lie to you about your chances, but... you have my sympathies."*

**moth-R** is a next-generation, multilingual voice synthesis engine for the AmigaOS 68k ecosystem. Inspired by the iconic computer voice from the 'Alien' saga, this project provides a unique, high-quality, and highly efficient voice for the system, applications, and the demoscene.

## Project Vision

moth-R is built around two exclusive synthetic voice personas, Male and Female, who can speak multiple languages while retaining their unique vocal identity. Our hybrid "Chimera" engine performs heavy computations offline, allowing for flawless performance even on classic 68k hardware.

## Quick Links

*   **[Project Roadmap](./ROADMAP.md):** See our development plan and current status.
*   **[Technical Architecture](./docs/ARCHITECTURE.md):** Learn how the "Chimera" engine works.
*   **[How to Contribute](./CONTRIBUTING.md):** Find out how you can help the project.
*   **[MOD-SVS Specification](./docs/MOD-SVS_SPECIFICATION.md):** For musicians who want to make moth-R sing!

Join us in giving the Amiga a new soul.

## Practical Example

To understand how it all works, check out our simple "Hello World" example:
*   [/examples/hello_moth-r.mod](./examples/hello_moth-r.mod) - The ProTracker module.
*   [/examples/hello_moth-r_lyrics.txt](./examples/hello_moth-r_lyrics.txt) - The corresponding lyrics script.
*   [/examples/conceptual_player.c](./examples/conceptual_player.c) - A C code file showing the logic of how the custom player reads both files to generate the vocal performance.
