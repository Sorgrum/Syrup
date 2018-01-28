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

            # Merge local and home configs
            # local config has higher priority than home config
            if (!home_config.nil? && !local_config.nil?) then

                # This combines local and home config, and removes duplicates
                rules = local_config["rules"] + home_config["rules"]

                # Take all info from the local config, but with the combined rules
                config = local_config
                config["rules"] = rules.uniq

                pp config
                return config
            end

            # This is the case where only one or the other exists
            # so no merging is needed
            if (!home_config.nil? && local_config.nil?) then
                return home_config
            else
                return local_config
            end
        end

        def self.read(filetype)
            # Unprocessed config
            config = find(filetype)


        end

        def self.verify

        end
    end
end

