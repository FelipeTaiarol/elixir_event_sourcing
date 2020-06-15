defmodule Example.ShoppingList.Events do
  defmodule ShoppingListCreated do
    defstruct [
      :id,
      :name
    ]
  end

  defmodule NameChanged do
    defstruct [
      :name
    ]
  end
end
