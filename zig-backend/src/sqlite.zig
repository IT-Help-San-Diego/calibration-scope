const c = @cImport({
    @include("sqlite3.h");
});
pub const sqlite3 = c;
