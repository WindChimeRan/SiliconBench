# Superseded — measured with one server across all concurrency levels

These arms ran every concurrency level against a single server, so levels
after the first inherited a warm prefix cache. On the agent split that is
worth up to 1.67x throughput and 4.1x TTFT, and for oMLX the on-disk cache
persisted too. Levels were therefore not independent measurements.

Replaced by arms measured with a server restart per level and, for oMLX, a
fresh cache directory per start. Do not plot. Kept for provenance.
