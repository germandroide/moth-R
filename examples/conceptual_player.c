/*
 * moth-R - Conceptual MOD-SVS Player Logic
 * This is not final code, but illustrates the core loop.
*/
#include "mothr_engine.h"
#include "ptplayer.h" // hypothetical protracker replayer library

int main() {
    // 1. Initialization
    load_module("examples/hello_moth-r.mod");
    LyricScript* lyrics = parse_lyrics_script("examples/hello_moth-r_lyrics.txt");
    open_mothr_engine();

    // 2. Main Loop (sync with screen refresh - 50Hz)
    while(user_does_not_quit) {
        wait_for_vertical_blank();
        ptplayer_play_tick(); // Advance the tracker player one tick

        // 3. THE MAGIC: Check the moth-R control channel (channel 3 in 0-indexed array)
        TrackerRowData* row = ptplayer_get_current_row_data();
        TrackerNote* voiceNote = row->channels[3].note;

        if (voiceNote) {
            // A new note has been triggered on the voice channel!
            char* syllable = find_syllable_for_position(lyrics, row->pattern, row->row_number);
            int instrument = row->channels[3].instrument;

            // Select voice based on instrument number
            if (instrument == 1) {
                mothr_set_voice(VOICE_MALE);
            } else if (instrument == 2) {
                mothr_set_voice(VOICE_FEMALE);
            }

            // Tell moth-R to speak the syllable at the specified musical pitch
            mothr_speak_syllable_at_pitch(syllable, voiceNote->pitch_frequency);
        }

        // Process effects (portamento, vibrato, etc.) on the currently playing voice sample...
    }

    // 4. Cleanup
    close_mothr_engine();
    free_module();
    free_lyrics_script(lyrics);
    return 0;
}
