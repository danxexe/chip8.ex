defmodule Chip8.Screen do
  alias Chip8.Buffer

  def draw(screen, sprite, x, y) do
    bits_before = x
    bits_after = 64 - 8 - x
    y_pos = y * 8

    data = sprite
    |> Enum.map(fn byte -> build_line(bits_before, byte, bits_after) end)
    |> :binary.list_to_bin

    {_screen, _collision} = screen |> Buffer.xor_bytes(data, y_pos)
  end

  defp build_line(bits_before, byte, bits_after) when bits_after < 0 do
    max_width = 8 + bits_after
    <<byte::size(max_width), _::bitstring>> = <<byte>>
    <<0::size(bits_before), byte::size(max_width)>>
  end

  defp build_line(bits_before, byte, bits_after) do
    <<0::size(bits_before), byte::8, 0::size(bits_after)>>
  end
end
