require 'spec_helper'
require 'fileutils'
require 'syrup/config'

RSpec.describe Syrup::Config do

    let(:config_file) {'.config.java.syp'}
    let(:text) {"{\"directories\":{\"java\":[\"java/\",\"java/libs/\",\"java/utils/\"]},\"rules\":[{\"multiline\":true,\"rule\":[\"public class $$$class_name$$$ do\",\"$$$class_body$$$\",\"end\",\"-->>\",\"public class $$$class_name$$$ {\",\"$$$class_body$$$\",\"}\"]},{\"multiline\":true,\"rule\":[\"if [$$$CONDITION$$$] then $$$EXPR$$$ end\",\"-->>\",\"maybe ($$$CONDITION$$$) { $$$EXPR$$$ }\"]},{\"rule\":[\"psvm\",\"-->>\",\"public static void main(String[] args)\"]},{\"multiline\":true,\"rule\":[\"p $$$ARGS$$$;\",\"-->>\",\"System.out.println($$$ARGS$$$);\"]},{\"rule\":[\"if [$$$condition$$$]\",\"-->>\",\"if($$$condition$$$)\"]}]}"}

    describe '.find' do
        it 'verifies that the correct regexps are generated from the user specs' do
            File.open(config_file, "w+") {|out| out.puts text}
            replace_map = {/(?<___SYPCOMPLETE___>public\ class\ (?<class_name>.*?)\ do\n(?<class_body>.*?)\nend)/m => "public class %{class_name} {\n" + "%{class_body}\n" + "}", /(?<___SYPCOMPLETE___>if\ \[(?<CONDITION>.*?)\]\ then\ (?<EXPR>.*?)\ end)/m => "maybe (%{CONDITION}) { %{EXPR} }", /(?<___SYPCOMPLETE___>psvm)/ => "public static void main(String[] args)", /(?<___SYPCOMPLETE___>p\ (?<ARGS>.*?);)/m => "System.out.println(%{ARGS});", /(?<___SYPCOMPLETE___>if\ \[(?<condition>.*?)\])/ => "if(%{condition})"}
            test_result = Syrup::Config.find('java')
            expect(test_result).to eq(replace_map)
            File.delete(config_file)
        end
    end
end
