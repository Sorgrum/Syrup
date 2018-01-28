require 'syrup/comments'

module Syrup
    class Translate

        # Strip syrup code of comments
        def self.remove_comments(text, lang)
            comments_regexp = case lang     # get proper comment format
                when 'python' then COM_PYTHON
                when 'java' then COM_JAVA
                when 'ruby' then COM_RUBY
                else raise "Invalid language: #{lang} specified!"
            end

            comments_regexp.inject(text) do |str, replace|
                str = str.gsub(replace, "") # remove all types of comments
                str
            end
        end

        # Scan through syrup code and perform all replacements for a given regexp
        def self.scan_and_replace(str, regexp, replacement)
            names = regexp.names.collect{ |name| name.to_sym} # get names from capture groups to match
            str.scan(regexp).each do |match|
                match_map = Hash[names.zip(match)]
                complete = match_map.delete(:___SYPCOMPLETE___) # grab the complete match
                str = str.gsub(complete, replacement % match_map) # perform replacement keeping named captures (other than ___SYPCOMPLETE___)
            end
            str
        end

        # Read in syrup code, perform transpilation, and output target language code
        def self.transpile(file_in, replace_map, file_out, lang)
            text = File.read(file_in)
            # remove comments then perform all replacements
            text = replace_map.inject(remove_comments(text, lang)){ |str, replace| scan_and_replace(str, replace[0], replace[1])}

            File.open(file_out, "w+") {|out| out.puts text}
        end
    end
end
