require "stringio"

module IoTestHelpers
  module StringIOExtensions
    def wait_readable(*)
      true
    end

    def ioctl(*)
      80
    end
  end

  def simulate_stdin(*inputs, &block)
    io = StringIO.new
    inputs.flatten.each { |str| io.puts(str) }
    io.rewind

    actual_stdin, $stdin = $stdin, io
    yield
  ensure
    $stdin = actual_stdin
  end

  def keypress(key)
    case key
    when :enter
      "\n"
    when :up
      "\e[A"
    when :down
      "\e[B"
    when :left
      "\e[D"
    when :right
      "\e[C"
    else
      key.to_s
    end
  end
end

StringIO.include(IoTestHelpers::StringIOExtensions)
