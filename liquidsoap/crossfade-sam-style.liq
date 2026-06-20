# SAM Broadcaster-style crossfade for mETaLcast / AzuraCast
#
# Usage: paste each section into the matching custom textbox at
#   Station → Broadcasting → Edit Liquidsoap Configuration
#
# Tested with AzuraCast Rolling Release (Liquidsoap 2.x, AutoCue enabled).
# ─────────────────────────────────────────────────────────────────────────────

# ── SECTION 1 (top custom box, before the generated header) ──────────────────
#
# Nothing needed here unless you want to add global settings.
# NOTE: settings.root.max_latency does NOT exist in Liquidsoap 2.4.x —
# it was removed. Leave this box empty.


# ── SECTION 3 (pre-fade custom box, before the generated processing chain) ───
#
# The generated header forces:
#   settings.azuracast.enable_crossfade := false
#   settings.azuracast.default_cross    := 0.00
#
# This section runs after that header but before azuracast.apply_crossfade()
# is called, so these assignments win.

# Enable crossfade and select the smart algorithm.
# "smart" uses cross.smart(), which measures audio energy at the transition:
#   - loud beginning on the incoming track → intro detected → clean cut
#   - normal ending/beginning             → 3-second overlapping crossfade
settings.azuracast.enable_crossfade := true
settings.azuracast.crossfade_type   := "smart"

# Overlap window (seconds).  How much of each song is buffered and blended.
settings.azuracast.default_cross := 3.0

# Individual fade-in / fade-out duration inside the overlap window.
settings.azuracast.default_fade := 3.0

# Redefine apply_crossfade to add the minimum-duration guard.
# minimum=121.0 → songs at or under 120 seconds (2 minutes) skip the
# transition entirely and play to completion before the next begins.
# Songs over 2 minutes get the full smart crossfade above.
def azuracast.apply_crossfade(s) =
    def transition(old, new) =
        let dur = float_of_string(default=999.0, old.metadata["duration"]) in
        if dur <= 120.0 then
            # Short song: play to completion then start next with no overlap.
            sequence([old.source, new.source])
        else
            azuracast.live_aware_crossfade_impl(old, new)
        end
    end
    cross(
        duration=settings.azuracast.default_cross(),
        transition,
        s
    )
end
