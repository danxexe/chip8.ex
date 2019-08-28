defmodule Chip8.Instruction do
  require Logger
  require Bitwise

  import Chip8.State

  alias Chip8.Screen
  alias Chip8.Font

  defguard is_reg(reg) when reg in [:i, :st, :dt] or (elem(reg, 0) == :v and elem(reg, 1) >= 0x0 and elem(reg, 1) <= 0xF)

  def execute(:cls, state) do
    put_in(state.screen, blank_screen())
  end

  def execute({:ld, {:i}, {:v, n}}, state) when is_integer(n) do
    bytes = (0..n) |> Enum.map(fn i -> state |> reg_get({:v, i}) end)

    state |> memory_put(bytes, state |> reg_get(:i))
  end

  def execute({:ld, {:v, n}, {:i}}, state) when is_integer(n) do
    memory_get(state, state |> reg_get(:i), n + 1)
    |> Enum.with_index
    |> Enum.map(fn {val, i} -> {{:v, i}, val} end)
    |> Enum.reduce(state, fn {reg, val}, state -> state |> reg_put(reg, val) end)
  end

  def execute({:ld, :b, reg}, state) when is_reg(reg) do
    addr = state |> reg_get(:i)
    val = state |> reg_get(reg)
    bytes = val |> Integer.digits |> :binary.list_to_bin

    state |> memory_put(bytes, addr)
  end

  def execute({:ld, :f, reg}, state) when is_reg(reg) do
    offset = Font.offset(state |> reg_get(reg))
    state |> reg_put(:i, offset)
  end

  def execute({:ld, reg_a, reg_b}, state) when is_reg(reg_a) and is_reg(reg_b) do
    execute({:ld, reg_a, state |> reg_get(reg_b)}, state)
  end

  def execute({:ld, reg, val}, state) when is_reg(reg) and is_integer(val) do
    state |> reg_put(reg, val)
  end

  def execute({:rnd, reg, val}, state) when is_reg(reg) and is_integer(val) do
    rand = (0x00..0xFF) |> Enum.random |> Bitwise.band(val)

    state |> reg_put(reg, rand)
  end

  def execute({:add, reg_a, reg_b}, state) when is_reg(reg_a) and is_reg(reg_b) do
    execute({:add, reg_a, state |> reg_get(reg_b)}, state)
  end

  def execute({:add, reg, val}, state) when is_reg(reg) and is_integer(val) do
    state |> reg_update(reg, &(&1 + val))
  end

  def execute({:and, reg_a, reg_b}, state) when is_reg(reg_a) and is_reg(reg_b) do
    reg_put(state, reg_a, Bitwise.band(reg_get(state, reg_a), reg_get(state, reg_b)))
  end

  def execute({:se, reg, val}, state) when is_reg(reg) and is_integer(val) do
    if reg_get(state, reg) == val do
      state |> pc_update(&(&1 + 2))
    else
      state
    end
  end

  def execute({:sne, reg_a, reg_b}, state) when is_reg(reg_a) and is_reg(reg_b) do
    execute({:sne, reg_a, reg_get(state, reg_b)}, state)
  end

  def execute({:sne, reg, val}, state) when is_reg(reg) and is_integer(val) do
    if reg_get(state, reg) != val do
      state |> pc_update(&(&1 + 2))
    else
      state
    end
  end

  def execute({:jp, addr}, state) do
    state |> pc_set(addr - 2)
  end

  def execute({:call, addr}, state) do
    state
    |> stack_push(state.pc + 2)
    |> pc_set(addr - 2)
  end

  def execute(:ret, state) do
    {addr, state} = state |> stack_pop()
    state |> pc_set(addr - 2)
  end

  def execute({:drw, reg_x, reg_y, n}, state) do
    sprite = memory_get(state, state |> reg_get(:i), n)
    x = state |> reg_get(reg_x)
    y = state |> reg_get(reg_y)

    {screen, collision} = Screen.draw(state.screen, sprite, x, y)

    state = if collision do
      state |> reg_put({:v, 0xF}, 1)
    else
      state
    end

    %{state | screen: screen}
  end

  def execute(instruction, state) do
    Logger.error("Unimplemented instructions: #{inspect instruction}")
    state
  end
end
