module Syrup
    COM_PYTHON = [/#.*?(?=\n)/]
    COM_JAVA = [/\/\*(\*(?!\/)|[^*])*\*\//, /\/\/.*?(?=\n)/]
    COM_RUBY = [/#.*?(?=\n)/]
end
