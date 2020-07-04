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

  defmodule AddItem do
    defstruct [
      :id,
      :name,
      :quantity
    ]
  end
end
