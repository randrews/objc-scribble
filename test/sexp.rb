require "fileutils"

BIN = File.join(File.dirname(__FILE__),"../bin/scribble")

describe "sexp validation" do
    # Run the app with the given input, return the output (stdout and stderr) as an array of lines
    def run input
        lines = `echo "#{input}" | #{BIN} 0 0 2>&1`
        lines.split("\n")
    end

    it "should reject an empty list" do
        run("()")[0].should =~ /Command was an empty list$/
    end

    it "should reject a command with a non-symbol car" do
        run("((1 2) 3)")[0].should =~ /wasn't a symbol: \(1 2\)$/
        run('(\"foo\" 3)')[0].should =~ /wasn't a symbol: "foo"$/ # backslashes for the shell
    end

    it "should echo a sexp with the echo command" do
        run("(echo foo bar)")[0].should =~ /\(echo foo bar\)/
    end

    it "should create a rect when told to" do
        run("(rect 0 0 100 50)")[0].should =~ /Successfully created rect/
    end

    it "should reject a rect with too few / many args" do
        run("(rect 0 1 2)")[0].should =~ /ERROR: Expected/
        run("(rect 0 1 2 3 4)")[0].should =~ /ERROR: Expected/
    end

    it "should reject a rect with lists for args" do
        run("(rect (0) 1 2 3)")[0].should =~ /ERROR:/
    end

    it "should accept floats as params" do
        run("(rect 0.0 0.0 100 50)")[0].should =~ /Successfully created rect/
    end

    it "should deal with strings, and evaluate them as numbers" do
        run("(rect a b c d)")[0].should =~ /Successfully created rect/
    end
end
