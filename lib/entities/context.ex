defmodule Entities.Context do
  defstruct [
    :user_id
  ]

  @type t :: %__MODULE__{
          user_id: integer
        }
end
