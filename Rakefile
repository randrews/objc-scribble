require "rake/clean"

CLEAN.include "**/*.o"
CLEAN.include "**/*~"
CLOBBER.include "bin/scribble"

SRC = Dir["src/**/*.m"]
HEADERS = Dir["src/**/*.h"]

FRAMEWORKS = %w{Foundation AppKit}

task :default=>:build

desc "Build the project"
task :build => ["bin/scribble"]

file "bin/scribble" => [:bindir] + SRC.map{|m| m.ext("o") } + HEADERS do
    frameworks = FRAMEWORKS.map{|f| "-framework #{f}" }.join(" ")
    sh "gcc -o bin/scribble #{SRC.map{|m| m.ext('o') }} #{frameworks}"
end

task :bindir do
    FileUtils.mkdir_p "bin"
end

SRC.each{|filename| file filename.ext("o") => HEADERS } unless HEADERS.empty?

rule '.o' => '.m' do |t|
    sh "gcc -c -o #{t.name} #{t.source}"
end
