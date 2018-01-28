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
                    fs = Regexp.escape(source[0]) # First symbol
                    fv = variableName(source[1]) # First variable
                    ss = Regexp.escape(source[2]) # Second symbol

                    regx += fs
                    regx += "(?<#{fv}>"
                    regx += "[^#{ss}]*)"
                    regx += ss

                    # If there are more than three sections, add them iteratively here
                    i = 2
                    while (i < source.size - 1) do
                        nv = variableName(source[i + 1]) # Next variable
                        ns = Regexp.escape(source[i + 2]) # Next symbol

                        regx += "(?<#{nv}>"
                        regx += "[^#{ns}]*)"
                        regx += ns
                        i += 3
                    end

                    regx += ")"
                    regx = Regexp.new(regx, Regexp::MULTILINE)
                    p regx
                end
                break
                pp "=========="

            elsif (!multiline) then
                
            end
                

            # replace_map = {
                # /(?<complete>if\ \[(?<condition>[^\]]+)\])/m => "if (%{condition})",
            # }

            # # Merge local and home configs
            # # local config has higher priority than home config
            # if (!home_config.nil? && !local_config.nil?) then

            #     # This combines local and home config, and removes duplicates
            #     rules = local_config["rules"] + home_config["rules"]

            #     # Take all info from the local config, but with the combined rules
            #     config = local_config
            #     config["rules"] = rules.uniq

            #     pp config
            #     return config
            # end

            # # This is the case where only one or the other exists
            # # so no merging is needed
            # if (!home_config.nil? && local_config.nil?) then
            #     return home_config
            # else
            #     return local_config
            # end
        end

        def self.isVariable(str)
            return str.match?(/\$\$\$[^\$\$\$]+\$\$\$/)
        end

        def self.variableName(str)
            return str.match(/\$\$\$([^\$\$\$]+)\$\$\$/)[1]
        end

        def self.read(filetype)
            # Unprocessed config
            config = find(filetype)


        end

        def self.verify

        end
    end
end

