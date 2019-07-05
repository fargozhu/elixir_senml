defmodule ElixirSenml.Record do
  @type t :: %__MODULE__{
          bn: String.t(),
          bt: integer,
          bu: String.t(),
          bv: integer,
          bs: integer,
          bver: integer,
          n: String.t(),
          t: integer,
          v: float,
          vs: String.t(),
          vd: String.t(),
          vb: boolean,
          s: integer,
          u: String.t(),
          ut: integer,
          ct: String.t()
        }

  defstruct bn: nil,
            bt: nil,
            bu: nil,
            bv: nil,
            bs: nil,
            bver: nil,
            n: nil,
            t: nil,
            v: nil,
            vs: nil,
            vb: nil,
            vd: nil,
            s: nil,
            u: nil,
            ut: nil,
            ct: nil
end
