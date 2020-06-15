defmodule Example.ErrorView do
  use Phoenix.View,
    root: "lib/workflows_web/templates",
    namespace: Example

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
