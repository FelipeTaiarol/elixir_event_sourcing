defmodule Workflows.Core.Workflow.EventRows do
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
