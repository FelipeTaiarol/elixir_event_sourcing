defmodule Example.Core.Workflow.Actions do
  defmodule CreateWorkflow do
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
