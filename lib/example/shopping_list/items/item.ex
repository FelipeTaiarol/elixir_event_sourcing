defmodule Example.ShoppingList.Items.Item do
  defstruct [
    :id,
    :name,
    :quantity
  ]

  @type t :: %__MODULE__{
          id: integer,
          name: String.t(),
          quantity: integer
        }
end
