require 'spec_helper'
require 'fileutils'
require 'syrup/translate'

RSpec.describe Syrup::Translate do

    let(:file_in) {'tmp/input.syp'}
    let(:file_out) {'tmp/output.syp'}
    let(:text) {'public class testy do\n\n\tpsvm {\n\n\t\tint x = 0;\n\n\t\tif [x == 0] {\n\n\t\t\tString y = /* inline comment */ "pineapple"; /* eol1 */ // eol2\n\n\t\t\tp y;\n\n\t\t} else {\n\n\t\t\t//test comment\n\t\t\tp "nope"; //Not chosen\n\n\t\t}\n\n\t\t// another test comment\n\n\t\tp x;\n\n\t}\n\nend'}
    let(:correct_result) {'public class testy {\n\n\tpublic static void main(String[] args) {\n\n\t\tint x = 0;\n\n\t\tif (x == 0) {\n\n\t\t\tString y = /* inline comment */ "pineapple"; /* eol1 */ // eol2\n\n\t\t\tSystem.out.println(y);\n\n\t\t} else {\n\n\t\t\t//test comment\n\t\t\tSystem.out.println("nope"); //Not chosen\n\n\t\t}\n\n\t\t// another test comment\n\n\t\tSystem.out.println(x);\n\n\t}\n\n}'}

    before :all do
        FileUtils.mkdir('tmp')
        File.open(:file_in, "w+") {|out| out.puts :text}
    end

    after :all do
        FileUtils.rm_r('tmp')
    end

    describe '.scan_and_replace' do
        it 'checks that scan and replace properly identifies and replaces text' do
            replace_map = {}
            test_result = replace_map.inject(:text){ |str, replace| Syrup::Translate.scan_and_replace(str, replace[0], replace[1])}
            expect(test_result).to eq(:correct_result)
        end
    end

    describe '.transpile' do
        it 'checks that transpile properly reads the input and writes to the output' do
            replace_map = {}
            Syrup::Translate.transpile(:file_in, replace_map, :file_out)
            expect(File.read(:file_in)).to eq(File.read(:file_out))
        end
    end
end
