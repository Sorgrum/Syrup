module Syrup
    class Translate
        def self.scan_and_replace(str, regexp, replacement)
            names = regexp.names.collect{ |name| name.to_sym}
            str.scan(regexp).each do |match|
                match_map = Hash[names.zip(match)]
                complete = match_map.delete(:___SYPCOMPLETE___)
                str = str.gsub(complete, replacement % match_map)
            end
            str
        end

        def self.transpile(file_in, replace_map, file_out)
            text = File.read(file_in)
            text = replace_map.inject(text){ |str, replace| scan_and_replace(str, replace[0], replace[1])}

            File.open(file_out, "w+") {|out| out.puts text}
        end
    end
end
