defmodule Workflows.ErrorView do
  use Phoenix.View,
  root: "lib/getaways_web/templates",
  namespace: Workflows

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
