defmodule Chip8.GUI do
  alias Chip8.Opcode

  @compile inline: [
    padding: 3,
    slice_and_pad_trailing: 2,
    unpack_pixels: 2,
    unpack_opcodes: 2,
    format_instruction: 1,
    column: 1,
    map_pixels: 1,
  ]

  def init(state) do
    [
      IO.ANSI.clear,
      boxes(),
    ] |> IO.puts

    state
  end

  defp boxes do
    [
      box(0, 0, 66, 18),
      box(67, 0, 15, 18),
      box(82, 0, 30, 18),
    ]
  end

  def render(state) do
    [
      (if state.screen_changed?, do: screen(state, 1, 1), else: []),
      registers(state, 68, 1),
      disasm(state, 83, 1),
    ] |> IO.puts

    state
  end

  @begin_box "\x1b(0"
  @end_box "\x1b(B"
  @top_left 0x6C
  @top_right 0x6B
  @bottom_left 0x6D
  @bottom_right 0x6A
  @h_line 0x71
  @v_line 0x78

  def box(x, y, w, h) when w >= 2 and h >= 2 do
    w = w - 2; h = h - 2

    [
      cursor(0, y),
      [column(x), @begin_box, @top_left, :binary.copy(<<@h_line>>, w), @top_right, @end_box, "\n"],
      [column(x), @begin_box, @v_line, IO.ANSI.cursor_right(w), @v_line, @end_box, "\n"] |> List.duplicate(h),
      [column(x), @begin_box, @bottom_left, :binary.copy(<<@h_line>>, w), @bottom_right, @end_box, "\n"],
    ]
  end

  defp cursor(x, y), do: IO.ANSI.cursor(y + 1, x + 1)

  defp column(0), do: ""
  defp column(x), do: IO.ANSI.cursor_right(x)

  def screen(state, x, y) do
    pixels = state.screen
    |> unpack_pixels()
    |> Enum.chunk_every(64)
    |> Enum.chunk_every(2)
    |> Enum.map(&Enum.zip/1)
    |> Enum.map(&map_row(&1, x))

    [
      (if y > 0, do: cursor(0, y), else: ""),
      pixels,
    ]
  end

  defp map_row(row, x) do
    [column(x), row |> Enum.map(&map_pixels/1), "\n"]
  end

  defp map_pixels(pixels) do
    case pixels do
      {0, 0} -> " "
      {0, 1} -> "▄"
      {1, 0} -> "▀"
      {1, 1} -> "█"
    end
  end

  def registers(state, x, y) do
    [
      cursor(0, y),
      (0x0..0xF) |> Enum.map(fn i ->
        val = state.registers[{:v, i}] |> hex()
        i = i |> Integer.to_string(16)
        [column(x), "V", i, " ", val, "\n"]
      end),
      cursor(0, y),
      [column(x + 6), "PC ", state.pc |> hex(4), "\n"],
      [column(x + 6), "I  ", state.registers.i |> hex(4), "\n"],
      [column(x + 6), "ST   ", state.registers.st |> hex(2), "\n"],
      [column(x + 6), "DT   ", state.registers.dt |> hex(2), "\n"],
    ]
  end

  defp hex(val, digits \\ 2) do
    str = val |> Integer.to_string(16)
    [padding(str, digits, "0"), str]
  end

  defp padding(binary, bytes, char) when byte_size(binary) < bytes, do: :binary.copy(char, bytes - byte_size(binary))
  defp padding(binary, _bytes, _char), do: binary

  def disasm(state, x, y) do
    instructions = binary_part(state.memory, state.pc - 16, 2 * 16)
    |> unpack_opcodes()
    |> Stream.with_index
    |> Enum.map(fn {opcode, i}->
      instruction = opcode |> Opcode.disassemble |> format_instruction |> slice_and_pad_trailing(27)
      if i == 8 do
        [column(x), IO.ANSI.light_blue_background, instruction, "\n"]
      else
        [column(x), IO.ANSI.default_background, instruction, "\n"]
      end
    end)

    [
      cursor(0, y),
      instructions,
    ]
  end

  defp slice_and_pad_trailing(str, n) when byte_size(str) > n, do: :binary.part(str, 0, n)
  defp slice_and_pad_trailing(str, n) when byte_size(str) < n, do: [str, padding(str, n, " ")]
  defp slice_and_pad_trailing(str, _n), do: str

  for i <- 0x0..0xF do
    name = "V" <> Integer.to_string(i, 16)
    defp format_instruction({:v, unquote(i)}), do: unquote(name)
  end
  defp format_instruction(val) when is_tuple(val), do:  val |> Tuple.to_list |> Enum.map(&format_instruction/1) |> Enum.join(" ")
  defp format_instruction(val) when is_atom(val), do: val |> to_string
  defp format_instruction(val), do: val |> inspect

  defp unpack_pixels(bytes) when is_binary(bytes), do: unpack_pixels(bytes, [])
  defp unpack_pixels("", bits), do: bits |> Enum.reverse
  defp unpack_pixels(<<bit::1, rest::bitstring>>, bits), do: unpack_pixels(rest, [bit | bits])

  defp unpack_opcodes(bytes) when is_binary(bytes), do: unpack_opcodes(bytes, [])
  defp unpack_opcodes("", opcodes), do: opcodes |> Enum.reverse
  defp unpack_opcodes(<<opcode::bitstring-16, rest::bitstring>>, opcodes), do: unpack_opcodes(rest, [opcode | opcodes])
end
