require 'syrup/constants'
require 'json'

module Syrup
    class Config

        def self.find(filetype)

            # Acceptable paths for configuration files
            home_filepath = File.expand_path("~/.config.#{filetype}.#{Syrup::FILE_EXTENSION}")
            local_filepath = File.expand_path("./.config.#{filetype}.#{Syrup::FILE_EXTENSION}")

            # Either a configuration object or nil
            home_config = File.exists?(home_filepath) ? JSON.parse(File.read(home_filepath)) : nil
            local_config = File.exists?(local_filepath) ? JSON.parse(File.read(local_filepath)) : nil

            raise "Config file not found for filetype '#{filetype}'" if (home_config.nil? && local_config.nil?)

            replace_map = Hash.new
            

            home_config["rules"].each do |ruleObj| 
                processRules(replace_map, ruleObj)
            end

            local_config["rules"].each do |ruleObj|
                processRules(replace_map, ruleObj)
            end

            return replace_map
            # replace_map = {
                # /(?<complete>if\ \[(?<condition>[^\]]+)\])/m => "if (%{condition})",
            # }
        end

        def self.isVariable(str)
            return str.match?(/\$\$\$[^\$\$\$]+\$\$\$/)
        end

        def self.variableName(str)
            return str.match(/\$\$\$([^\$\$\$]+)\$\$\$/)[1]
        end

        def self.processRules(replace_map, ruleObj)

            split_rules = [[], []] # is size 2
            ruleObj["rule"].inject(0) do |acc, e|
                if '-->>' == e
                    acc += 1
                else
                    split_rules[acc].append(e)
                    acc
                end
            end

            # Combine multiple lines into one
            source = split_rules[0].inject { |acc, var| acc + "\n" + var }
            target = split_rules[1].inject { |acc, var| acc + "\n" + var }

            source = source.split(/(\$\$\$[^\$\$\$]*\$\$\$)/).reject { |source| source.empty? }
            target = target.split(/(\$\$\$[^\$\$\$]*\$\$\$)/).reject { |source| source.empty? }

            # Boolean, true if it is multiline, false otherwise
            multiline = ruleObj["multiline"] == true ? true : false

            validateRule(source)

            if (multiline) then

                # Sanity checks
                # First and last sections /MUST/ be symbols
                raise "Multiline rules can not start or end with a variable" if (isVariable(source[0]) || isVariable(source[-1]))

                # Ensure that every other section is a variable
                source.each_with_index do |e, i|
                    if (i % 2 == 0) then
                        if (isVariable(source[i])) then
                            raise "Delimiter splitting failed"
                        end
                    else
                        if (!isVariable(source[i])) then
                            raise "Delimiter splitting failed"
                        end
                    end
                end

                regx = "(?<___SYPCOMPLETE___>"

                # Add regex boilerplate for the first three sections
                fs = Regexp.escape(source[0])   # First symbol
                fv = variableName(source[1])    # First variable
                ss = Regexp.escape(source[2])   # Second symbol

                regx += fs
                regx += "(?<#{fv}>"
                regx += "[^#{ss}]*)"
                regx += ss

                # If there are more than three sections, add them iteratively here
                i = 2
                while (i < source.size - 1) do
                    nv = variableName(source[i + 1])    # Next variable
                    ns = Regexp.escape(source[i + 2])   # Next symbol

                    regx += "(?<#{nv}>"
                    regx += "[^#{ns}]*)"
                    regx += ns
                    i += 3
                end

                regx += ")"
                regx = Regexp.new(regx, Regexp::MULTILINE)

                rhs = ""
                target.each do |section| 
                    if (isVariable(section)) then
                        rhs += "%{#{variableName(section)}}"
                    else
                        rhs += section
                    end
                end

                replace_map[regx] = rhs
            elsif (!multiline)
                regx = "(?<___SYPCOMPLETE___>"
                source.each_with_index do |section, index|
                    if (isVariable(section)) then
                        if (index == source.size - 1) then
                            regx += "(?<#{variableName(section)}>"
                            regx += ".*"
                        else
                            regx += "(?<#{variableName(section)}>"
                        end
                    else
                        if (index == 0) then
                            regx += Regexp.escape(section)
                        else
                            regx += "[^#{Regexp.escape(section)}]*)"
                            regx += Regexp.escape(section)
                        end
                    end
                end
                regx += ")"

                regx = Regexp.new(regx)

                rhs = ""
                target.each do |section| 
                    if (isVariable(section)) then
                        rhs += "%{#{variableName(section)}}"
                    else
                        rhs += section
                    end
                end

                replace_map[regx] = rhs
            end
        end
        
        def self.read(filetype)
        # Unprocessed config
        config = find(filetype)
        end

        def self.validateRule(rule)
            # Check if rule is length one and only a variable

            return true
        end

        def self.verify

        end
    end
end

