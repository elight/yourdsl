module YourDSL
  VERSION = '0.7.2'

  class Scope < Struct.new(:expressions); end
  class Expression < Struct.new(:symbol, :args, :lineno, :proc, :scope); end
  class Output < Struct.new(:file, :expressions); end

  def record_your_dsl(opts = {})
    @@remember_blocks_starting_with = Array(opts[:retain_blocks_for])
    @@only = Array(opts[:only])
    @@exclude = Array(opts[:except])
    @@output = Output.new
    @@file = nil
    @stack = []
  end

  def output
    if @current_scope
      @@output.expressions = @current_scope.expressions
    end
    @@output
  end

  def file=(file)
    unless @@file
      @@file = file
      @@output.file = @@file
    end
  end

  def method_missing(sym, *args, &block)
    caller[0] =~ (/(.*):(.*):in?/)
    file, lineno = $1, $2
    self.file = file

    assert_inclusion_of sym
    assert_exclusion_of sym

    args = (args.length == 1 ? args.first : args)

    record_as_sexp(sym, args, lineno, &block)
  end

  private

    def record_as_sexp(sym, args, lineno, &block)
      @current_scope ||= Scope.new([])
      @current_scope.expressions << Expression.new(sym, args, lineno)
      if block
        if @@remember_blocks_starting_with.include? sym
          @current_scope.expressions.last.proc = block
        else
          nest(&block)
        end
      end
    end

    def nest(&block)
      @stack.push @current_scope

      new_scope = Scope.new([])
      @current_scope.expressions.last.scope = new_scope
      @current_scope = new_scope

      instance_eval(&block)

      @current_scope = @stack.pop
    end

    def assert_inclusion_of symbol
      if !@@only.empty? && !@@only.include?(symbol)
        fail(NoMethodError, symbol.to_s)
      end
    end

    def assert_exclusion_of symbol
      if !@@exclude.empty? && @@exclude.include?(symbol)
        fail(NoMethodError, symbol.to_s)
      end
    end
end
