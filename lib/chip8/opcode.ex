defmodule Chip8.Opcode do
  require Logger

  def from_int(val) when is_integer(val) do
    <<val::16-big>>
  end

  def disassemble(<<0x00E0::16-big>>) do
    :cls
  end

  def disassemble(<<0x00EE::16-big>>) do
    :ret
  end

  def disassemble(<<0x0::4, _::12>>) do
    :noop
  end

  def disassemble(<<0x1::4, addr::12>>) do
    {:jp, addr}
  end

  def disassemble(<<0x2::4, addr::12>>) do
    {:call, addr}
  end

  def disassemble(<<0x3::4, x::4, kk::8>>) do
    {:se, {:v, x}, kk}
  end

  def disassemble(<<0x4::4, x::4, kk::8>>) do
    {:sne, {:v, x}, kk}
  end

  def disassemble(<<0x5::4, x::4, y::4, 0x0::4>>) do
    {:se, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x6::4, x::4, kk::8>>) do
    {:ld, {:v, x}, kk}
  end

  def disassemble(<<0x7::4, x::4, kk::8>>) do
    {:add, {:v, x}, kk}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x0::4>>) do
    {:ld, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x1::4>>) do
    {:or, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x2::4>>) do
    {:and, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x3::4>>) do
    {:xor, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x4::4>>) do
    {:add, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x5::4>>) do
    {:sub, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x6::4>>) do
    {:shr, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0x7::4>>) do
    {:subn, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x8::4, x::4, y::4, 0xE::4>>) do
    {:shl, {:v, x}, {:v, y}}
  end

  def disassemble(<<0x9::4, x::4, y::4, 0x0::4>>) do
    {:sne, {:v, x}, {:v, y}}
  end

  def disassemble(<<0xA::4, addr::12>>) do
    {:ld, :i, addr}
  end

  def disassemble(<<0xB::4, addr::12>>) do
    {:jp, {:v, 0}, addr}
  end

  def disassemble(<<0xC::4, x::4, kk::8>>) do
    {:rnd, {:v, x}, kk}
  end

  def disassemble(<<0xD::4, x::4, y::4, n::4>>) do
    {:drw, {:v, x}, {:v, y}, n}
  end

  def disassemble(<<0xE::4, x::4, 0x9E::8>>) do
    {:skp, {:v, x}}
  end

  def disassemble(<<0xE::4, x::4, 0xA1::8>>) do
    {:sknp, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x07::8>>) do
    {:ld, {:v, x}, :dt}
  end

  def disassemble(<<0xF::4, x::4, 0x0A::8>>) do
    {:ld, {:v, x}, :k}
  end

  def disassemble(<<0xF::4, x::4, 0x15::8>>) do
    {:ld, :dt, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x18::8>>) do
    {:ld, :st, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x1E::8>>) do
    {:add, :i, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x29::8>>) do
    {:ld, :f, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x33::8>>) do
    {:ld, :b, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x55::8>>) do
    {:ld, {:i}, {:v, x}}
  end

  def disassemble(<<0xF::4, x::4, 0x65::8>>) do
    {:ld, {:v, x}, {:i}}
  end

  def disassemble(opcode) do
    hex =  opcode |> :binary.decode_unsigned(:big) |> Integer.to_string(16) |> String.pad_leading(4, "0")
    Logger.error "Unknown opcode: 0x#{hex}"
  end
end
