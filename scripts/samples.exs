alias Kojin.Rust.Field, as: F
alias Kojin.Rust.Struct, as: S
alias Kojin.Rust.Type, as: T



IO.puts inspect %F{ name: :foo, type: :int, pub: 3 }, pretty: true

IO.puts inspect %S{ name: :foo, fields: [3] }, pretty: true

IO.puts inspect T.type(:i32), pretty: true
IO.puts inspect T.type(:unit), pretty: true
IO.puts inspect T.type(:str), pretty: true
IO.puts inspect T.type(:String), pretty: true
IO.puts inspect T.type(:BamBam), pretty: true

IO.puts F.decl(%F{ name: :f_1, doc: "This is a field", type: :i32})

IO.puts T.type(:i32).primitive?
