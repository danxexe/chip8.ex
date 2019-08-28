defmodule Chip8.State do
  alias Chip8.Buffer
  alias Chip8.Font

  defstruct [
    memory: nil,
    registers: nil,
    stack: nil,
    screen: nil,
    pc: 0x200,
    cycles: 0,
  ]

  def new do
    %__MODULE__{
      memory: Buffer.new(4096),
      registers: init_registers(),
      stack: [],
      screen: blank_screen(),
    }
    |> memory_put(Font.bytes, 0)
  end

  def blank_screen do
    Buffer.new(256)
  end

  def pc_set(state, addr) do
    put_in(state.pc, addr)
  end

  def pc_update(state, fun) do
    update_in(state.pc, fun)
  end

  def stack_push(state, addr) do
    update_in(state.stack, fn stack -> [addr | stack] end)
  end

  def stack_pop(state) do
    get_and_update_in(state.stack, fn [addr | stack] -> {addr, stack} end)
  end

  def reg_get(state, reg) do
    state.registers[reg]
  end

  def reg_put(state, reg, val) do
    put_in(state.registers[reg], val)
  end

  def reg_update(state, reg, fun) do
    update_in(state.registers[reg], fun)
  end

  def memory_get(state, pos, n) do
    :binary.part(state.memory, pos, n) |> :binary.bin_to_list
  end

  def memory_put(state, bytes, pos) do
    data = bytes |> IO.iodata_to_binary

    update_in(state.memory, fn memory ->
      memory |> Buffer.put_bytes(data, pos)
    end)
  end

  defp init_registers do
    (0x0..0xF) |> Enum.map(fn i -> {{:v, i}, 0x0} end)
    |> Enum.concat([i: 0x0000, st: 0x00, dt: 0x00])
    |> Enum.into(%{})
  end
end
