/// Persistent state of one file's metadata association.
///
/// A match is explicit rather than inferred from an overloaded ID field. This
/// lets rescan safely skip confirmed files while retaining useful diagnostics
/// for entries that still need attention.
enum StoredMetadataMatchStatus { pending, confirmed, unmatched, ambiguous }
