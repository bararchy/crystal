require 'spec_helper'

describe 'Type inference: errors' do
  it "reports undefined local variable or method" do
    assert_error %(
      def foo
        a = something
      end

      def bar
        foo
      end

      bar),
      "undefined local variable or method 'something'"
  end

  it "reports undefined method" do
    assert_error "foo()",
      "undefined method 'foo'"
  end

  it "reports wrong number of arguments" do
    assert_error "def foo(x); x; end; foo",
      "wrong number of arguments for 'foo' (0 for 1)"
  end

  it "reports undefined method when method inside a class" do
    assert_error "class Int; def foo; 1; end; end; foo",
      "undefined local variable or method 'foo'"
  end

  it "reports undefined instance method" do
    assert_error "1.foo",
      "undefined method 'foo' for Int"
  end

  it "reports can't call primitive with args" do
    assert_error "1 + 'a'",
      "no overload matches"
  end

  it "reports can't call external with args" do
    assert_error "lib Foo; fun foo(x : Char); end; Foo.foo 1",
      "argument #1 to Foo.foo must be Char, not Int"
  end

  it "reports uninitialized constant" do
    assert_error "Foo.new",
      "uninitialized constant Foo"
  end

  it "reports unknown class when extending" do
    assert_error "class Foo < Bar; end",
      "uninitialized constant Bar"
  end

  it "reports superclass mismatch" do
    assert_error "class Foo; end; class Bar; end; class Foo < Bar; end",
      "superclass mismatch for class Foo (Bar for Object)"
  end

  it "reports can't use instance variables inside module" do
    assert_error "def foo; @a = 1; end; foo",
      "can't use instance variables at the top level"
  end

  it "reports can't use instance variables inside a Value" do
    assert_error "class Int; def foo; @a = 1; end; end; 2.foo",
      "can't use instance variables inside Int"
  end

  it "reports error when changing var type and something breaks" do
    assert_error "class Foo; def initialize; @value = 1; end; #{rw :value}; end; f = Foo.new; f.value + 1; f.value = 'a'",
      "undefined method '+' for Char"
  end

  it "reports must be called with out" do
    assert_error "lib Foo; fun x(c : out Int); end; a = 1; Foo.x(a)",
      "argument #1 to Foo.x must be passed as 'out'"
  end

  it "reports error when changing instance var type and something breaks" do
    assert_error %Q(
      lib Lib
        fun bar(c : Char)
      end

      class Foo
        #{rw :value}
      end

      def foo(x)
        x.value = 'a'
        Lib.bar x.value
      end

      f = Foo.new
      foo(f)

      f.value = 1
      ),
      "argument #1 to Lib.bar must be Char"
  end

  it "reports can only get pointer of variable" do
    assert_syntax_error "a.ptr",
      "can only get 'ptr' of variable or instance variable"
  end

  it "reports wrong number of arguments for ptr" do
    assert_syntax_error "a = 1; a.ptr 1",
      "wrong number of arguments for 'ptr' (1 for 0)"
  end

  it "reports ptr can't receive a block" do
    assert_syntax_error "a = 1; a.ptr {}",
      "'ptr' can't receive a block"
  end

  it "reports break cannot be used outside a while" do
    assert_error 'break',
      "Invalid break"
  end

  it "reports read before assignment" do
    assert_syntax_error "a += 1",
      "'+=' before definition of 'a'"
  end

  it "reports no overload matches" do
    assert_error %(
      def foo(x : Int)
      end

      foo 1 || 1.5
      ),
      "no overload matches"
  end

  it "reports no overload matches 2" do
    assert_error %(
      def foo(x : Int, y : Int)
      end

      def foo(x : Int, y : Double)
      end

      foo(1 || 'a', 1 || 1.5)
      ),
      "no overload matches"
  end

  it "reports no matches for hierarchy type" do
    assert_error %(
      class Foo
      end

      class Bar < Foo
        def foo
        end
      end

      x = Foo.new || Bar.new
      x.foo
      ),
      "undefined method 'foo'"
  end

  it "can't do Pointer.malloc without type var" do
    assert_error %(
      Pointer.malloc(1)
    ), "can't malloc pointer without type, use Pointer(Type).malloc(size)"
  end
end
