require "fileutils"

BIN = File.join(File.dirname(__FILE__),"../bin/scribble")

# Run the app with the given input, return the output (stdout and stderr) as an array of lines
def run input
    lines = `echo "#{input}" | #{BIN} 0 0 2>&1`
    lines.split("\n")
end

describe "sexp validation" do
    it "should reject an empty list" do
        run("()")[0].should =~ /Command was an empty list$/
    end

    it "should reject a command with a non-symbol car" do
        run("((1 2) 3)")[0].should =~ /wasn't a symbol: \(1 2\)$/
    end

    it "should echo a sexp with the echo command" do
        run("(echo foo bar)")[0].should =~ /\(echo foo bar\)/
    end
end

describe "shape command" do
    it "should create a rect when told to" do
        run("(shape foo (rect 0 0 100 50))").should be_empty
    end

    it "should reject a rect with too few / many args" do
        run("(shape foo (rect 0 1 2))")[0].should =~ /ERROR: Expected/
        run("(shape foo (rect 0 1 2 3 4))")[0].should =~ /ERROR: Expected/
    end

    it "should reject a rect with lists for args" do
        run("(shape foo (rect (0) 1 2 3))")[0].should =~ /ERROR:/
    end

    it "should accept floats as params" do
        run("(shape foo (rect 0.0 0.0 100 50))").should be_empty
    end

    it "should deal with strings, and evaluate them as numbers" do
        run("(shape foo (rect a b c d))").should be_empty
    end

    it "should refuse to create a shape with a bad name" do
        run("(shape (foo) (rect a b c d))")[0].should =~ /ERROR/
    end

    it "should refuse to create a shape with no shape" do
        run("(shape foo)")[0].should =~ /ERROR/
    end
end

describe "stroke command" do
    it "should refuse to stroke with too few / many arguments" do
        run("(stroke (rect 0 0 0 0) 1 2 3 4 5)")[0].should =~ /ERROR/
        run("(stroke (rect 0 0 0 0) 1 2)")[0].should =~ /ERROR/
    end

    it "should refuse to stroke an illegal shape" do
        run("(stroke (not-a-rect) 1 2 3)")[0].should =~ /ERROR/
        run("(stroke (rect 1 2) 1 2 3)")[0].should =~ /ERROR/
    end

    it "should refuse to stroke a shape that doesn't exist" do
        run("(stroke not-a-rect 1 2 3)")[0].should =~ /ERROR/
    end

    it "should stroke a shape literal" do
        run("(stroke (rect 0 0 100 50) 1 2 3)").should be_empty
    end

    it "should stroke a shape by name" do
        run("(shape foo (rect 0 0 100 50)) (stroke foo 1 0 0)").should be_empty
    end

    it "should stroke a shape with an alpha" do
        run("(stroke (rect 100 100 50 50) 1 0 0 0.5)").should be_empty
    end
end
