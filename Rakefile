require "rake/clean"

CLEAN.include "**/*.o"
CLEAN.include "**/*~"
CLOBBER.include "bin/scribble"

CLOBBER.include "res/lib" # 3rd-party libs
CLEAN.include "res/sexpr_1.2" # 3rd-party libs
CLOBBER.include "res/include" # 3rd-party headers

SRC = Dir["src/**/*.m"]
HEADERS = Dir["src/**/*.h"]

FRAMEWORKS = %w{Foundation AppKit}

ENV["CC"] ||= "gcc"

task :"3rd-party" => :sexpr

task :default=>:build

desc "Build the project"
task :build => ["bin/scribble"]

file "bin/scribble" => [:bindir] + SRC.map{|m| m.ext("o") } + HEADERS do
    frameworks = FRAMEWORKS.map{|f| "-framework #{f}" }.join(" ")
    sh "#{ENV['CC']} -o bin/scribble #{SRC.map{|m| m.ext('o') }.join(' ')} #{frameworks} -fobjc-gc-only -Lres/lib -lsexp"
end

task :bindir do
    FileUtils.mkdir_p "bin"
end

SRC.each{|filename| file filename.ext("o") => HEADERS } unless HEADERS.empty?
SRC.each{|filename| file filename.ext("o") => filename }

rule '.o' => '.m' do |t|
    sh "#{ENV['CC']} -c -o #{t.name} #{t.source} -fobjc-gc-only -Ires/include"
end

file :sexpr => "res/lib/libsexp.a" do
    FileUtils.cd "res" do
        sh "tar -xzvf sexpr_1.2.tar.gz"
        FileUtils.cd "sexpr_1.2" do
            sh "./configure"
            sh "make"
        end

        FileUtils.mkdir "lib" unless File.exists?("lib")
        FileUtils.cp "sexpr_1.2/src/libsexp.a", "lib"

        FileUtils.mkdir "include" unless File.exists?("include")
        Dir["sexpr_1.2/src/*.h"].map{|f| FileUtils.cp f, "include" }
    end
end
