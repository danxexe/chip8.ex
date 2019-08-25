defmodule Chip8Test do
  use ExUnit.Case
  doctest Chip8

  alias Chip8.ROM

  test "disassemble a ROM file" do
    instructions = ROM.load("games/MAZE") |> ROM.disassemble

    assert [
      {:ld, :i, 542},
      {:rnd, {:v, 2}, 1},
      {:se, {:v, 2}, 1},
      {:ld, :i, 538},
      {:drw, {:v, 0}, {:v, 1}, 4},
      {:add, {:v, 0}, 4},
      {:se, {:v, 0}, 64},
      {:jp, 512},
      {:ld, {:v, 0}, 0},
      {:add, {:v, 1}, 4},
      {:se, {:v, 1}, 32},
      {:jp, 512},
      {:jp, 536},
      {:ld, {:v, 0}, {:v, 4}},
      {:call, 16},
      {:call, 64},
      {:ld, {:v, 0}, {:v, 1}}
    ] == instructions
  end
end
