defmodule Chip8.Interpreter do
  alias Chip8.State
  alias Chip8.Opcode
  alias Chip8.Instruction

  def load(filename) do
    program = File.read!(filename)

    state = State.new
    state |> State.memory_put(program, state.pc)
  end

  def run(state, cycles \\ :infinity, callback \\ &(&1))
  def run(state, _cycles = 0, callback), do: callback.(state)
  def run(state, cycles, callback) do
    case fetch_instruction(state) do
      :halt -> state
      instruction ->
        state = Instruction.execute(instruction, %{state | screen_changed?: false}) |> increment_pc()
        state = callback.(state)
        cycles = if is_integer(cycles), do: cycles - 1, else: cycles
        state |> run(cycles, callback)
    end
  end

  defp fetch_instruction(state) do
    case :binary.part(state.memory, state.pc, 2) do
      <<0, 0>> -> :halt
      instruction -> instruction |> Opcode.disassemble
    end
  end

  defp increment_pc(state) do
    state = update_in(state.cycles, &(&1 + 1))
    state = update_in(state.pc, &(&1 + 2))

    state
  end
end
