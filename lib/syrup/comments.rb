module Syrup
    COM_PYTHON = {:eol => "/(?<%{com_num}>(#[^$]*)?)$/"}
    COM_JAVA = {:inline => "/(?<%{com_num}>(\/\*.*?\*\/\s*)*)/", :eol => "/(?<%{com_num}>(\/\*.*?\*\/\s*)*(\/\/[^$]*)?)$/"}
    COM_RUBY = {:eol => "/(?<%{com_num}>(#[^$]*)?)$/"}
end
