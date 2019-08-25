defmodule Chip8.ROM do
  alias Chip8.Opcode

  def load(filename) do
    File.stream!(filename, [], _bytes = 2)
  end

  def disassemble(opcode_stream) do
    opcode_stream |> Enum.map(&Opcode.disassemble/1)
  end
end
