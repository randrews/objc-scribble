require "fileutils"

BIN = File.join(File.dirname(__FILE__),"../bin/scribble")

describe "sexp validation" do
    # Run the app with the given input, return the output (stdout and stderr) as an array of lines
    def run input
        lines = `echo "#{input}" | #{BIN} 0 0 2>&1`
        lines.split("\n")
    end

    it "should read the command from a valid sexp" do
        run("(a b c)")[0].should =~ /Command: a$/
    end

    it "should reject an empty list" do
        run("()")[0].should =~ /Command was an empty list$/
    end

    it "should reject a command with a non-symbol car" do
        run("((1 2) 3)")[0].should =~ /wasn't a symbol: \(1 2\)$/
        run('(\"foo\" 3)')[0].should =~ /wasn't a symbol: "foo"$/ # backslashes for the shell
    end
end
