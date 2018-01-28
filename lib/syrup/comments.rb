module Syrup
    COM_PYTHON = [/#/, /"""(?<comment>)"""/]
    COM_JAVA = [/\/\//, /\/*(?<comment>)*\//]
    COM_RUBY = [/#/, /\=begin\n(?<comment>)\n=end/]
end
