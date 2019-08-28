defmodule Chip8.Buffer do
  def new(size) do
    :binary.copy(<<0x0>>, size)
  end

  def put_bytes(buffer, bytes, pos) do
    next_pos = pos + byte_size(bytes)
    part_1 = binary_part(buffer, 0, pos)
    part_2 = binary_part(buffer, next_pos, byte_size(buffer) - next_pos)

    [part_1, bytes, part_2] |> IO.iodata_to_binary
  end

  def xor_bytes(buffer, bytes, pos) do
    size = byte_size(bytes)
    next_pos = pos + size
    part_1 = binary_part(buffer, 0, pos)
    current_bytes = binary_part(buffer, pos, size)
    part_2 = binary_part(buffer, next_pos, byte_size(buffer) - next_pos)
    xored = :crypto.exor(current_bytes, bytes)
    collision = xored != bytes

    buffer = [part_1, :crypto.exor(current_bytes, bytes), part_2] |> IO.iodata_to_binary

    {buffer, collision}
  end
end
