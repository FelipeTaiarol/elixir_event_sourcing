defmodule Workflows.ErrorHelpers do
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(Workflows.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Workflows.Gettext, "errors", msg, opts)
    end
  end
end
