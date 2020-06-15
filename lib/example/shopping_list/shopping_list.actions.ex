defmodule Example.ShoppingList.Actions do
  defmodule CreateShoppingList do
    defstruct [
      :id,
      :name
    ]
  end

  defmodule SetName do
    defstruct [
      :id,
      :name
    ]
  end
end
