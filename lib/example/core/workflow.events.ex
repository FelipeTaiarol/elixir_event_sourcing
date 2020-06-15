defmodule Example.Core.Workflow.Events do
  defmodule WorkflowCreated do
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
