# Superseded — oMLX with no prefix cache at all

This arm ran with `--no-cache --hot-cache-max-size 8GB`. The 8GB never applied:
oMLX honours `--hot-cache-max-size` only when a cache directory is set and
forces it to 0 otherwise (omlx/cli.py), so `--no-cache` leaves no prefix reuse
in memory or on disk. It was published as "oMLX (bounded in-memory mode)",
which is not what it measured.

Replaced by two arms that say what they are: `omlx` keeps oMLX's own default,
a disk-backed prefix cache with the memory tier off, and `omlx_ram` holds the
cache in memory and writes nothing to disk — the configuration comparable with
every other engine in the roster.

Output throughput at c=1/2/4 was 28.98 / 29.57 / 30.32 tok/s here, against
33.67 / 33.11 / 33.90 for the RAM arm and 30.55 / 27.44 / 30.13 for the disk
arm, so having no cache cost oMLX roughly 10% against having one in memory.

Kept for provenance. Do not plot.
