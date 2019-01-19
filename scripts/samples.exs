alias Kojin.Rust.Field
import Kojin.Rust.Field
alias Kojin.Rust.Struct, as: S
alias Kojin.Rust.Type, as: T

import S


IO.puts inspect %Field{ name: :foo, type: :int, pub: 3 }, pretty: true

IO.puts inspect %S{ name: :foo, fields: [3] }, pretty: true

IO.puts inspect T.type(:i32), pretty: true
IO.puts inspect T.type(:unit), pretty: true
IO.puts inspect T.type(:str), pretty: true
IO.puts inspect T.type(:String), pretty: true
IO.puts inspect T.type(:BamBam), pretty: true

IO.puts %Field{ name: :f_1, doc: "This is a field
with multiline comment


", type: :i32}

IO.puts field(:some_field, :i64, "comment for some field", access: :ro)

IO.puts struct(:some_struct, "comment for some struct",
      [
        [ :foo, :i32, "foo field", [ access: :wo, pub: false ] ],
        [ :bar, :i64, "bar field" ],
        field(:some_field, :i64, "comment for some field", access: :ia),
#        field(:some_field, "Foo::Bar", "comment for some field", access: :ia),        
      ]
    )

IO.puts T.type(:i32).primitive?
